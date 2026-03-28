import Foundation
import PostHog

enum Analytics {

    // MARK: - Screen Views

    static func screen(_ name: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.screen(name, properties: properties)
    }

    // MARK: - Events

    static func track(_ event: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.capture(event, properties: properties)
    }

    // MARK: - Onboarding

    static func onboardingStep(_ step: Int, name: String) {
        track("onboarding_step", properties: ["step": step, "step_name": name])
    }

    static func onboardingCompleted() {
        track("onboarding_completed")
    }

    static func onboardingSkipped() {
        track("onboarding_skipped")
    }

    // MARK: - Habits

    static func habitCreated(name: String, type: String, difficulty: String) {
        track("habit_created", properties: ["habit_name": name, "type": type, "difficulty": difficulty])
    }

    static func habitCompleted(name: String, type: String, streak: Int) {
        track("habit_completed", properties: ["habit_name": name, "type": type, "streak": streak])
    }

    static func habitRelapse(name: String) {
        track("habit_relapse", properties: ["habit_name": name])
    }

    static func habitDeleted(name: String) {
        track("habit_deleted", properties: ["habit_name": name])
    }

    // MARK: - Engagement

    static func tabSwitched(to tab: String) {
        track("tab_switched", properties: ["tab": tab])
    }

    static func levelUp(level: Int, rank: String) {
        track("level_up", properties: ["level": level, "rank": rank])
    }

    static func auraCheckViewed() {
        track("aura_check_viewed")
    }

    static func auraShared() {
        track("aura_shared")
    }

    static func reviewPromptShown() {
        track("review_prompt_shown")
    }

    static func reviewAccepted() {
        track("review_accepted")
    }

    static func reviewDismissed() {
        track("review_dismissed")
    }

    // MARK: - Paywall

    static func paywallTriggered(placement: String) {
        track("paywall_triggered", properties: ["placement": placement])
    }
}
