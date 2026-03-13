import SwiftUI

// MARK: - Habit Type

enum HabitType: String, Codable, CaseIterable, Identifiable {
    case build
    case quit
    case numeric

    var id: String { rawValue }

    var label: String {
        switch self {
        case .build: "Build"
        case .quit: "Quit"
        case .numeric: "Numeric"
        }
    }

    var description: String {
        switch self {
        case .build: "Check off when done"
        case .quit: "Success unless you relapse"
        case .numeric: "Track a measurable value"
        }
    }

    var icon: String {
        switch self {
        case .build: "plus.circle.fill"
        case .quit: "xmark.circle.fill"
        case .numeric: "number.circle.fill"
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case minor
    case medium
    case major

    var id: String { rawValue }

    var label: String {
        switch self {
        case .minor: "Minor"
        case .medium: "Medium"
        case .major: "Major"
        }
    }

    var baseXP: Int {
        switch self {
        case .minor: 5
        case .medium: 15
        case .major: 30
        }
    }

    var statXP: Int {
        switch self {
        case .minor: 1
        case .medium: 3
        case .major: 5
        }
    }

    var color: Color {
        switch self {
        case .minor: AppTheme.accentGreen
        case .medium: AppTheme.statBlue
        case .major: AppTheme.accentOrange
        }
    }
}

// MARK: - Stat Type

enum StatType: String, Codable, CaseIterable, Identifiable {
    case strength
    case focus
    case discipline
    case knowledge
    case energy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .strength: "Strength"
        case .focus: "Focus"
        case .discipline: "Discipline"
        case .knowledge: "Knowledge"
        case .energy: "Energy"
        }
    }

    var icon: String {
        switch self {
        case .strength: "figure.strengthtraining.traditional"
        case .focus: "eye.fill"
        case .discipline: "flame.fill"
        case .knowledge: "book.fill"
        case .energy: "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .strength: AppTheme.statGold
        case .focus: AppTheme.statBlue
        case .discipline: AppTheme.statOrange
        case .knowledge: AppTheme.statGold
        case .energy: AppTheme.statBlue
        }
    }
}

// MARK: - Schedule

enum Schedule: Codable, Equatable {
    case daily
    case specificDays(Set<Weekday>)

    var label: String {
        switch self {
        case .daily:
            return "Every day"
        case .specificDays(let days):
            let sorted = days.sorted { $0.sortIndex < $1.sortIndex }
            return sorted.map(\.shortLabel).joined(separator: ", ")
        }
    }

    /// Whether this habit is scheduled for the given weekday.
    func isScheduled(on day: Weekday) -> Bool {
        switch self {
        case .daily:
            return true
        case .specificDays(let days):
            return days.contains(day)
        }
    }
}

// MARK: - Weekday

enum Weekday: String, Codable, CaseIterable, Identifiable, Hashable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        case .sunday: "Sun"
        }
    }

    var sortIndex: Int {
        switch self {
        case .monday: 0
        case .tuesday: 1
        case .wednesday: 2
        case .thursday: 3
        case .friday: 4
        case .saturday: 5
        case .sunday: 6
        }
    }

    /// Create from Foundation's `Calendar.component(.weekday)` (1=Sunday, 2=Monday, ...).
    static func from(calendarWeekday: Int) -> Weekday {
        switch calendarWeekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }

    /// The current weekday based on the user's calendar.
    static var today: Weekday {
        let weekday = Calendar.current.component(.weekday, from: appNow())
        return from(calendarWeekday: weekday)
    }
}

// MARK: - Log Status

enum LogStatus: String, Codable {
    case completed
    case skipped
    case relapsed
    case partial
}
