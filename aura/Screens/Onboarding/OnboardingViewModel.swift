import SwiftUI

// MARK: - Suggested Habit (for starter plan)

struct SuggestedHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let type: HabitType
    let difficulty: Difficulty
    let stat: StatType
    let schedule: Schedule
    let targetValue: Double?
    let unit: String?
    let reason: String // Why this was suggested
    var isSelected: Bool = true

    init(name: String, icon: String, type: HabitType, difficulty: Difficulty, stat: StatType,
         schedule: Schedule = .daily, targetValue: Double? = nil, unit: String? = nil, reason: String) {
        self.name = name
        self.icon = icon
        self.type = type
        self.difficulty = difficulty
        self.stat = stat
        self.schedule = schedule
        self.targetValue = targetValue
        self.unit = unit
        self.reason = reason
    }
}

@Observable
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 21 // was 20, added starter plan step

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
        currentStep >= 1 && currentStep <= 19
    }

    var showBackButton: Bool {
        currentStep >= 1 && currentStep <= 19
    }

    var showXPBadge: Bool {
        currentStep >= 1 && currentStep <= 19
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

    // MARK: - Starter Plan

    /// Mutable list of suggested habits generated from onboarding answers.
    var starterHabits: [SuggestedHabit] = []

    /// Generate starter habits based on all collected onboarding data.
    func generateStarterPlan() {
        var habits: [SuggestedHabit] = []

        // 1. Quit habits — direct mapping from user selections
        let quitMap: [String: (name: String, icon: String, stat: StatType)] = [
            "Doom scrolling": ("No Doom Scrolling", "iphone.slash", .focus),
            "Vaping / Smoking": ("No Smoking", "nosign", .discipline),
            "Excessive drinking": ("No Alcohol", "wineglass.fill", .discipline),
            "Porn": ("No Porn", "eye.slash.fill", .discipline),
            "Junk food": ("Eat Clean", "leaf.fill", .energy),
            "Procrastinating": ("No Procrastinating", "clock.arrow.circlepath", .focus),
            "Staying up late": ("Sleep On Time", "moon.zzz.fill", .energy),
            "Negative self-talk": ("Positive Mindset", "brain.head.profile", .focus),
        ]

        for quitHabit in selectedQuitHabits {
            if let mapping = quitMap[quitHabit] {
                habits.append(SuggestedHabit(
                    name: mapping.name,
                    icon: mapping.icon,
                    type: .quit,
                    difficulty: .medium,
                    stat: mapping.stat,
                    reason: "You want to quit \(quitHabit.lowercased())"
                ))
            }
        }

        // 2. Exercise habit — if user exercises ≤ 1-2x/week
        if let exercise = exerciseAnswer, exercise >= 2 {
            habits.append(SuggestedHabit(
                name: "Exercise",
                icon: "dumbbell.fill",
                type: .build,
                difficulty: .major,
                stat: .strength,
                schedule: .specificDays(Set([.monday, .wednesday, .friday])),
                reason: "You said you rarely exercise"
            ))
        }

        // 3. Sleep habit — if sleep is average or worse
        if let sleep = sleepAnswer, sleep >= 2 {
            habits.append(SuggestedHabit(
                name: "Sleep 8 Hours",
                icon: "bed.double.fill",
                type: .build,
                difficulty: .medium,
                stat: .energy,
                reason: "Your sleep needs improvement"
            ))
        }

        // 4. Routine habit — if routine is inconsistent
        if let routine = routineAnswer, routine >= 2 {
            habits.append(SuggestedHabit(
                name: "Morning Routine",
                icon: "sunrise.fill",
                type: .build,
                difficulty: .medium,
                stat: .discipline,
                reason: "You need a consistent routine"
            ))
        }

        // 5. Reading/learning — if productivity is low or life goal is knowledge/career
        if (productivityAnswer ?? 2) >= 2 || lifeGoalAnswer == 0 || lifeGoalAnswer == 3 {
            habits.append(SuggestedHabit(
                name: "Read 20 Min",
                icon: "book.fill",
                type: .build,
                difficulty: .medium,
                stat: .knowledge,
                reason: "Reading builds knowledge and focus"
            ))
        }

        // 6. Meditation — if user has concentration or anxiety symptoms
        let mentalSymptoms: Set<String> = ["Difficulty concentrating", "General anxiety", "Feeling unmotivated"]
        if !selectedSymptoms.isDisjoint(with: mentalSymptoms) {
            habits.append(SuggestedHabit(
                name: "Meditate",
                icon: "brain.head.profile",
                type: .build,
                difficulty: .minor,
                stat: .focus,
                reason: "Helps with focus and anxiety"
            ))
        }

        // 7. Hydration — always a good starter habit if nothing else fills energy
        if !habits.contains(where: { $0.stat == .energy && $0.type == .build }) {
            habits.append(SuggestedHabit(
                name: "Drink Water",
                icon: "drop.fill",
                type: .build,
                difficulty: .minor,
                stat: .energy,
                targetValue: 3.0,
                unit: "L",
                reason: "Stay hydrated for better energy"
            ))
        }

        // 8. Journal — if user has fatigue or emotional symptoms
        let emotionalSymptoms: Set<String> = ["Social withdrawal", "Irritability", "Relationship strain", "Negative self-talk"]
        if !selectedSymptoms.isDisjoint(with: emotionalSymptoms) && !habits.contains(where: { $0.name == "Positive Mindset" }) {
            habits.append(SuggestedHabit(
                name: "Journal",
                icon: "pencil.line",
                type: .build,
                difficulty: .minor,
                stat: .discipline,
                reason: "Writing helps process emotions"
            ))
        }

        starterHabits = habits
    }

    func toggleHabit(_ habit: SuggestedHabit) {
        guard let index = starterHabits.firstIndex(where: { $0.id == habit.id }) else { return }
        starterHabits[index].isSelected.toggle()
    }

    var selectedStarterHabits: [SuggestedHabit] {
        starterHabits.filter(\.isSelected)
    }
}
