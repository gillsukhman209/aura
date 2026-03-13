import SwiftUI

struct OB_LifeGoalView: View {
    var vm: OnboardingViewModel

    private let options: [(String, String)] = [
        ("briefcase.fill", "Career & Wealth"),
        ("figure.run", "Health & Fitness"),
        ("heart.fill", "Relationships"),
        ("book.fill", "Skills & Knowledge"),
        ("house.fill", "Family & Purpose")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("What's the #1 area you want to improve?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 30)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        Button {
                            vm.lifeGoalAnswer = index
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: option.0)
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.tabActive)
                                    .frame(width: 30)

                                Text(option.1)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(vm.lifeGoalAnswer == index ? AppTheme.tabActive.opacity(0.15) : AppTheme.bgCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                vm.lifeGoalAnswer == index ? AppTheme.tabActive.opacity(0.7) : AppTheme.tabActive.opacity(0.25),
                                                lineWidth: vm.lifeGoalAnswer == index ? 1.5 : 0.8
                                            )
                                    )
                            )
                            .shadow(color: vm.lifeGoalAnswer == index ? AppTheme.tabActive.opacity(0.2) : .clear, radius: 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
            }

            Spacer()

            OnboardingNextButton(
                title: "Next",
                isEnabled: vm.lifeGoalAnswer != nil
            ) {
                vm.next()
            }
        }
    }
}
