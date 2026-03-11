import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("chart.bar.fill", "Progress"),
        ("person.text.rectangle", "Stats"),
        ("diamond.fill", "Rank"),
        ("person.fill", "Profile"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Content ──
            Group {
                switch selectedTab {
                case 0: CharacterView()
                case 1: WeeklyProgressView()
                case 2: CharacterStatsView()
                case 3: RankView()
                case 4: NavigationStack { MoreView() }
                default: CharacterView()
                }
            }

            // ── Tab bar ──
            VStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AppTheme.tabSeparator.opacity(0.4), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)

                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { i in
                        let active = selectedTab == i

                        Button {
                            withAnimation(.easeOut(duration: 0.12)) {
                                selectedTab = i
                            }
                        } label: {
                            VStack(spacing: 1.5) {
                                ZStack {
                                    if active {
                                        Circle()
                                            .fill(AppTheme.tabGlow.opacity(0.12))
                                            .frame(width: 24, height: 24)
                                            .blur(radius: 8)
                                    }

                                    Image(systemName: tabs[i].icon)
                                        .font(.system(size: 13, weight: active ? .medium : .light))
                                        .foregroundColor(
                                            active ? AppTheme.tabActive : AppTheme.tabInactive
                                        )
                                        .shadow(
                                            color: active ? AppTheme.tabGlow.opacity(0.4) : .clear,
                                            radius: 3
                                        )
                                }
                                .frame(height: 20)

                                Text(tabs[i].label)
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(
                                        active
                                            ? AppTheme.tabActive.opacity(0.85)
                                            : AppTheme.tabInactive.opacity(0.7)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 1)
            }
            .padding(.bottom, 20)
            .background(
                AppTheme.bgTabBar.opacity(0.97)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

// MARK: - Character Stats (moved from home to its own tab)
struct CharacterStatsView: View {
    let stats = MockData.stats

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 200)

            VStack(spacing: 0) {
                HStack {
                    Text("Aura")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(AppTheme.textBright)
                        .shadow(color: AppTheme.ringGlow.opacity(0.3), radius: 8)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // ── Header ──
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

                    Text("Character Stats")
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
                .padding(.top, 16)
                .padding(.bottom, 8)

                // ── Stats panel ──
                VStack(spacing: 0) {
                    ForEach(Array(stats.enumerated()), id: \.element.id) { i, stat in
                        StatBar(stat: stat, isLast: i == stats.count - 1)
                        if i < stats.count - 1 {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.bgCard.opacity(0.65),
                                    AppTheme.bgCard.opacity(0.55),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.bgCardBorder.opacity(0.4),
                                            AppTheme.bgCardBorder.opacity(0.2),
                                            AppTheme.bgCardBorder.opacity(0.3),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 12, y: 4)
                )
                .padding(.horizontal, 10)

                Spacer()
                    .frame(height: 62)
            }
        }
    }
}

// MARK: - Profile
struct MoreView: View {
    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 150)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    Text("P R O F I L E")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(AppTheme.textMuted)
                        .tracking(2)
                        .padding(.top, 14)

                    NavigationLink(destination: TrainingView()) {
                        ProfileMenuItem(icon: "flame.fill", title: "Training", color: AppTheme.accentOrange)
                    }
                    NavigationLink(destination: StreakView()) {
                        ProfileMenuItem(icon: "bolt.fill", title: "Streak", color: AppTheme.goldBright)
                    }
                    NavigationLink(destination: ResetView()) {
                        ProfileMenuItem(icon: "arrow.counterclockwise", title: "Reset", color: AppTheme.accentDanger)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.10))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.custom("Georgia", size: 14))
                .foregroundColor(AppTheme.textStat)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.tabInactive)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppTheme.bgCard.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.bgCardBorder.opacity(0.4), lineWidth: 0.5)
                )
        )
    }
}
