import SwiftUI

struct OB_FinalView: View {
    var vm: OnboardingViewModel
    let onComplete: () -> Void
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            // Extra glow layer
            AuraGlowBackground(
                levelInfo: LevelInfo(globalLevel: 1, tier: .wood, subLevel: 1, currentXP: 0, xpRequired: 100, totalXP: 0),
                intensity: 0.8
            )
            .opacity(glowPulse ? 0.8 : 0.4)

            VStack(spacing: 0) {
                Spacer()

                Text("YOUR JOURNEY")
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(.white)
                    .tracking(4)
                    .opacity(textOpacity)

                Text("BEGINS NOW")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(6)
                    .padding(.top, 4)
                    .opacity(textOpacity)

                Spacer()

                OnboardingNextButton(title: "Enter Aura", style: .filled) {
                    onComplete()
                }
                .opacity(buttonOpacity)

                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                textOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
                buttonOpacity = 1
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}
