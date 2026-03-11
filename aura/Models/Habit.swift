import Foundation
import SwiftData

@Model
final class Habit {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String

    // MARK: - Classification

    var typeRaw: String
    var difficultyRaw: String
    var statRaw: String

    // MARK: - Schedule (stored as JSON)

    var scheduleData: Data

    // MARK: - Numeric-only

    var targetValue: Double?
    var unit: String?

    // MARK: - XP (derived from difficulty, stored for query performance)

    var baseXP: Int
    var statXP: Int

    // MARK: - Meta

    var isArchived: Bool
    var createdAt: Date
    var sortOrder: Int

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]

    // MARK: - Computed Properties

    var type: HabitType {
        get { HabitType(rawValue: typeRaw) ?? .build }
        set { typeRaw = newValue.rawValue }
    }

    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .medium }
        set {
            difficultyRaw = newValue.rawValue
            baseXP = newValue.baseXP
            statXP = newValue.statXP
        }
    }

    var stat: StatType {
        get { StatType(rawValue: statRaw) ?? .strength }
        set { statRaw = newValue.rawValue }
    }

    var schedule: Schedule {
        get {
            (try? JSONDecoder().decode(Schedule.self, from: scheduleData)) ?? .daily
        }
        set {
            scheduleData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    // MARK: - Init

    init(
        name: String,
        type: HabitType,
        icon: String,
        difficulty: Difficulty,
        stat: StatType,
        schedule: Schedule = .daily,
        targetValue: Double? = nil,
        unit: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.typeRaw = type.rawValue
        self.difficultyRaw = difficulty.rawValue
        self.statRaw = stat.rawValue
        self.scheduleData = (try? JSONEncoder().encode(schedule)) ?? Data()
        self.targetValue = targetValue
        self.unit = unit
        self.baseXP = difficulty.baseXP
        self.statXP = difficulty.statXP
        self.isArchived = false
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.logs = []
    }
}

// MARK: - Query Helpers

extension Habit {
    /// Whether this habit is scheduled for a given date.
    func isScheduled(on date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let day = Weekday.from(calendarWeekday: weekday)
        return schedule.isScheduled(on: day)
    }

    /// Find the log for a specific calendar day, if any.
    func log(for date: Date) -> HabitLog? {
        let calendar = Calendar.current
        return logs.first { log in
            calendar.isDate(log.date, inSameDayAs: date)
        }
    }

    /// Whether the habit is completed for a given date.
    func isCompleted(on date: Date) -> Bool {
        guard let log = log(for: date) else {
            // Quit habits: no log means success (evaluated at day reset)
            return type == .quit
        }
        return log.status == .completed
    }
}
