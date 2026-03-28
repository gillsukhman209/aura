import SwiftUI

struct RankView: View {
    @Environment(HabitManager.self) private var manager
    @State private var scoreAnimated: CGFloat = 0
    @State private var showRoadmap = false
    @State private var showAuraCheck = false
    #if DEBUG
    @AppStorage("showDebugPanel") private var showDebugPanel = false
    #endif

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60)
                .opacity(0.2)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("RANK")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .tracking(6)
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

                        Text(info.displayName.uppercased())
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .tracking(2)

                        Text("LEVEL \(info.globalLevel)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(2)

                        // XP progress bar
                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color(hex: "1A1A1A")).frame(height: 4)
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
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(info.color)
                        }

                        // Consistency score
                        let score = manager.consistencyScore
                        Text("CONSISTENCY: \(score)%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(2)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 16)

                    Rectangle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    // ── Aura Check button ──
                    Button { showAuraCheck = true } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .medium))
                            Text("Aura Check")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "B9F2FF"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "0A0A0A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "B9F2FF").opacity(0.2), lineWidth: 0.8)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    // ── Rank tier preview ──
                    Text("RANK TIERS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .tracking(3)

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
                                            .foregroundColor(Color(hex: "333333"))
                                    }
                                }

                                Text(tier.name.uppercased())
                                    .font(.system(size: 14, weight: isCurrentTier ? .black : .semibold))
                                    .foregroundColor(
                                        isCurrentTier ? .white :
                                        isUnlocked ? Color(hex: "888888") : Color(hex: "444444")
                                    )
                                    .tracking(1)

                                Spacer()

                                if isCurrentTier {
                                    Text("CURRENT")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(tier.color)
                                        .tracking(1)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule().fill(tier.color.opacity(0.15))
                                        )
                                }

                                Text("Lv \(tier.rawValue * 5 + 1)-\(tier.rawValue * 5 + 5)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(
                                        isCurrentTier ? tier.color :
                                        isUnlocked ? Color(hex: "666666") : Color(hex: "333333")
                                    )
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isCurrentTier ? tier.color.opacity(0.08) : Color(hex: "0A0A0A"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                isCurrentTier ? tier.color.opacity(0.3) : Color.white.opacity(0.04),
                                                lineWidth: isCurrentTier ? 1.5 : 0.5
                                            )
                                    )
                            )
                        }
                    }

                    // ── View All Levels button ──
                    Button { showRoadmap = true } label: {
                        HStack {
                            Image(systemName: "list.number")
                                .font(.system(size: 14, weight: .medium))
                            Text("View All Levels")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "888888"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "0A0A0A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    #if DEBUG
                    Button {
                        showDebugPanel.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "ladybug.fill")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.accentOrange)
                            Text("Debug Panel")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "C0C0C0"))
                            Spacer()
                            Text(showDebugPanel ? "ON" : "OFF")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(showDebugPanel ? AppTheme.accentGreen : Color(hex: "555555"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "0A0A0A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    #endif

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Analytics.screen("Rank")
            let info = manager.levelInfo
            let progress = CGFloat(info.currentXP) / CGFloat(max(1, info.xpRequired))
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                scoreAnimated = progress
            }
        }
        .fullScreenCover(isPresented: $showRoadmap) {
            LevelRoadmapView()
        }
        .fullScreenCover(isPresented: $showAuraCheck) {
            AuraCheckView()
        }
    }
}
