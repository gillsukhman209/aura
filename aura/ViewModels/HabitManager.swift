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
        syncProfileState()
        dailyBonusAwarded = false
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
        let today = appNow()
        return habits.filter { $0.isScheduled(on: today) }
    }

    var completedTodayCount: Int {
        let today = appNow()
        return todaysHabits.filter { $0.isCompleted(on: today) }.count
    }

    var allTodayCompleted: Bool {
        let today = appNow()
        let scheduled = todaysHabits
        guard !scheduled.isEmpty else { return false }
        return scheduled.allSatisfy { $0.isCompleted(on: today) }
    }

    // MARK: - Profile Accessors (stored for @Observable reactivity)

    private(set) var levelInfo: LevelInfo = LevelSystem.levelInfo(for: 0)
    private(set) var totalXP: Int = 0
    private(set) var currentStreak: Int = 0
    private(set) var longestStreak: Int = 0

    // Convenience accessors
    var level: Int { levelInfo.globalLevel }
    var currentLevelXP: Int { levelInfo.currentXP }
    var xpPerLevel: Int { levelInfo.xpRequired }

    /// Sync stored properties from profile so @Observable detects changes.
    private func syncProfileState() {
        let xp = profile?.totalXP ?? 0
        totalXP = xp
        levelInfo = LevelSystem.levelInfo(for: xp)
        currentStreak = profile?.currentStreak ?? 0
        longestStreak = profile?.longestStreak ?? 0
    }

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
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: appNow()) ?? appNow()

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
        let today = calendar.startOfDay(for: appNow())
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

    /// Level roadmap for display.
    var roadmapLevels: [RoadmapLevel] {
        LevelSystem.allLevels(currentTotalXP: totalXP)
    }

    /// Daily XP earned for each day this week (Mon-Sun), for bar chart.
    var weeklyXPPerDay: [(label: String, xp: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())

        // Find Monday of this week
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7 // Mon=0, Tue=1, ..., Sun=6
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }

        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return (label: dayLabels[offset], xp: 0)
            }
            let dayStart = calendar.startOfDay(for: day)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                return (label: dayLabels[offset], xp: 0)
            }

            let xp = habits.flatMap { habit in
                habit.logs.filter { log in
                    let logDay = calendar.startOfDay(for: log.date)
                    return logDay >= dayStart && logDay < dayEnd && log.status == .completed
                }.map { _ in habit.baseXP }
            }.reduce(0, +)

            return (label: dayLabels[offset], xp: xp)
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
        let today = appNow()
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
        let today = appNow()

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
        let today = appNow()

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
        let today = appNow()
        guard let log = habit.log(for: today) else { return }

        if log.status == .completed {
            // Reverse XP
            profile?.addXP(-habit.baseXP)
            profile?.addStatXP(-habit.statXP, to: habit.stat)
        }

        habit.logs.removeAll { $0.id == log.id }
        modelContext.delete(log)
        syncProfileState()
        save()
    }

    // MARK: - XP Engine

    /// Whether the daily completion bonus has been awarded today.
    private(set) var dailyBonusAwarded: Bool = false

    private func awardXP(for habit: Habit) {
        profile?.addXP(habit.baseXP)
        profile?.addStatXP(habit.statXP, to: habit.stat)
        syncProfileState()
        checkDailyCompletionBonus()
    }

    /// Award +40 AP bonus when all today's habits are completed (once per day).
    private func checkDailyCompletionBonus() {
        guard !dailyBonusAwarded, allTodayCompleted else { return }
        profile?.addXP(40)
        dailyBonusAwarded = true
        syncProfileState()
        save()
    }

    /// Reset the daily bonus flag (called on day change).
    func resetDailyBonus() {
        dailyBonusAwarded = false
    }

    // MARK: - Day Reset

    /// Run day-reset evaluation on app foreground. Safe to call multiple times.
    func performDayReset() {
        guard let profile else { return }
        let service = DayResetService(modelContext: modelContext)
        service.evaluateIfNeeded(profile: profile, habits: habits)
        refresh() // refresh already calls syncProfileState()
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
    /// Scale the bar to the next milestone above current value
    var maxValue: Int {
        if value <= 10 { return 10 }
        if value <= 25 { return 25 }
        if value <= 50 { return 50 }
        if value <= 100 { return 100 }
        // Round up to next 100
        return ((value / 100) + 1) * 100
    }
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

