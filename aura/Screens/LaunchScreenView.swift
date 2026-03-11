import SwiftUI

struct LaunchScreenView: View {
    @Binding var showMain: Bool
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 250)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 4) {
                    Text("BUILD YOUR")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)

                    Text("CHARACTER")
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .tracking(6)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                Text("Your real-life RPG.")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
                    .italic()
                    .padding(.top, 14)
                    .opacity(subtitleOpacity)

                Spacer()

                GlowingButton(title: "BEGIN TRAINING", style: .outlined) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMain = true
                    }
                }
                .padding(.horizontal, 40)
                .opacity(buttonOpacity)

                Spacer()
                    .frame(height: 80)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                titleOpacity = 1
                titleOffset = 0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                subtitleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
                buttonOpacity = 1
            }
        }
    }
}
