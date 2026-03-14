import SwiftUI

struct NotificationSettingsView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("morningRoastHour") private var morningHour = 9
    @AppStorage("morningRoastMinute") private var morningMinute = 0
    @AppStorage("eveningRoastHour") private var eveningHour = 20
    @AppStorage("eveningRoastMinute") private var eveningMinute = 0
    @AppStorage("roastIntensity") private var intensityRaw = RoastIntensity.brutal.rawValue
    @AppStorage("inactivityRoasts") private var inactivityEnabled = true
    @AppStorage("showDebugPanel") private var showDebugPanel = false

    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    @State private var lastFiredDebug: String?

    private var intensity: RoastIntensity {
        RoastIntensity(rawValue: intensityRaw) ?? .brutal
    }

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // ── Header ──
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(hex: "111111")))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("NOTIFICATIONS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(4)

                        Spacer()

                        Color.clear.frame(width: 32, height: 32)
                    }
                    .padding(.top, 8)

                    // ── Master Toggle ──
                    settingCard {
                        Toggle(isOn: $notificationsEnabled) {
                            settingRow(
                                icon: "bell.fill",
                                color: AppTheme.accentOrange,
                                title: "Roast Notifications",
                                subtitle: "Harsh reminders to keep you on track"
                            )
                        }
                        .tint(AppTheme.accentGreen)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                NotificationService.shared.requestPermission()
                            }
                            reschedule()
                        }
                    }

                    if notificationsEnabled {
                        // ── Intensity ──
                        settingCard {
                            VStack(alignment: .leading, spacing: 12) {
                                settingRow(
                                    icon: "flame.fill",
                                    color: AppTheme.accentDanger,
                                    title: "Roast Intensity",
                                    subtitle: intensity.description
                                )

                                HStack(spacing: 8) {
                                    ForEach(RoastIntensity.allCases) { level in
                                        let selected = intensity == level
                                        Button {
                                            intensityRaw = level.rawValue
                                            reschedule()
                                        } label: {
                                            Text(level.label.uppercased())
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(selected ? .white : Color(hex: "555555"))
                                                .tracking(1)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(selected ? intensityColor(level).opacity(0.2) : Color(hex: "111111"))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(selected ? intensityColor(level).opacity(0.4) : Color.clear, lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // ── Schedule ──
                        settingCard {
                            VStack(spacing: 14) {
                                HStack {
                                    settingRow(
                                        icon: "sunrise.fill",
                                        color: Color(hex: "FF6B35"),
                                        title: "Morning Roast",
                                        subtitle: nil
                                    )
                                    Spacer()
                                    DatePicker("", selection: $morningTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .onChange(of: morningTime) { _, newValue in
                                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                            morningHour = comps.hour ?? 9
                                            morningMinute = comps.minute ?? 0
                                            reschedule()
                                        }
                                }

                                Rectangle()
                                    .fill(Color(hex: "1A1A1A"))
                                    .frame(height: 0.5)

                                HStack {
                                    settingRow(
                                        icon: "moon.fill",
                                        color: AppTheme.accentPurple,
                                        title: "Evening Roast",
                                        subtitle: nil
                                    )
                                    Spacer()
                                    DatePicker("", selection: $eveningTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .onChange(of: eveningTime) { _, newValue in
                                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                            eveningHour = comps.hour ?? 20
                                            eveningMinute = comps.minute ?? 0
                                            reschedule()
                                        }
                                }
                            }
                        }

                        // ── Inactivity ──
                        settingCard {
                            Toggle(isOn: $inactivityEnabled) {
                                settingRow(
                                    icon: "clock.badge.questionmark",
                                    color: Color(hex: "888888"),
                                    title: "Inactivity Roasts",
                                    subtitle: "Roast you after 2 and 5 days of absence"
                                )
                            }
                            .tint(AppTheme.accentGreen)
                            .onChange(of: inactivityEnabled) { _, _ in
                                reschedule()
                            }
                        }

                        // ── Debug Panel ──
                        if showDebugPanel {
                            debugPanel
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            morningTime = timeFromComponents(hour: morningHour, minute: morningMinute)
            eveningTime = timeFromComponents(hour: eveningHour, minute: eveningMinute)
        }
    }

    // MARK: - Debug Panel

    private var debugPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.accentOrange)
                Text("DEBUG — TEST NOTIFICATIONS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.accentOrange)
                    .tracking(2)
            }
            .padding(.bottom, 4)

            Text("Tap to fire a test notification in 2 seconds. Minimize the app to see it.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "555555"))

            ForEach(DebugNotificationType.allCases) { type in
                Button {
                    fireDebugNotification(type)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: type.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: type.color))
                            .frame(width: 24)

                        Text(type.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "C0C0C0"))

                        Spacer()

                        if lastFiredDebug == type.rawValue {
                            Text("SENT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(AppTheme.accentGreen)
                                .tracking(1)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "333333"))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "111111"))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0A0A0A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.accentOrange.opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Helpers

    private func settingCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0A0A0A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                )
        )
    }

    private func settingRow(icon: String, color: Color, title: String, subtitle: String?) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "E0E0E0"))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "555555"))
                }
            }
        }
    }

    private func intensityColor(_ level: RoastIntensity) -> Color {
        switch level {
        case .mild: AppTheme.accentGreen
        case .brutal: AppTheme.accentOrange
        case .unhinged: AppTheme.accentDanger
        }
    }

    private func timeFromComponents(hour: Int, minute: Int) -> Date {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func buildContext() -> RoastContext {
        let today = appNow()
        let todaysHabits = manager.todaysHabits
        let incompleteNames = todaysHabits.filter { !$0.isCompleted(on: today) }.map(\.name)

        return RoastContext(
            habitCount: todaysHabits.count,
            completedCount: manager.completedTodayCount,
            remainingCount: todaysHabits.count - manager.completedTodayCount,
            habitNames: incompleteNames,
            streak: manager.currentStreak,
            bestStreak: manager.longestStreak,
            rank: manager.levelInfo.displayName,
            consistency: manager.consistencyScore,
            discipline: manager.statValue(for: .discipline),
            apLost: 20,
            oldStreak: max(manager.longestStreak, 5),
            intensity: intensity
        )
    }

    private func fireDebugNotification(_ type: DebugNotificationType) {
        let context = buildContext()
        NotificationService.shared.debugFireNotification(type: type, context: context)
        lastFiredDebug = type.rawValue

        // Reset "SENT" label after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if lastFiredDebug == type.rawValue {
                lastFiredDebug = nil
            }
        }
    }

    private func reschedule() {
        let today = appNow()
        let todaysHabits = manager.todaysHabits
        let incompleteNames = todaysHabits.filter { !$0.isCompleted(on: today) }.map(\.name)

        NotificationService.shared.rescheduleAll(
            habitCount: todaysHabits.count,
            completedCount: manager.completedTodayCount,
            habitNames: incompleteNames,
            streak: manager.currentStreak,
            bestStreak: manager.longestStreak,
            rank: manager.levelInfo.displayName,
            consistency: manager.consistencyScore,
            discipline: manager.statValue(for: .discipline),
            allCompleted: manager.allTodayCompleted,
            morningHour: morningHour,
            morningMinute: morningMinute,
            eveningHour: eveningHour,
            eveningMinute: eveningMinute,
            intensity: intensity,
            enabled: notificationsEnabled,
            inactivityEnabled: inactivityEnabled
        )
    }
}
