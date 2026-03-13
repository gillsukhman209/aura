import SwiftUI

struct OB_ExerciseView: View {
    var vm: OnboardingViewModel

    private let options = [
        "5+ times",
        "3-4 times",
        "1-2 times",
        "Rarely",
        "Never"
    ]

    var body: some View {
        OnboardingSingleSelectScreen(
            question: "How often do you exercise per week?",
            options: options,
            selection: Binding(
                get: { vm.exerciseAnswer },
                set: { vm.exerciseAnswer = $0 }
            ),
            vm: vm
        )
    }
}
