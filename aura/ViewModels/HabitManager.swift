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

    /// Date the daily completion bonus was last awarded.
    private var lastBonusDate: Date?

    /// Whether the daily bonus has already been awarded today.
    var dailyBonusAwarded: Bool {
        guard let lastBonusDate else { return false }
        return Calendar.current.isDate(lastBonusDate, inSameDayAs: appNow())
    }

    /// Tracks the previous level for level-up detection.
    private(set) var previousLevel: Int = 0

    /// Set to true when a level-up just occurred — UI reads this to show celebration.
    private(set) var showLevelUpCelebration: Bool = false
    private(set) var celebrationLevelInfo: LevelInfo?

    func dismissLevelUp() {
        showLevelUpCelebration = false
        celebrationLevelInfo = nil
    }

    /// Set to true when aura is lost — UI reads this to show negative feedback.
    private(set) var showAuraLost: Bool = false
    private(set) var auraLostAmount: Int = 0

    func dismissAuraLost() {
        showAuraLost = false
        auraLostAmount = 0
    }

    private func awardXP(for habit: Habit) {
        let oldLevel = levelInfo.globalLevel
        profile?.addXP(habit.baseXP)
        profile?.addStatXP(habit.statXP, to: habit.stat)
        syncProfileState()
        checkDailyCompletionBonus()

        // Check for level-up
        if levelInfo.globalLevel > oldLevel {
            celebrationLevelInfo = levelInfo
            showLevelUpCelebration = true
        }
    }

    /// Award +40 AP bonus when all today's habits are completed (once per day).
    private func checkDailyCompletionBonus() {
        guard !dailyBonusAwarded, allTodayCompleted else { return }
        let oldLevel = levelInfo.globalLevel
        profile?.addXP(40)
        lastBonusDate = appNow()
        syncProfileState()
        save()

        // All done — cancel evening and streak-death roasts
        NotificationService.shared.cancelCompletionRoasts()

        // Check for streak milestones
        let milestones = [7, 14, 30, 60, 90, 180, 365]
        if milestones.contains(currentStreak) {
            NotificationService.shared.scheduleMilestoneNotification(streak: currentStreak)
        }

        if levelInfo.globalLevel > oldLevel {
            celebrationLevelInfo = levelInfo
            showLevelUpCelebration = true
        }
    }

    // MARK: - Day Reset

    /// Run day-reset evaluation on app foreground. Safe to call multiple times.
    func performDayReset() {
        guard let profile else { return }
        let xpBefore = profile.totalXP
        let streakBefore = profile.currentStreak
        let service = DayResetService(modelContext: modelContext)
        service.evaluateIfNeeded(profile: profile, habits: habits)
        let xpAfter = profile.totalXP
        refresh()

        // Detect aura loss from penalties
        if xpAfter < xpBefore {
            auraLostAmount = xpBefore - xpAfter
            showAuraLost = true

            // Schedule post-penalty roast notification
            let intensity = RoastIntensity(rawValue: UserDefaults.standard.string(forKey: "roastIntensity") ?? "brutal") ?? .brutal
            let enabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
            if enabled {
                NotificationService.shared.schedulePostPenaltyRoast(
                    apLost: auraLostAmount,
                    oldStreak: streakBefore,
                    missedHabits: [],
                    rank: levelInfo.displayName,
                    intensity: intensity
                )
            }
        }
    }

    // MARK: - Debug

    func debugAddXP(_ amount: Int) {
        let oldLevel = levelInfo.globalLevel
        profile?.addXP(amount)
        syncProfileState()
        save()
        if levelInfo.globalLevel > oldLevel {
            celebrationLevelInfo = levelInfo
            showLevelUpCelebration = true
        }
    }

    // MARK: - Mock Data

    func seedMockData() {
        // Clear existing data
        let existingHabits = (try? modelContext.fetch(FetchDescriptor<Habit>())) ?? []
        for h in existingHabits { modelContext.delete(h) }
        let existingLogs = (try? modelContext.fetch(FetchDescriptor<HabitLog>())) ?? []
        for l in existingLogs { modelContext.delete(l) }
        let existingProfiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        for p in existingProfiles { modelContext.delete(p) }
        save()

        // Create profile
        let newProfile = UserProfile()
        newProfile.totalXP = 4200
        newProfile.currentStreak = 12
        newProfile.longestStreak = 18
        newProfile.lastCompletedDate = Calendar.current.date(byAdding: .day, value: -1, to: appNow())
        var statsDict: [String: Int] = [:]
        statsDict[StatType.strength.rawValue] = 68
        statsDict[StatType.focus.rawValue] = 52
        statsDict[StatType.discipline.rawValue] = 74
        statsDict[StatType.knowledge.rawValue] = 45
        statsDict[StatType.energy.rawValue] = 56
        newProfile.stats = statsDict
        modelContext.insert(newProfile)

        // Define mock habits
        let mockHabits: [(name: String, type: HabitType, icon: String, difficulty: Difficulty, stat: StatType, schedule: Schedule, target: Double?, unit: String?)] = [
            ("Gym", .build, "dumbbell.fill", .major, .strength, .specificDays(Set([.monday, .wednesday, .friday, .saturday])), nil, nil),
            ("Read 30 min", .build, "book.fill", .medium, .knowledge, .daily, nil, nil),
            ("Meditate", .build, "brain.head.profile", .medium, .focus, .daily, nil, nil),
            ("Cold Shower", .build, "snowflake", .minor, .discipline, .daily, nil, nil),
            ("No Doom Scrolling", .quit, "iphone.slash", .medium, .focus, .daily, nil, nil),
            ("Drink Water", .numeric, "drop.fill", .minor, .energy, .daily, 3.0, "L"),
            ("Journal", .build, "pencil.line", .minor, .discipline, .specificDays(Set([.monday, .wednesday, .friday])), nil, nil),
            ("Run", .build, "figure.run", .major, .energy, .specificDays(Set([.tuesday, .thursday, .saturday])), nil, nil),
        ]

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())

        for (i, mock) in mockHabits.enumerated() {
            let habit = Habit(
                name: mock.name,
                type: mock.type,
                icon: mock.icon,
                difficulty: mock.difficulty,
                stat: mock.stat,
                schedule: mock.schedule,
                targetValue: mock.target,
                unit: mock.unit,
                sortOrder: i
            )
            habit.createdAt = calendar.date(byAdding: .day, value: -35, to: today) ?? today
            modelContext.insert(habit)

            // Generate 30 days of history (not today)
            for dayOffset in 1...30 {
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
                guard habit.isScheduled(on: date) else { continue }

                // ~85% completion rate
                let shouldComplete = Int.random(in: 1...100) <= 85

                if mock.type == .quit {
                    // Quit habits: log only relapses
                    if !shouldComplete {
                        let log = HabitLog(habit: habit, date: date, status: .relapsed)
                        modelContext.insert(log)
                        habit.logs.append(log)
                    }
                } else if mock.type == .numeric {
                    if shouldComplete {
                        let value = (mock.target ?? 3.0) * Double.random(in: 0.9...1.3)
                        let log = HabitLog(habit: habit, date: date, status: .completed, value: value)
                        modelContext.insert(log)
                        habit.logs.append(log)
                    } else {
                        let value = (mock.target ?? 3.0) * Double.random(in: 0.2...0.6)
                        let log = HabitLog(habit: habit, date: date, status: .partial, value: value)
                        modelContext.insert(log)
                        habit.logs.append(log)
                    }
                } else {
                    // Build habits
                    if shouldComplete {
                        let log = HabitLog(habit: habit, date: date, status: .completed)
                        modelContext.insert(log)
                        habit.logs.append(log)
                    }
                }
            }

            // Today: complete ~60% of habits
            if habit.isScheduled(on: today) {
                let completeToday = i < 5 // first 5 habits completed today

                if mock.type == .quit {
                    // No log = success for quit
                } else if mock.type == .numeric && completeToday {
                    let value = (mock.target ?? 3.0) * Double.random(in: 1.0...1.2)
                    let log = HabitLog(habit: habit, date: today, status: .completed, value: value)
                    modelContext.insert(log)
                    habit.logs.append(log)
                } else if mock.type == .build && completeToday {
                    let log = HabitLog(habit: habit, date: today, status: .completed)
                    modelContext.insert(log)
                    habit.logs.append(log)
                }
            }
        }

        save()
        profile = newProfile
        fetchHabits()
        syncProfileState()
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

