import SwiftUI

struct StreakView: View {
    @Environment(HabitManager.self) private var manager
    @State private var flameScale: CGFloat = 0.8
    @State private var flameGlow = false
    @State private var numberVisible = false

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            RadialGradient(
                colors: [AppTheme.accentOrange.opacity(0.06), .clear],
                center: .init(x: 0.5, y: 0.35),
                startRadius: 30, endRadius: 250
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                let streak = manager.currentStreak

                ZStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 120))
                        .foregroundColor(AppTheme.accentOrange.opacity(flameGlow ? 0.2 : 0.08))
                        .blur(radius: 25)
                        .scaleEffect(flameScale * 1.3)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FF4500"), AppTheme.accentOrange, AppTheme.goldBright],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .shadow(color: AppTheme.accentOrange.opacity(0.5), radius: 15)
                        .scaleEffect(flameScale)

                    Text("\(streak)")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                        .offset(y: -5)
                        .opacity(numberVisible ? 1 : 0)
                        .scaleEffect(numberVisible ? 1 : 0.5)
                }

                Text("DAYS")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .tracking(8)
                    .padding(.top, 16)

                VStack(spacing: 4) {
                    Text("If you complete all daily quests today,")
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .foregroundColor(AppTheme.textMuted)
                    HStack(spacing: 0) {
                        Text("STREAK BECOMES ")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.textMuted)
                        Text("\(streak + 1)")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(AppTheme.goldBright)
                    }
                }
                .padding(.top, 24)

                Spacer()
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { flameScale = 1.0 }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) { numberVisible = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { flameGlow = true }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) { flameScale = 1.04 }
        }
    }
}
