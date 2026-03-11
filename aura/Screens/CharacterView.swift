import SwiftUI

struct CharacterView: View {
    @Environment(HabitManager.self) private var manager
    @State private var showBonus = false
    @State private var bonusProgress: CGFloat = 0
    @State private var showCreateHabit = false
    @State private var showManageHabits = false

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 250)

            VStack(spacing: 0) {
                // ── App name + actions ──
                HStack {
                    Text("Aura")
                        .font(.custom("Georgia-Bold", size: 22))
                        .foregroundColor(AppTheme.textBright)
                        .shadow(color: AppTheme.ringGlow.opacity(0.3), radius: 8)
                    Spacer()

                    // ── Streak badge ──
                    if manager.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "FF4500"), AppTheme.accentOrange],
                                        startPoint: .bottom, endPoint: .top
                                    )
                                )
                            Text("\(manager.currentStreak)")
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(AppTheme.accentOrange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppTheme.accentOrange.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.accentOrange.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }

                    Button { showCreateHabit = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.gold)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // ── XP Ring ──
                XPRing(
                    level: manager.level,
                    currentXP: manager.currentLevelXP,
                    maxXP: manager.xpPerLevel
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
                        .shadow(color: AppTheme.textMuted.opacity(0.3), radius: 4)
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

                // ── Habit cards ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        if !manager.todaysHabits.isEmpty {
                            ForEach(manager.todaysHabits) { habit in
                                HabitCard(habit: habit)
                            }

                            // Manage Habits link
                            Button { showManageHabits = true } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 11, weight: .medium))
                                    Text("Manage Habits")
                                        .font(.system(size: 12, weight: .medium, design: .serif))
                                }
                                .foregroundColor(AppTheme.textMuted)
                                .padding(.top, 4)
                            }
                            .buttonStyle(.plain)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.system(size: 40, weight: .ultraLight))
                                    .foregroundColor(AppTheme.textSubtle)
                                Text("No habits yet")
                                    .font(.custom("Georgia", size: 14))
                                    .foregroundColor(AppTheme.textMuted)
                                Button { showCreateHabit = true } label: {
                                    Text("Create your first habit")
                                        .font(.system(size: 13, weight: .medium, design: .serif))
                                        .foregroundColor(AppTheme.tabActive)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppTheme.tabActive.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 30)
                        }

                        // Daily Completion Bonus
                        if manager.allTodayCompleted, !manager.todaysHabits.isEmpty {
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
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 70)
                }
            }
        }
        .onAppear {
            manager.refresh()
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) { bonusProgress = 1.0 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.2)) { showBonus = true }
        }
        .sheet(isPresented: $showCreateHabit) {
            CreateHabitView()
        }
        .fullScreenCover(isPresented: $showManageHabits) {
            HabitListView()
        }
        .safeAreaInset(edge: .bottom) {
            DebugDatePanel(manager: manager)
        }
    }
}

// MARK: - DEBUG: Date Control Panel (remove before release)

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
