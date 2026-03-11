import SwiftUI

struct RankView: View {
    let ranks = MockData.ranks
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

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: "CD7F32").opacity(0.2),
                                            Color(hex: "CD7F32").opacity(0.05),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 50, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "CD7F32"), AppTheme.goldBright],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(hex: "CD7F32").opacity(0.5), radius: 10)
                        }

                        VStack(spacing: 8) {
                            Text("Consistency Score: \(MockData.consistencyScore) /100")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundColor(AppTheme.textMuted)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(AppTheme.barGroove).frame(height: 4)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "CD7F32"), AppTheme.goldBright],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: scoreAnimated * geo.size.width, height: 4)
                                        .shadow(color: Color(hex: "CD7F32").opacity(0.3), radius: 3)
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
                        ForEach(ranks) { rank in
                            RankCard(rank: rank)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                scoreAnimated = CGFloat(MockData.consistencyScore) / 100.0
            }
        }
    }
}
