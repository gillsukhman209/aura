import SwiftUI

struct LevelRoadmapView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60)
                .opacity(0.2)

            VStack(spacing: 0) {
                // ── Header ──
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: "111111")))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("LEVELS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(4)

                    Spacer()

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

                    Text(info.displayName.uppercased())
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("\(info.currentXP) / \(info.xpRequired) AP")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(info.color)
                }
                .padding(.bottom, 16)

                Rectangle()
                    .fill(Color(hex: "1A1A1A"))
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
                        .foregroundColor(Color(hex: "333333"))
                }
            }

            // Level name
            VStack(alignment: .leading, spacing: 2) {
                Text("LEVEL \(level.globalLevel)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(
                        level.isCurrent ? level.tier.color :
                        level.isCompleted ? Color(hex: "666666") : Color(hex: "333333")
                    )
                    .tracking(1)
                Text(level.displayName.uppercased())
                    .font(.system(size: 14, weight: level.isCurrent ? .black : .semibold))
                    .foregroundColor(
                        level.isCurrent ? .white :
                        level.isCompleted ? Color(hex: "666666") : Color(hex: "333333")
                    )
                    .tracking(1)
            }

            Spacer()

            // XP info
            if level.isCurrent {
                Text("\(level.currentXPInLevel)/\(level.xpRequired)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(level.tier.color)
                + Text(" AP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(level.tier.color.opacity(0.7))
            } else if level.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.accentGreen)
            } else {
                Text("0/\(level.xpRequired)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                + Text(" AP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "333333").opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(level.isCurrent ? level.tier.color.opacity(0.08) : Color(hex: "0A0A0A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            level.isCurrent ? level.tier.color.opacity(0.3) : Color.white.opacity(0.04),
                            lineWidth: level.isCurrent ? 1.5 : 0.5
                        )
                )
        )
    }
}
