import SwiftUI

struct LevelRoadmapView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            VStack(spacing: 0) {
                // ── Header ──
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppTheme.bgCard))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("LEVELS")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)

                    Spacer()

                    // Balance the X button
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // ── Current rank badge ──
                let info = manager.levelInfo
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [info.color.opacity(0.2), info.color.opacity(0.05), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(info.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .shadow(color: info.color.opacity(0.5), radius: 8)
                    }

                    Text(info.displayName)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("\(info.currentXP) / \(info.xpRequired) AP")
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(info.color)
                }
                .padding(.bottom, 16)

                Rectangle()
                    .fill(LinearGradient(colors: [.clear, AppTheme.bgCardBorder, .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 0.5)

                // ── Level list ──
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 6) {
                            ForEach(manager.roadmapLevels) { level in
                                RoadmapRow(level: level)
                                    .id(level.globalLevel)
                            }
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                    .onAppear {
                        // Scroll to current level
                        let currentLevel = info.globalLevel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo(currentLevel, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Roadmap Row

struct RoadmapRow: View {
    let level: RoadmapLevel

    var body: some View {
        HStack(spacing: 14) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(level.tier.color.opacity(level.isCompleted || level.isCurrent ? 0.12 : 0.04))
                    .frame(width: 50, height: 50)

                if level.isCompleted || level.isCurrent {
                    Image(level.tier.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSubtle)
                }
            }

            // Level name
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(level.globalLevel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(
                        level.isCurrent ? level.tier.color :
                        level.isCompleted ? AppTheme.textMuted : AppTheme.textSubtle
                    )
                Text(level.displayName)
                    .font(.system(size: 15, weight: level.isCurrent ? .bold : .medium, design: .serif))
                    .foregroundColor(
                        level.isCurrent ? .white :
                        level.isCompleted ? AppTheme.textMuted : AppTheme.textSubtle
                    )
            }

            Spacer()

            // XP info
            if level.isCurrent {
                Text("\(level.currentXPInLevel)/\(level.xpRequired)")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(level.tier.color)
                + Text(" AP")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundColor(level.tier.color.opacity(0.7))
            } else if level.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.accentGreen)
            } else {
                Text("0/\(level.xpRequired)")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textSubtle)
                + Text(" AP")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textSubtle.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(level.isCurrent ? level.tier.color.opacity(0.08) : AppTheme.bgCard.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            level.isCurrent ? level.tier.color.opacity(0.3) : AppTheme.bgCardBorder.opacity(0.2),
                            lineWidth: level.isCurrent ? 1.5 : 0.5
                        )
                )
        )
    }
}
