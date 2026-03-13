import SwiftUI

struct OB_AchievementView: View {
    var vm: OnboardingViewModel
    @State private var cardScale: CGFloat = 0.5
    @State private var cardOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("The first step to change is self honesty.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Rank card
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Wood I")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("0 XP")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)

                Image("wood_rank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A3520"), Color(hex: "2A1A0E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 30)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .padding(.top, 30)

            // Achievement text
            VStack(spacing: 8) {
                Text("Your First Achievement Unlocked!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.bgCardBorder, lineWidth: 1)
                    )

                Text("Only 14.56% of users reach this rank.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSubtle)
            }
            .padding(.top, 20)
            .opacity(textOpacity)

            Spacer()

            OnboardingNextButton(title: "Collect") {
                vm.next()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                cardScale = 1
                cardOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                textOpacity = 1
            }
        }
    }
}
