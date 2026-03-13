import SwiftUI

@Observable
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 20

    // XP accumulator (motivational only, not persisted)
    var onboardingXP: Int = 0

    // MARK: - Answers
    var satisfactionAnswer: Int? = nil      // 0-4
    var lifeGoalAnswer: Int? = nil          // 0-4
    var distractionHours: Double = 10       // 0-40
    var selectedSymptoms: Set<String> = []
    var selectedQuitHabits: Set<String> = []
    var routineAnswer: Int? = nil           // 0-4
    var productivityAnswer: Int? = nil      // 0-4
    var sleepAnswer: Int? = nil             // 0-4
    var exerciseAnswer: Int? = nil          // 0-4

    // MARK: - Navigation
    var showProgressBar: Bool {
        currentStep >= 1 && currentStep <= 18
    }

    var showBackButton: Bool {
        currentStep >= 1 && currentStep <= 18
    }

    var showXPBadge: Bool {
        currentStep >= 1 && currentStep <= 18
    }

    func next() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func back() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func addXP(_ amount: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            onboardingXP += amount
        }
    }

    // MARK: - Computed Results
    var yearsLost: Int {
        // hoursPerWeek * 52 weeks * 50 years / 8760 hours per year
        let total = (distractionHours * 52.0 * 50.0) / 8760.0
        return max(1, Int(total.rounded()))
    }

    var impactAchievement: String {
        switch distractionHours {
        case 0..<8: return "read over 200 books"
        case 8..<15: return "learned a new language fluently"
        case 15..<25: return "written and published a book"
        case 25..<35: return "built a successful business"
        default: return "run 50 marathons"
        }
    }

    var disciplineScore: Int {
        // Weighted average of answers (higher = worse habits)
        let sat = Double(satisfactionAnswer ?? 2)       // 20%
        let routine = Double(routineAnswer ?? 2)         // 20%
        let prod = Double(productivityAnswer ?? 2)       // 20%
        let sleep = Double(sleepAnswer ?? 2)             // 15%
        let exercise = Double(exerciseAnswer ?? 2)       // 15%
        let distraction = min(distractionHours / 10.0, 4.0) // 10%, normalized 0-4

        let weighted = (sat * 0.20) + (routine * 0.20) + (prod * 0.20) +
                       (sleep * 0.15) + (exercise * 0.15) + (distraction * 0.10)

        let score = Int((weighted / 4.0) * 100.0)
        return min(max(score, 15), 85) // Clamp to 15-85% for dramatic effect
    }

    var scoreComparison: Int {
        // How much worse than "average"
        return max(10, disciplineScore - 12)
    }
}
