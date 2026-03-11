import Foundation
import SwiftData
import SwiftUI

@Observable
final class HabitManager {
    private let modelContext: ModelContext

    // MARK: - Cached State

    var profile: UserProfile?
    var habits: [Habit] = []

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    // MARK: - Refresh

    func refresh() {
        fetchProfile()
        fetchHabits()
    }

    private func fetchProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        profile = try? modelContext.fetch(descriptor).first
    }

    private func fetchHabits() {
        var descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )
        descriptor.fetchLimit = 200
        habits = (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Today's Habits

    var todaysHabits: [Habit] {
        let today = Date()
        return habits.filter { $0.isScheduled(on: today) }
    }

    var completedTodayCount: Int {
        let today = Date()
        return todaysHabits.filter { $0.isCompleted(on: today) }.count
    }

    var allTodayCompleted: Bool {
        let today = Date()
        let scheduled = todaysHabits
        guard !scheduled.isEmpty else { return false }
        return scheduled.allSatisfy { $0.isCompleted(on: today) }
    }

    // MARK: - Profile Accessors

    var level: Int { profile?.level ?? 0 }
    var totalXP: Int { profile?.totalXP ?? 0 }
    var currentLevelXP: Int { profile?.currentLevelXP ?? 0 }
    var xpPerLevel: Int { profile?.xpPerLevel ?? 100 }
    var currentStreak: Int { profile?.currentStreak ?? 0 }
    var longestStreak: Int { profile?.longestStreak ?? 0 }

    func statValue(for stat: StatType) -> Int {
        profile?.statValue(for: stat) ?? 0
    }

    /// Character stats for display — derived from real UserProfile data.
    var characterStats: [DisplayStat] {
        StatType.allCases.map { stat in
            DisplayStat(
                statType: stat,
                value: statValue(for: stat)
            )
        }
    }

    /// Weekly XP gained per stat (last 7 days).
    var weeklyProgress: [DisplayWeeklyStat] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        return StatType.allCases.compactMap { stat in
            let xp = habits
                .filter { $0.stat == stat }
                .flatMap { habit in
                    habit.logs.filter { log in
                        log.date >= weekAgo && log.status == .completed
                    }.map { _ in habit.statXP }
                }
                .reduce(0, +)

            guard xp > 0 else { return nil }
            return DisplayWeeklyStat(statType: stat, xpGained: xp)
        }
    }

    /// Consistency score: % of habits completed over rolling 30 days.
    var consistencyScore: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var totalScheduled = 0
        var totalCompleted = 0

        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            for habit in habits {
                if habit.isScheduled(on: date) {
                    totalScheduled += 1
                    if habit.isCompleted(on: date) {
                        totalCompleted += 1
                    }
                }
            }
        }

        guard totalScheduled > 0 else { return 0 }
        return Int(Double(totalCompleted) / Double(totalScheduled) * 100)
    }

    /// Rank based on consistency score.
    var currentRank: AuraRank {
        let score = consistencyScore
        let thresholds: [(Int, AuraRank)] = [
            (95, AuraRank.ranks[5]), // Diamond
            (85, AuraRank.ranks[4]), // Gold
            (70, AuraRank.ranks[3]), // Silver
            (50, AuraRank.ranks[2]), // Bronze
            (30, AuraRank.ranks[1]), // Iron
        ]
        for (threshold, rank) in thresholds {
            if score >= threshold { return rank }
        }
        return AuraRank.ranks[0] // Unranked
    }

    var displayRanks: [DisplayRank] {
        let score = consistencyScore
        let thresholds = [0, 30, 50, 70, 85, 95]
        return AuraRank.ranks.enumerated().map { i, rank in
            let isUnlocked = score >= thresholds[i]
            let isCurrent = rank.name == currentRank.name
            return DisplayRank(
                rank: rank,
                threshold: thresholds[i],
                isUnlocked: isUnlocked,
                isCurrent: isCurrent
            )
        }
    }

    // MARK: - Habit CRUD

    func createHabit(
        name: String,
        type: HabitType,
        icon: String,
        difficulty: Difficulty,
        stat: StatType,
        schedule: Schedule = .daily,
        targetValue: Double? = nil,
        unit: String? = nil
    ) {
        let habit = Habit(
            name: name,
            type: type,
            icon: icon,
            difficulty: difficulty,
            stat: stat,
            schedule: schedule,
            targetValue: targetValue,
            unit: unit,
            sortOrder: habits.count
        )
        modelContext.insert(habit)
        save()
        fetchHabits()
    }

    func updateHabit(_ habit: Habit, name: String, icon: String, schedule: Schedule) {
        habit.name = name
        habit.icon = icon
        habit.schedule = schedule
        save()
    }

    func archiveHabit(_ habit: Habit) {
        habit.isArchived = true
        save()
        fetchHabits()
    }

    func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        save()
        fetchHabits()
    }

    // MARK: - Habit Completion

    /// Complete a build habit for today.
    func completeBuildHabit(_ habit: Habit) {
        guard habit.type == .build else { return }
        let today = Date()
        guard habit.log(for: today) == nil else { return } // already logged

        let log = HabitLog(habit: habit, date: today, status: .completed)
        modelContext.insert(log)
        habit.logs.append(log)
        awardXP(for: habit)
        save()
    }

    /// Log a relapse for a quit habit.
    func logRelapse(_ habit: Habit) {
        guard habit.type == .quit else { return }
        let today = Date()

        if let existing = habit.log(for: today) {
            existing.status = .relapsed
        } else {
            let log = HabitLog(habit: habit, date: today, status: .relapsed)
            modelContext.insert(log)
            habit.logs.append(log)
        }
        save()
    }

    /// Log numeric progress. Accumulates across multiple calls per day.
    func logNumericProgress(_ habit: Habit, value: Double) {
        guard habit.type == .numeric else { return }
        let today = Date()

        if let existing = habit.log(for: today) {
            let newValue = (existing.value ?? 0) + value
            existing.value = newValue
            existing.completedAt = Date()

            let wasPartial = existing.status != .completed
            if let target = habit.targetValue, newValue >= target {
                existing.status = .completed
                if wasPartial {
                    awardXP(for: habit)
                }
            } else {
                existing.status = .partial
            }
        } else {
            let status: LogStatus
            if let target = habit.targetValue, value >= target {
                status = .completed
            } else {
                status = .partial
            }
            let log = HabitLog(habit: habit, date: today, status: status, value: value)
            modelContext.insert(log)
            habit.logs.append(log)

            if status == .completed {
                awardXP(for: habit)
            }
        }
        save()
    }

    /// Undo a build habit completion for today.
    func undoCompletion(_ habit: Habit) {
        let today = Date()
        guard let log = habit.log(for: today) else { return }

        if log.status == .completed {
            // Reverse XP
            profile?.addXP(-habit.baseXP)
            profile?.addStatXP(-habit.statXP, to: habit.stat)
        }

        habit.logs.removeAll { $0.id == log.id }
        modelContext.delete(log)
        save()
    }

    // MARK: - XP Engine

    private func awardXP(for habit: Habit) {
        profile?.addXP(habit.baseXP)
        profile?.addStatXP(habit.statXP, to: habit.stat)
    }

    // MARK: - Day Reset

    /// Run day-reset evaluation on app foreground. Safe to call multiple times.
    func performDayReset() {
        guard let profile else { return }
        let service = DayResetService(modelContext: modelContext)
        service.evaluateIfNeeded(profile: profile, habits: habits)
        refresh()
    }

    // MARK: - Persistence

    private func save() {
        try? modelContext.save()
    }
}

// MARK: - Display Structs (lightweight, for UI components)

struct DisplayStat: Identifiable {
    let id = UUID()
    let statType: StatType
    let value: Int

    var name: String { statType.label }
    var icon: String { statType.icon }
    var color: Color { statType.color }
    var maxValue: Int { 100 }
    var subtitle: String { "RANK" }
}

struct DisplayWeeklyStat: Identifiable {
    let id = UUID()
    let statType: StatType
    let xpGained: Int

    var name: String { statType.label }
    var icon: String { statType.icon }
    var color: Color { statType.color }
}

struct DisplayRank: Identifiable {
    let id = UUID()
    let rank: AuraRank
    let threshold: Int
    let isUnlocked: Bool
    let isCurrent: Bool

    var name: String { rank.name }
    var tier: String { rank.tier }
    var icon: String { rank.icon }
    var color: Color { Color(hex: rank.color) }
}
