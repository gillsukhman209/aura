import Foundation

enum WeekKey {
    static func current(for date: Date = Date()) -> String {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let year = comps.yearForWeekOfYear ?? 0
        let week = comps.weekOfYear ?? 0
        return String(format: "%04d-W%02d", year, week)
    }
}
