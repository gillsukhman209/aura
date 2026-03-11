import Foundation
import SwiftData

@Model
final class HabitLog {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - Relationship

    var habit: Habit?

    // MARK: - Log Data

    /// Calendar day (normalized to start of day in local timezone).
    var date: Date

    /// Completion status.
    var statusRaw: String

    /// Actual value for numeric habits (e.g. 2.5 liters).
    var value: Double?

    /// Timestamp when the user completed/logged this.
    var completedAt: Date?

    // MARK: - Computed

    var status: LogStatus {
        get { LogStatus(rawValue: statusRaw) ?? .completed }
        set { statusRaw = newValue.rawValue }
    }

    // MARK: - Init

    init(
        habit: Habit,
        date: Date,
        status: LogStatus,
        value: Double? = nil
    ) {
        self.id = UUID()
        self.habit = habit
        self.date = Calendar.current.startOfDay(for: date)
        self.statusRaw = status.rawValue
        self.value = value
        self.completedAt = Date()
    }
}

// MARK: - Helpers

extension HabitLog {
    /// Whether the numeric value meets or exceeds the habit's target.
    var meetsTarget: Bool {
        guard let habit, let target = habit.targetValue, let actual = value else {
            return false
        }
        return actual >= target
    }
}
