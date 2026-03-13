import SwiftUI

struct OB_ProductivityView: View {
    var vm: OnboardingViewModel

    private let options = [
        "Almost always",
        "Most of the time",
        "Sometimes",
        "Rarely",
        "Never"
    ]

    var body: some View {
        OnboardingSingleSelectScreen(
            question: "How often do you set goals and actually follow through?",
            options: options,
            selection: Binding(
                get: { vm.productivityAnswer },
                set: { vm.productivityAnswer = $0 }
            ),
            vm: vm
        )
    }
}
