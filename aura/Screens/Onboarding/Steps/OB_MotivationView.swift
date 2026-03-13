import SwiftUI

struct OB_MotivationView: View {
    var vm: OnboardingViewModel
    @State private var quoteOpacity: Double = 0
    @State private var authorOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("\"The best time to plant a tree was 20 years ago. The second best time is now.\"")
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(quoteOpacity)

            Text("— Chinese Proverb")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(AppTheme.textMuted)
                .italic()
                .padding(.top, 16)
                .opacity(authorOpacity)

            Spacer()

            OnboardingNextButton(title: "Continue") {
                vm.next()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                quoteOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                authorOpacity = 1
            }
        }
    }
}
