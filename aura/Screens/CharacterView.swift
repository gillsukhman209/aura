import SwiftUI

struct CharacterView: View {
    let quests = MockData.dailyQuests
    @State private var showBonus = false
    @State private var bonusProgress: CGFloat = 0

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 250)

            VStack(spacing: 0) {
                // ── App name top-left ──
                HStack {
                    Text("Aura")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(AppTheme.textBright)
                        .shadow(color: AppTheme.ringGlow.opacity(0.3), radius: 8)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // ── XP Ring ──
                XPRing(
                    level: MockData.level,
                    currentXP: MockData.currentXP,
                    maxXP: MockData.maxXP
                )
                .padding(.top, -8)

                // ── "Today's Quests" header ──
                HStack(spacing: 6) {
                    HStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, AppTheme.headerLine.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 0.5)
                        Diamond()
                            .fill(AppTheme.headerDiamond)
                            .frame(width: 3.5, height: 3.5)
                    }

                    Text("Today's Quests")
                        .font(.custom("Georgia-Italic", size: 14))
                        .foregroundColor(AppTheme.textMuted)
                        .fixedSize()

                    HStack(spacing: 0) {
                        Diamond()
                            .fill(AppTheme.headerDiamond)
                            .frame(width: 3.5, height: 3.5)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.headerLine.opacity(0.5), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 0.5)
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)

                // ── Quest cards ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(quests) { quest in
                            QuestCard(quest: quest)
                        }

                        // Daily Completion Bonus
                        HStack {
                            Text("Daily Completion Bonus")
                                .font(.system(size: 12, weight: .medium, design: .serif))
                                .foregroundColor(AppTheme.textMuted)
                            Spacer()
                            Text("+40")
                                .font(.system(size: 13, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.gold)

                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGreen.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.accentGreen)
                            }
                            .scaleEffect(showBonus ? 1 : 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.bgCard.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.gold.opacity(0.12), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 70)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) { bonusProgress = 1.0 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.2)) { showBonus = true }
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}
