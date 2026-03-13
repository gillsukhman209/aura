import SwiftUI

struct StreakView: View {
    @Environment(HabitManager.self) private var manager
    @State private var flameScale: CGFloat = 0.8
    @State private var flameGlow = false
    @State private var numberVisible = false

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60)
                .opacity(0.2)

            VStack(spacing: 0) {
                Spacer()

                let streak = manager.currentStreak

                ZStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 120))
                        .foregroundColor(Color.white.opacity(flameGlow ? 0.12 : 0.04))
                        .blur(radius: 25)
                        .scaleEffect(flameScale * 1.3)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), Color.white.opacity(0.6), Color.white.opacity(0.3)],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .shadow(color: Color.white.opacity(0.2), radius: 15)
                        .scaleEffect(flameScale)

                    Text("\(streak)")
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                        .offset(y: -5)
                        .opacity(numberVisible ? 1 : 0)
                        .scaleEffect(numberVisible ? 1 : 0.5)
                }

                Text("DAYS")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .tracking(10)
                    .padding(.top, 16)

                VStack(spacing: 4) {
                    Text("If you complete all daily quests today,")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "555555"))
                    HStack(spacing: 0) {
                        Text("STREAK BECOMES ")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                        Text("\(streak + 1)")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
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
