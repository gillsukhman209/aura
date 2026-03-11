import SwiftUI

struct RankView: View {
    @Environment(HabitManager.self) private var manager: HabitManager?
    @State private var scoreAnimated: CGFloat = 0

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("RANKS")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)
                        .padding(.top, 12)

                    let currentRank = manager?.currentRank ?? AuraRank.ranks[0]

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: currentRank.color).opacity(0.2),
                                            Color(hex: currentRank.color).opacity(0.05),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(systemName: currentRank.icon)
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: currentRank.color), AppTheme.goldBright],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(hex: currentRank.color).opacity(0.5), radius: 10)
                        }

                        let score = manager?.consistencyScore ?? 0

                        VStack(spacing: 8) {
                            Text("Consistency Score: \(score) /100")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundColor(AppTheme.textMuted)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(AppTheme.barGroove).frame(height: 4)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: currentRank.color), AppTheme.goldBright],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: scoreAnimated * geo.size.width, height: 4)
                                        .shadow(color: Color(hex: currentRank.color).opacity(0.3), radius: 3)
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical, 16)

                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, AppTheme.bgCardBorder, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 0.5)

                    VStack(spacing: 8) {
                        ForEach(manager?.displayRanks ?? []) { rank in
                            RankCard(rank: rank)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            let score = manager?.consistencyScore ?? 0
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                scoreAnimated = CGFloat(score) / 100.0
            }
        }
    }
}
