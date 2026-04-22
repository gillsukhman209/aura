import SwiftUI
import Observation

/// Drives the first-launch tutorial that walks the user from the home screen
/// through the Create Habit flow. The user can skip at any point.
@Observable
final class TutorialCoordinator {
    static let shared = TutorialCoordinator()

    enum Step: Int, CaseIterable, Hashable, Comparable {
        case createHabitButton
        case habitName
        case habitIcon
        case habitType
        case numericTarget
        case difficulty
        case stat
        case schedule
        case createButton

        static func < (lhs: Step, rhs: Step) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    private let defaultsKey = "hasCompletedTutorial"

    var isActive: Bool = false
    var currentStep: Step = .createHabitButton

    private init() {}

    var hasCompleted: Bool {
        UserDefaults.standard.bool(forKey: defaultsKey)
    }

    /// Call after onboarding finishes. No-op if the user already completed or skipped.
    func startIfNeeded() {
        guard !hasCompleted else { return }
        currentStep = .createHabitButton
        isActive = true
    }

    /// Reset + replay (for debug button).
    func restart() {
        UserDefaults.standard.set(false, forKey: defaultsKey)
        currentStep = .createHabitButton
        isActive = true
    }

    func advance() {
        guard isActive else { return }
        if let next = Step(rawValue: currentStep.rawValue + 1) {
            withAnimation(.easeOut(duration: 0.25)) { currentStep = next }
        } else {
            complete()
        }
    }

    /// Jump to a specific step (used when the Create Habit sheet opens).
    func jump(to step: Step) {
        guard isActive else { return }
        guard step.rawValue >= currentStep.rawValue else { return }
        withAnimation(.easeOut(duration: 0.25)) { currentStep = step }
    }

    func skip() { complete() }

    func complete() {
        UserDefaults.standard.set(true, forKey: defaultsKey)
        withAnimation(.easeOut(duration: 0.3)) { isActive = false }
    }
}

// MARK: - Copy

extension TutorialCoordinator.Step {
    var title: String {
        switch self {
        case .createHabitButton: "Create your first habit"
        case .habitName:         "Name your habit"
        case .habitIcon:         "Pick an icon"
        case .habitType:         "Choose a habit type"
        case .numericTarget:     "Set your target"
        case .difficulty:        "Pick a difficulty"
        case .stat:              "What does it build?"
        case .schedule:          "Set your schedule"
        case .createButton:      "Create it"
        }
    }

    var body: String {
        switch self {
        case .createHabitButton:
            "Tap + to add a new habit."
        case .habitName:
            "Name it — like \"Gym\" or \"Read 20 pages\"."
        case .habitIcon:
            "Pick an icon for your habit."
        case .habitType:
            "Build — check off when done.\nQuit — avoid it each day.\nNumeric — track a value."
        case .numericTarget:
            "Enter your daily target and unit."
        case .difficulty:
            "Harder earns more aura.\nMinor 5 · Medium 15 · Major 30 AP."
        case .stat:
            "Choose the stat this habit levels up."
        case .schedule:
            "Daily, or pick specific days."
        case .createButton:
            "Tap Create — you're done."
        }
    }

    var primaryCTA: String {
        switch self {
        case .createHabitButton, .createButton: ""
        default: "Next"
        }
    }

    /// Steps where advancement requires the user to actually tap the highlighted UI element.
    var requiresUserAction: Bool {
        self == .createHabitButton || self == .createButton
    }
}
