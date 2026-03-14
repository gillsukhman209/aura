import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    // MARK: - Notification IDs

    private enum ID {
        static let morningRoast = "morning-roast"
        static let eveningRoast = "evening-roast"
        static let streakDeath = "streak-death-warning"
        static let inactivity2Day = "inactivity-2day"
        static let inactivity5Day = "inactivity-5day"
        static let postPenalty = "post-penalty"
        static let streakMilestone = "streak-milestone"
    }

    // MARK: - Permission

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var isAuthorized: Bool {
        var result = false
        let semaphore = DispatchSemaphore(value: 0)
        center.getNotificationSettings { settings in
            result = settings.authorizationStatus == .authorized
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }

    // MARK: - Master Reschedule (called on foreground)

    func rescheduleAll(
        habitCount: Int,
        completedCount: Int,
        habitNames: [String],
        streak: Int,
        bestStreak: Int,
        rank: String,
        consistency: Int,
        discipline: Int,
        allCompleted: Bool,
        morningHour: Int,
        morningMinute: Int,
        eveningHour: Int,
        eveningMinute: Int,
        intensity: RoastIntensity,
        enabled: Bool,
        inactivityEnabled: Bool
    ) {
        guard enabled else {
            cancelAll()
            return
        }

        let remaining = habitCount - completedCount
        let incompleteNames = habitNames

        let context = RoastContext(
            habitCount: habitCount,
            completedCount: completedCount,
            remainingCount: remaining,
            habitNames: incompleteNames,
            streak: streak,
            bestStreak: bestStreak,
            rank: rank,
            consistency: consistency,
            discipline: discipline,
            apLost: 0,
            oldStreak: 0,
            intensity: intensity
        )

        // Always schedule morning roast
        scheduleMorningRoast(hour: morningHour, minute: morningMinute, context: context)

        // Evening + streak-death only if not all completed
        if !allCompleted && remaining > 0 {
            scheduleEveningRoast(hour: eveningHour, minute: eveningMinute, context: context)
            if streak >= 3 {
                scheduleStreakDeathWarning(context: context)
            } else {
                cancel(ids: [ID.streakDeath])
            }
        } else {
            cancelCompletionRoasts()
        }

        // Cancel inactivity on foreground (will be rescheduled on background)
        cancelInactivityRoasts()
    }

    // MARK: - Morning Roast

    private func scheduleMorningRoast(hour: Int, minute: Int, context: RoastContext) {
        cancel(ids: [ID.morningRoast])

        let body = RoastEngine.morningRoast(context: context)
        let content = makeContent(title: "Rise and Grind", body: body)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: ID.morningRoast, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Evening Roast

    private func scheduleEveningRoast(hour: Int, minute: Int, context: RoastContext) {
        cancel(ids: [ID.eveningRoast])

        let body = RoastEngine.eveningRoast(context: context)
        let content = makeContent(title: "Unfinished Business", body: body)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: ID.eveningRoast, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Streak Death Warning (10 PM)

    private func scheduleStreakDeathWarning(context: RoastContext) {
        cancel(ids: [ID.streakDeath])

        let body = RoastEngine.streakDeathRoast(context: context)
        let content = makeContent(title: "Streak at Risk", body: body)

        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: ID.streakDeath, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Inactivity Roasts

    func scheduleInactivityRoasts(rank: String, intensity: RoastIntensity, enabled: Bool) {
        guard enabled else { return }

        let context = RoastContext(
            habitCount: 0, completedCount: 0, remainingCount: 0,
            habitNames: [], streak: 0, bestStreak: 0,
            rank: rank, consistency: 0, discipline: 0,
            apLost: 0, oldStreak: 0, intensity: intensity
        )

        // 2-day
        let body2 = RoastEngine.inactivityRoast(days: 2, context: context)
        let content2 = makeContent(title: "Where'd You Go?", body: body2)
        let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 24 * 60 * 60, repeats: false)
        let request2 = UNNotificationRequest(identifier: ID.inactivity2Day, content: content2, trigger: trigger2)
        center.add(request2)

        // 5-day
        let body5 = RoastEngine.inactivityRoast(days: 5, context: context)
        let content5 = makeContent(title: "It's Been a While", body: body5)
        let trigger5 = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 24 * 60 * 60, repeats: false)
        let request5 = UNNotificationRequest(identifier: ID.inactivity5Day, content: content5, trigger: trigger5)
        center.add(request5)
    }

    func cancelInactivityRoasts() {
        cancel(ids: [ID.inactivity2Day, ID.inactivity5Day])
    }

    // MARK: - Post-Penalty Roast

    func schedulePostPenaltyRoast(apLost: Int, oldStreak: Int, missedHabits: [String], rank: String, intensity: RoastIntensity) {
        cancel(ids: [ID.postPenalty])

        let context = RoastContext(
            habitCount: 0, completedCount: 0, remainingCount: 0,
            habitNames: missedHabits, streak: 0, bestStreak: 0,
            rank: rank, consistency: 0, discipline: 0,
            apLost: apLost, oldStreak: oldStreak, intensity: intensity
        )

        let body = RoastEngine.penaltyRoast(context: context)
        let content = makeContent(title: "Aura Lost", body: body)

        // Fire in 5 seconds (immediate-ish, for when penalty is applied on foreground)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: ID.postPenalty, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Milestone

    func scheduleMilestoneNotification(streak: Int) {
        cancel(ids: [ID.streakMilestone])

        let body = RoastEngine.milestoneRoast(streak: streak)
        let content = makeContent(title: "Streak Milestone", body: body)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: ID.streakMilestone, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Cancel Helpers

    func cancelCompletionRoasts() {
        cancel(ids: [ID.eveningRoast, ID.streakDeath])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    private func cancel(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Content Builder

    private func makeContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }

    // MARK: - Debug: Fire Immediately

    func debugFireNotification(
        type: DebugNotificationType,
        context: RoastContext
    ) {
        let title: String
        let body: String

        switch type {
        case .morning:
            title = "Rise and Grind"
            body = RoastEngine.morningRoast(context: context)
        case .evening:
            title = "Unfinished Business"
            body = RoastEngine.eveningRoast(context: context)
        case .streakDeath:
            title = "Streak at Risk"
            body = RoastEngine.streakDeathRoast(context: context)
        case .inactivity2Day:
            title = "Where'd You Go?"
            body = RoastEngine.inactivityRoast(days: 2, context: context)
        case .inactivity5Day:
            title = "It's Been a While"
            body = RoastEngine.inactivityRoast(days: 5, context: context)
        case .penalty:
            title = "Aura Lost"
            body = RoastEngine.penaltyRoast(context: context)
        case .milestone7:
            title = "Streak Milestone"
            body = RoastEngine.milestoneRoast(streak: 7)
        case .milestone30:
            title = "Streak Milestone"
            body = RoastEngine.milestoneRoast(streak: 30)
        case .milestone365:
            title = "Streak Milestone"
            body = RoastEngine.milestoneRoast(streak: 365)
        }

        let content = makeContent(title: title, body: body)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "debug-\(type.rawValue)", content: content, trigger: trigger)
        center.add(request)
    }
}

// MARK: - Debug Notification Types

enum DebugNotificationType: String, CaseIterable, Identifiable {
    case morning = "Morning Roast"
    case evening = "Evening Roast"
    case streakDeath = "Streak Death Warning"
    case inactivity2Day = "Inactivity (2 Day)"
    case inactivity5Day = "Inactivity (5 Day)"
    case penalty = "Post-Penalty Roast"
    case milestone7 = "Milestone (7 days)"
    case milestone30 = "Milestone (30 days)"
    case milestone365 = "Milestone (365 days)"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .morning: "sunrise.fill"
        case .evening: "moon.fill"
        case .streakDeath: "flame.fill"
        case .inactivity2Day: "clock.badge.questionmark"
        case .inactivity5Day: "clock.badge.exclamationmark"
        case .penalty: "minus.circle.fill"
        case .milestone7: "star.fill"
        case .milestone30: "star.circle.fill"
        case .milestone365: "crown.fill"
        }
    }

    var color: String {
        switch self {
        case .morning: "FF6B35"
        case .evening: "7A5CFF"
        case .streakDeath: "FF3B30"
        case .inactivity2Day: "888888"
        case .inactivity5Day: "555555"
        case .penalty: "FF3B30"
        case .milestone7: "4ADE80"
        case .milestone30: "FFD700"
        case .milestone365: "B9F2FF"
        }
    }
}
