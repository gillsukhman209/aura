import SwiftUI
import SuperwallKit

struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("chart.bar.fill", "Stats"),
        ("diamond.fill", "Rank"),
        ("person.fill", "Profile"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Content ──
            Group {
                switch selectedTab {
                case 0: CharacterView()
                case 1: StatsView()
                case 2: RankView()
                case 3: NavigationStack { MoreView() }
                default: CharacterView()
                }
            }

            // ── Tab bar ──
            VStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.06), .clear],
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
                                Image(systemName: tabs[i].icon)
                                    .font(.system(size: 13, weight: active ? .semibold : .light))
                                    .foregroundColor(
                                        active ? .white : Color(hex: "3A3A3A")
                                    )
                                .frame(height: 20)

                                Text(tabs[i].label)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(
                                        active ? .white.opacity(0.7) : Color(hex: "3A3A3A").opacity(0.7)
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
                Color(hex: "050505").opacity(0.97)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

// MARK: - Combined Stats View
struct StatsView: View {
    @Environment(HabitManager.self) private var manager
    @State private var animateValues = false

    private var stats: [DisplayStat] { manager.characterStats }

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60)
                .opacity(0.2)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // ── Level progress ──
                    let info = manager.levelInfo
                    VStack(spacing: 4) {
                        Text(info.displayName.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(info.color)
                            .tracking(3)

                        Text("LEVEL \(info.globalLevel)")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.white)

                        GeometryReader { geo in
                            let progress = CGFloat(manager.currentLevelXP) / CGFloat(max(1, manager.xpPerLevel))
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(hex: "1A1A1A")).frame(height: 5)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [info.color, info.color.opacity(0.6)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: animateValues ? geo.size.width * progress : 0, height: 5)
                                    .shadow(color: info.color.opacity(0.4), radius: 4)
                            }
                        }
                        .frame(height: 5)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)

                        Text("\(manager.currentLevelXP) / \(manager.xpPerLevel) AP")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(info.color)
                            .padding(.top, 4)
                    }
                    .padding(.top, 12)

                    // ── Divider ──
                    Rectangle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    // ── Weekly XP Bar Chart ──
                    WeeklyXPChart(data: manager.weeklyXPPerDay, animate: animateValues)

                    // ── Divider ──
                    Rectangle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    // ── Character Stats header ──
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color(hex: "1A1A1A"))
                            .frame(height: 0.5)
                        Text("STATS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(4)
                            .fixedSize()
                        Rectangle()
                            .fill(Color(hex: "1A1A1A"))
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal, 20)

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
                            .fill(Color(hex: "0A0A0A"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                            )
                    )
                    .padding(.horizontal, 10)

                    // ── Divider ──
                    Rectangle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    // ── Weekly XP Progress ──
                    HStack {
                        Text("AURA GAINED THIS WEEK")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(3)
                    }

                    let progress = manager.weeklyProgress
                    if progress.isEmpty {
                        Text("Complete habits to see weekly progress")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "555555"))
                            .padding(.top, 4)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(progress) { stat in
                                HStack(spacing: 12) {
                                    Image(systemName: stat.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(stat.color)
                                        .frame(width: 24)
                                    Text(stat.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "C0C0C0"))
                                    Spacer()
                                    Text("+\(animateValues ? stat.xpGained : 0)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .contentTransition(.numericText())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "0A0A0A"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 10)
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) { animateValues = true }
        }
    }
}

// MARK: - Profile
struct MoreView: View {
    @State private var showAuraCheck = false
    @AppStorage("showDebugPanel") private var showDebugPanel = false

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60)
                .opacity(0.2)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    Text("PROFILE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .tracking(4)
                        .padding(.top, 14)

                    Button { showAuraCheck = true } label: {
                        ProfileMenuItem(icon: "sparkles", title: "Aura Check", color: Color(hex: "B9F2FF"))
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: StreakView()) {
                        ProfileMenuItem(icon: "bolt.fill", title: "Streak", color: AppTheme.accentOrange)
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        ProfileMenuItem(icon: "bell.fill", title: "Notifications", color: AppTheme.accentOrange)
                    }

                    NavigationLink(destination: ResetView()) {
                        ProfileMenuItem(icon: "arrow.counterclockwise", title: "Reset", color: AppTheme.accentDanger)
                    }

                    // Test Superwall paywall
                    #if DEBUG
                    Button {
                        Superwall.shared.register(placement: "campaign_trigger")
                    } label: {
                        ProfileMenuItem(icon: "creditcard.fill", title: "Test Paywall", color: AppTheme.accentPurple)
                    }
                    .buttonStyle(.plain)
                    #endif

                    // Debug toggle
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDebugPanel.toggle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentOrange.opacity(0.10))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "ladybug.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.accentOrange)
                            }
                            Text("Debug Panel")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "C0C0C0"))
                            Spacer()
                            Text(showDebugPanel ? "ON" : "OFF")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(showDebugPanel ? AppTheme.accentGreen : Color(hex: "555555"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(showDebugPanel ? AppTheme.accentGreen.opacity(0.1) : Color(hex: "1A1A1A"))
                                )
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "0A0A0A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .fullScreenCover(isPresented: $showAuraCheck) {
                    AuraCheckView()
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "C0C0C0"))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "3A3A3A"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "0A0A0A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )
        )
    }
}
