import SwiftUI

struct OB_SleepView: View {
    var vm: OnboardingViewModel

    private let options = [
        "Excellent",
        "Good",
        "Average",
        "Poor",
        "Terrible"
    ]

    var body: some View {
        OnboardingSingleSelectScreen(
            question: "How would you rate your sleep quality?",
            options: options,
            selection: Binding(
                get: { vm.sleepAnswer },
                set: { vm.sleepAnswer = $0 }
            ),
            vm: vm
        )
    }
}
