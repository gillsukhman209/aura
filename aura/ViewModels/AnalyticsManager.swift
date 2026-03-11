import Foundation

/// Computes analytics for a single habit: completion rates, heatmap data, streaks.
struct HabitAnalytics {
    let habit: Habit

    private let calendar = Calendar.current

    // MARK: - Completion Rates

    /// Completion rate over the last N days (0.0–1.0).
    func completionRate(days: Int) -> Double {
        let today = calendar.startOfDay(for: appNow())
        var scheduled = 0
        var completed = 0

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            guard date >= calendar.startOfDay(for: habit.createdAt) else { continue }
            if habit.isScheduled(on: date) {
                scheduled += 1
                if habit.isCompleted(on: date) {
                    completed += 1
                }
            }
        }

        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }

    var rate7d: Double { completionRate(days: 7) }
    var rate30d: Double { completionRate(days: 30) }
    var rate90d: Double { completionRate(days: 90) }

    // MARK: - Heatmap Data

    /// Returns a dictionary mapping dates to heatmap intensity levels for the last N days.
    func heatmapData(days: Int = 112) -> [Date: HeatmapLevel] {
        let today = calendar.startOfDay(for: appNow())
        var result: [Date: HeatmapLevel] = [:]

        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)

            guard startOfDay >= calendar.startOfDay(for: habit.createdAt) else { continue }

            if !habit.isScheduled(on: date) {
                result[startOfDay] = .none
                continue
            }

            if let log = habit.log(for: date) {
                switch log.status {
                case .completed:
                    // For numeric habits, scale by how much over target
                    if habit.type == .numeric, let target = habit.targetValue, let value = log.value, target > 0 {
                        let ratio = value / target
                        if ratio >= 1.5 { result[startOfDay] = .max }
                        else if ratio >= 1.0 { result[startOfDay] = .high }
                        else { result[startOfDay] = .medium }
                    } else {
                        result[startOfDay] = .high
                    }
                case .partial:
                    result[startOfDay] = .low
                case .relapsed:
                    result[startOfDay] = .none
                case .skipped:
                    result[startOfDay] = .none
                }
            } else {
                // No log — for quit habits before day reset, this is neutral
                if habit.type == .quit {
                    result[startOfDay] = .medium // Going strong (not yet evaluated by DayResetService)
                } else {
                    result[startOfDay] = .none
                }
            }
        }

        return result
    }

    // MARK: - Habit Streak (per-habit, not global)

    /// Current consecutive days this habit was completed.
    var currentHabitStreak: Int {
        let today = calendar.startOfDay(for: appNow())
        var streak = 0
        var date = today

        // Start from yesterday if today isn't completed yet
        if !habit.isCompleted(on: today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            date = yesterday
        }

        while true {
            guard date >= calendar.startOfDay(for: habit.createdAt) else { break }

            if habit.isScheduled(on: date) {
                if habit.isCompleted(on: date) {
                    streak += 1
                } else {
                    break
                }
            }
            // Skip non-scheduled days
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }

        return streak
    }

    // MARK: - Total Completions

    var totalCompletions: Int {
        habit.logs.filter { $0.status == .completed }.count
    }

    // MARK: - Total XP Earned

    var totalXPEarned: Int {
        totalCompletions * habit.baseXP
    }
}
