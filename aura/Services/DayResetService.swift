import Foundation
import SwiftData

/// Handles midnight day-reset logic: evaluates missed days, auto-completes quit habits,
/// updates streak, applies XP penalties. Runs on app launch via `scenePhase` check.
struct DayResetService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Call on every app foreground. Evaluates all days between `lastCompletedDate` and yesterday.
    func evaluateIfNeeded(profile: UserProfile, habits: [Habit]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())

        // Determine the first day to evaluate
        let startDate: Date
        if let last = profile.lastCompletedDate {
            // Start evaluating the day after the last completed date
            guard let dayAfter = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: last)) else { return }
            startDate = dayAfter
        } else {
            // First time: evaluate yesterday only (don't penalize days before the user had habits)
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
            startDate = yesterday
        }

        // Don't evaluate today (it's still in progress) or future dates
        guard startDate < today else { return }

        // Cap at 30 days to prevent excessive processing after long absence
        let maxLookback = calendar.date(byAdding: .day, value: -30, to: today) ?? startDate
        let evalStart = max(startDate, maxLookback)

        var date = evalStart
        while date < today {
            evaluateDay(date, profile: profile, habits: habits, calendar: calendar)
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        // Update lastCompletedDate to yesterday so we don't re-evaluate
        profile.lastCompletedDate = calendar.date(byAdding: .day, value: -1, to: today)
        try? modelContext.save()
    }

    /// Evaluate a single past day.
    private func evaluateDay(_ date: Date, profile: UserProfile, habits: [Habit], calendar: Calendar) {
        let scheduledHabits = habits.filter { $0.isScheduled(on: date) }

        guard !scheduledHabits.isEmpty else { return }

        // Auto-complete quit habits that had no relapse
        for habit in scheduledHabits where habit.type == .quit {
            if habit.log(for: date) == nil {
                // No log = no relapse = success. Create a completed log.
                let log = HabitLog(habit: habit, date: date, status: .completed)
                modelContext.insert(log)
                habit.logs.append(log)
            }
        }

        // Check if all scheduled habits were completed
        let allCompleted = scheduledHabits.allSatisfy { $0.isCompleted(on: date) }

        if allCompleted {
            profile.incrementStreak()
        } else {
            profile.resetStreak()
            profile.penalizeXP(20)
        }
    }
}
