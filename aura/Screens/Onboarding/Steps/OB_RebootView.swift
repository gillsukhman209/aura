import SwiftUI

struct OB_RebootView: View {
    var vm: OnboardingViewModel
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.tabActive)
                .padding(.bottom, 30)

            Text("Ready to reboot your brain?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Text("You've been honest about where you are.\nNow let's build a plan to get you where you want to be.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 16)
                .opacity(textOpacity)

            Spacer()

            OnboardingNextButton(title: "Reboot my brain") {
                vm.next()
            }
            .opacity(buttonOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                buttonOpacity = 1
            }
        }
    }
}
