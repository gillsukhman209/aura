import SwiftUI

struct OB_QuitHabitsView: View {
    var vm: OnboardingViewModel

    private let habits: [(String, String)] = [
        ("iphone.gen3", "Doom scrolling"),
        ("smoke.fill", "Vaping / Smoking"),
        ("wineglass.fill", "Excessive drinking"),
        ("eye.slash.fill", "Porn"),
        ("fork.knife", "Junk food"),
        ("clock.arrow.circlepath", "Procrastinating"),
        ("moon.fill", "Staying up late"),
        ("bubble.left.fill", "Negative self-talk")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Which habits are holding you back?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 30)

            Text("Select all that apply")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(habits, id: \.1) { icon, name in
                        let isSelected = vm.selectedQuitHabits.contains(name)
                        Button {
                            if isSelected {
                                vm.selectedQuitHabits.remove(name)
                            } else {
                                vm.selectedQuitHabits.insert(name)
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(isSelected ? AppTheme.tabActive : AppTheme.textMuted)

                                Text(name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? AppTheme.tabActive.opacity(0.12) : AppTheme.bgCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                isSelected ? AppTheme.tabActive.opacity(0.6) : AppTheme.bgCardBorder,
                                                lineWidth: isSelected ? 1.5 : 0.8
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            Spacer()

            OnboardingNextButton(
                title: "Next",
                isEnabled: !vm.selectedQuitHabits.isEmpty
            ) {
                vm.next()
            }
        }
    }
}
