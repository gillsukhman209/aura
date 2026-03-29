import SwiftUI

struct CharacterView: View {
    @Environment(HabitManager.self) private var manager
    @AppStorage("showDebugPanel") private var showDebugPanel = false
    @State private var showBonus = false
    @State private var showCreateHabit = false
    @State private var showDailyBonusOverlay = false
    @State private var wasBonusAwarded = false
    @State private var headerOpacity: Double = 0
    @State private var cardsOpacity: Double = 0

    var body: some View {
        ZStack {
            // ── Pure black base ──
            Color(hex: "050505").ignoresSafeArea()

            // ── Subtle starfield (fewer, dimmer) ──
            StarfieldBackground(starCount: 80)
                .opacity(0.25)

            VStack(spacing: 0) {
                // ══════════════════════════════════════
                // HEADER
                // ══════════════════════════════════════
                HStack(alignment: .center) {
                    Text("AURA")
                        .font(.system(size: 24, weight: .black))
                        .tracking(6)
                        .foregroundColor(.white)

                    Spacer()

                    if manager.currentStreak > 0 {
                        HStack(spacing: 5) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.accentOrange)
                            Text("\(manager.currentStreak)")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(AppTheme.accentOrange.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.accentOrange.opacity(0.25), lineWidth: 0.5)
                                )
                        )
                        .shadow(color: AppTheme.accentOrange.opacity(0.3), radius: 8)
                    }

                    Button { showCreateHabit = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.07))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .opacity(headerOpacity)

                // ══════════════════════════════════════
                // XP RING
                // ══════════════════════════════════════
                XPRing(
                    levelInfo: manager.levelInfo,
                    currentXP: manager.currentLevelXP,
                    maxXP: manager.xpPerLevel
                )
                .padding(.top, -12)

                // ══════════════════════════════════════
                // RANK + LEVEL
                // ══════════════════════════════════════
                VStack(spacing: 4) {
                    Text("LEVEL \(manager.level)")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(4)
                        .foregroundColor(Color(hex: "555555"))

                    Text(manager.levelInfo.displayName.uppercased())
                        .font(.system(size: 20, weight: .black))
                        .tracking(3)
                        .foregroundColor(manager.levelInfo.color)
                }
                .padding(.top, -12)
                .padding(.bottom, 6)
                .opacity(headerOpacity)

                // ══════════════════════════════════════
                // SECTION DIVIDER
                // ══════════════════════════════════════
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, Color(hex: "2A2A2A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)

                    Text("DAILY")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(4)
                        .foregroundColor(Color(hex: "555555"))
                        .fixedSize()

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2A2A2A"), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .opacity(headerOpacity)

                // ══════════════════════════════════════
                // PROGRESS COUNTER
                // ══════════════════════════════════════
                HStack {
                    let total = manager.todaysHabits.count
                    let done = manager.completedTodayCount

                    Text("\(done)/\(total)")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.white)

                    Text("COMPLETED")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(hex: "555555"))

                    Spacer()

                    if total > 0 {
                        GeometryReader { geo in
                            let frac = total > 0 ? CGFloat(done) / CGFloat(total) : 0
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(hex: "1A1A1A"))
                                    .frame(height: 3)
                                Capsule()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: geo.size.width * frac, height: 3)
                            }
                        }
                        .frame(width: 60, height: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .opacity(cardsOpacity)

                // ══════════════════════════════════════
                // HABIT CARDS
                // ══════════════════════════════════════
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 6) {
                        if !manager.todaysHabits.isEmpty {
                            ForEach(manager.todaysHabits) { habit in
                                HabitCard(habit: habit)
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 36, weight: .ultraLight))
                                    .foregroundColor(Color(hex: "333333"))
                                Text("NO HABITS YET")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(3)
                                    .foregroundColor(Color(hex: "555555"))
                                Button { showCreateHabit = true } label: {
                                    Text("CREATE HABIT")
                                        .font(.system(size: 11, weight: .heavy))
                                        .tracking(2)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.07))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 40)
                        }

                        // Daily Completion Bonus
                        if manager.allTodayCompleted, !manager.todaysHabits.isEmpty {
                            HStack {
                                Text("DAILY BONUS")
                                    .font(.system(size: 11, weight: .heavy))
                                    .tracking(2)
                                    .foregroundColor(Color(hex: "555555"))
                                Spacer()
                                Text("+40")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)

                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(showBonus ? 1 : 0)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "0A0A0A"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 70)
                    .opacity(cardsOpacity)
                }
            }
        }
        .onAppear {
            Analytics.screen("Home")
            manager.refresh()
            wasBonusAwarded = manager.dailyBonusAwarded
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { headerOpacity = 1 }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) { cardsOpacity = 1 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.2)) { showBonus = true }
        }
        .onChange(of: manager.dailyBonusAwarded) { oldVal, newVal in
            if !wasBonusAwarded && newVal {
                showDailyBonusOverlay = true
                wasBonusAwarded = true
            } else if !newVal {
                wasBonusAwarded = false
            }
        }
        .sheet(isPresented: $showCreateHabit) {
            CreateHabitView()
        }
/*  DEBUG DISABLED FOR TESTING
        .safeAreaInset(edge: .bottom) {
            if showDebugPanel {
                DebugDatePanel(manager: manager)
            }
        }
*/
        .overlay {
            if manager.showLevelUpCelebration, let info = manager.celebrationLevelInfo {
                LevelUpOverlay(levelInfo: info) {
                    manager.dismissLevelUp()
                }
            }
        }
        .overlay {
            if showDailyBonusOverlay {
                DailyBonusOverlay {
                    showDailyBonusOverlay = false
                }
            }
        }
        .overlay {
            if manager.showAuraLost {
                AuraLostOverlay(amount: manager.auraLostAmount) {
                    manager.dismissAuraLost()
                }
            }
        }
    }
}

// MARK: - DEBUG: Date Control Panel

struct DebugDatePanel: View {
    let manager: HabitManager
    private var debug: DebugDate { DebugDate.shared }

    var body: some View {
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEE, MMM d"
            return f
        }()

        HStack(spacing: 14) {
            Button {
                debug.back()
                manager.performDayReset()
                manager.refresh()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.textBright)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AppTheme.bgCardBorder))
            }
            .buttonStyle(.plain)

            VStack(spacing: 1) {
                Text(dateFormatter.string(from: appNow()))
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(AppTheme.textBright)
                if debug.dayOffset != 0 {
                    Text("(\(debug.dayOffset > 0 ? "+" : "")\(debug.dayOffset)d)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(AppTheme.accentOrange)
                }
            }

            Button {
                debug.forward()
                manager.performDayReset()
                manager.refresh()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.textBright)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AppTheme.bgCardBorder))
            }
            .buttonStyle(.plain)

            if debug.dayOffset != 0 {
                Button {
                    debug.reset()
                    manager.performDayReset()
                    manager.refresh()
                } label: {
                    Text("Reset")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.accentDanger)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(AppTheme.accentDanger.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }

            Button {
                manager.debugAddXP(500)
            } label: {
                Text("+500 AP")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.accentGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(AppTheme.accentGreen.opacity(0.1)))
            }
            .buttonStyle(.plain)

            Button {
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            } label: {
                Text("Redo Onboarding")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.accentPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(AppTheme.accentPurple.opacity(0.1)))
            }
            .buttonStyle(.plain)

            Button {
                manager.seedMockData()
            } label: {
                Text("Seed Data")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.statBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(AppTheme.statBlue.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.bgCard.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.accentOrange.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, y: -2)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 72)
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
