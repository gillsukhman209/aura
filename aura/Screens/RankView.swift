import SwiftUI

struct RankView: View {
    @Environment(HabitManager.self) private var manager
    @State private var scoreAnimated: CGFloat = 0
    @State private var showRoadmap = false

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("RANK")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)
                        .padding(.top, 12)

                    // ── Current rank badge ──
                    let info = manager.levelInfo

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            info.color.opacity(0.2),
                                            info.color.opacity(0.05),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(info.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .shadow(color: info.color.opacity(0.5), radius: 10)
                        }

                        Text(info.displayName)
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("Level \(info.globalLevel)")
                            .font(.system(size: 13, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.textMuted)

                        // XP progress bar
                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(AppTheme.barGroove).frame(height: 4)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [info.color, info.color.opacity(0.6)],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: scoreAnimated * geo.size.width, height: 4)
                                        .shadow(color: info.color.opacity(0.3), radius: 3)
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 40)

                            Text("\(info.currentXP) / \(info.xpRequired) AP")
                                .font(.system(size: 12, weight: .medium, design: .serif))
                                .foregroundColor(info.color)
                        }

                        // Consistency score
                        let score = manager.consistencyScore
                        Text("Consistency: \(score)%")
                            .font(.system(size: 12, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 16)

                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, AppTheme.bgCardBorder, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 0.5)

                    // ── View All Levels button ──
                    Button { showRoadmap = true } label: {
                        HStack {
                            Image(systemName: "list.number")
                                .font(.system(size: 14, weight: .medium))
                            Text("View All Levels")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.bgCard.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.bgCardBorder.opacity(0.3), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, AppTheme.bgCardBorder, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 0.5)

                    // ── Rank tier preview ──
                    Text("RANK TIERS")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundColor(AppTheme.textMuted)
                        .tracking(2)

                    VStack(spacing: 6) {
                        ForEach(RankTier.allCases, id: \.rawValue) { tier in
                            let isCurrentTier = tier == manager.levelInfo.tier
                            let isUnlocked = tier.rawValue <= manager.levelInfo.tier.rawValue

                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(tier.color.opacity(isUnlocked ? 0.12 : 0.04))
                                        .frame(width: 48, height: 48)
                                    if isUnlocked {
                                        Image(tier.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSubtle)
                                    }
                                }

                                Text(tier.name)
                                    .font(.system(size: 15, weight: isCurrentTier ? .bold : .medium, design: .serif))
                                    .foregroundColor(
                                        isCurrentTier ? .white :
                                        isUnlocked ? AppTheme.textMuted : AppTheme.textSubtle
                                    )

                                Spacer()

                                if isCurrentTier {
                                    Text("CURRENT")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(tier.color)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule().fill(tier.color.opacity(0.15))
                                        )
                                }

                                Text("Lv \(tier.rawValue * 5 + 1)-\(tier.rawValue * 5 + 5)")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .foregroundColor(
                                        isCurrentTier ? tier.color :
                                        isUnlocked ? AppTheme.textMuted : AppTheme.textSubtle
                                    )
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isCurrentTier ? tier.color.opacity(0.08) : AppTheme.bgCard.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                isCurrentTier ? tier.color.opacity(0.3) : AppTheme.bgCardBorder.opacity(0.2),
                                                lineWidth: isCurrentTier ? 1.5 : 0.5
                                            )
                                    )
                            )
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            let info = manager.levelInfo
            let progress = CGFloat(info.currentXP) / CGFloat(max(1, info.xpRequired))
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                scoreAnimated = progress
            }
        }
        .fullScreenCover(isPresented: $showRoadmap) {
            LevelRoadmapView()
        }
    }
}
