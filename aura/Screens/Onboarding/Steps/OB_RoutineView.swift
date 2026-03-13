import SwiftUI

struct OB_RoutineView: View {
    var vm: OnboardingViewModel

    private let options = [
        "Very consistent",
        "Mostly consistent",
        "Hit or miss",
        "Rarely consistent",
        "No routine at all"
    ]

    var body: some View {
        OnboardingSingleSelectScreen(
            question: "How consistent is your daily routine?",
            options: options,
            selection: Binding(
                get: { vm.routineAnswer },
                set: { vm.routineAnswer = $0 }
            ),
            vm: vm
        )
    }
}

// MARK: - Reusable single-select screen
struct OnboardingSingleSelectScreen: View {
    let question: String
    let options: [String]
    @Binding var selection: Int?
    var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(question)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 30)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        OnboardingOptionCard(
                            index: index,
                            text: option,
                            isSelected: selection == index
                        ) {
                            selection = index
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
            }

            Spacer()

            OnboardingNextButton(
                title: "Next",
                isEnabled: selection != nil
            ) {
                vm.next()
            }
        }
    }
}
