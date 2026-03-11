import Foundation
import SwiftUI

/// DEBUG: Global date override for testing. Remove before release.
@Observable
final class DebugDate {
    static let shared = DebugDate()

    /// Offset in days from the real date. 0 = real time.
    var dayOffset: Int = 0

    /// The "current" date used throughout the app.
    var now: Date {
        if dayOffset == 0 { return Date() }
        return Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
    }

    func forward() { dayOffset += 1 }
    func back() { dayOffset -= 1 }
    func reset() { dayOffset = 0 }
}

/// Use this everywhere instead of Date() when you mean "today".
func appNow() -> Date {
    DebugDate.shared.now
}
