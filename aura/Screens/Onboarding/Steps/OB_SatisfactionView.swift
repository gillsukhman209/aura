import SwiftUI

struct OB_SatisfactionView: View {
    var vm: OnboardingViewModel

    private let options = [
        "Things are going well",
        "I'm managing, but know I can do better",
        "I feel stuck and frustrated",
        "I'm running on empty",
        "I'm struggling and need a reset"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("How would you honestly describe where you're at right now?")
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
                            isSelected: vm.satisfactionAnswer == index
                        ) {
                            vm.satisfactionAnswer = index
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
            }

            Spacer()

            OnboardingNextButton(
                title: "Next",
                isEnabled: vm.satisfactionAnswer != nil
            ) {
                vm.next()
            }
        }
    }
}
