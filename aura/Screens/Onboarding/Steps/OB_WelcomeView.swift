import SwiftUI

struct OB_WelcomeView: View {
    var vm: OnboardingViewModel
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            VStack(spacing: 4) {
                Text("AURA")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(8)
            }
            .opacity(titleOpacity)

            // Tagline
            HStack(spacing: 0) {
                Text("Turn your life into ")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                Text("a game")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.accentPurple)
            }
            .padding(.top, 16)
            .opacity(subtitleOpacity)

            Spacer()

            // Start button
            OnboardingNextButton(title: "Start Journey", style: .white) {
                vm.next()
            }
            .opacity(buttonOpacity)

            Spacer()
                .frame(height: 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                subtitleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                buttonOpacity = 1
            }
        }
    }
}
