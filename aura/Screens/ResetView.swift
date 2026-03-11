import SwiftUI

struct ResetView: View {
    @State private var titleOpacity: Double = 0
    @State private var buttonVisible = false
    @State private var silhouetteOpacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "15151F").opacity(0.8), AppTheme.bgPure],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                Image(systemName: "figure.martial.arts")
                    .font(.system(size: 250, weight: .ultraLight))
                    .foregroundColor(AppTheme.bgCardBorder.opacity(0.6))
                    .offset(x: 60, y: -50)
                    .opacity(silhouetteOpacity)

                RadialGradient(
                    colors: [AppTheme.goldBright.opacity(0.03), .clear],
                    center: .init(x: 0.8, y: 0.1),
                    startRadius: 10, endRadius: 300
                )
                .ignoresSafeArea()
            }

            StarfieldBackground(starCount: 100)

            VStack(spacing: 0) {
                Spacer()
                Spacer()

                Text("RESET")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(12)
                    .opacity(titleOpacity)

                Text("For the bold.")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
                    .italic()
                    .padding(.top, 8)
                    .opacity(titleOpacity)

                Spacer()

                GlowingButton(title: "START OVER", style: .danger) {}
                    .padding(.horizontal, 40)
                    .opacity(buttonVisible ? 1 : 0)

                Spacer().frame(height: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { titleOpacity = 1; silhouetteOpacity = 1 }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) { buttonVisible = true }
        }
    }
}
