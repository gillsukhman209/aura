import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var animateStats = false
    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    private var analytics: HabitAnalytics { HabitAnalytics(habit: habit) }

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // ── Header ──
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(hex: "111111")))
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Button { showEdit = true } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "888888"))
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color(hex: "111111")))
                            }
                            Button { showDeleteConfirm = true } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.accentDanger)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(AppTheme.accentDanger.opacity(0.1)))
                            }
                        }
                    }
                    .padding(.top, 8)

                    // ── Habit Identity ──
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(habit.stat.color.opacity(0.1))
                                .frame(width: 72, height: 72)
                            Image(systemName: habit.icon)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(habit.stat.color)
                                .shadow(color: habit.stat.color.opacity(0.4), radius: 6)
                        }

                        Text(habit.name)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "F0F0F0"))

                        HStack(spacing: 12) {
                            statPill(habit.type.label, color: .white)
                            statPill(habit.difficulty.label, color: habit.difficulty.color)
                            statPill(habit.stat.label, color: habit.stat.color)
                        }

                        Text(habit.schedule.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "555555"))
                    }

                    // ── Quick Stats ──
                    HStack(spacing: 10) {
                        quickStatCard(
                            value: "\(analytics.currentHabitStreak)",
                            label: "Streak",
                            icon: "flame.fill",
                            color: AppTheme.accentOrange
                        )
                        quickStatCard(
                            value: "\(analytics.totalCompletions)",
                            label: "Done",
                            icon: "checkmark.circle.fill",
                            color: AppTheme.accentGreen
                        )
                        quickStatCard(
                            value: "\(analytics.totalXPEarned)",
                            label: "AP",
                            icon: "star.fill",
                            color: AppTheme.gold
                        )
                    }

                    // ── Completion Rates ──
                    sectionCard(title: "Completion Rate") {
                        VStack(spacing: 10) {
                            rateBar(label: "7 days", rate: analytics.rate7d)
                            rateBar(label: "30 days", rate: analytics.rate30d)
                            rateBar(label: "90 days", rate: analytics.rate90d)
                        }
                    }

                    // ── Activity ──
                    sectionCard(title: "Activity") {
                        ActivityGridView(habit: habit)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            Analytics.screen("HabitDetail", properties: ["habit_name": habit.name])
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { animateStats = true }
        }
        .sheet(isPresented: $showEdit) {
            EditHabitView(habit: habit)
        }
        .confirmationDialog("Delete Habit", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                manager.deleteHabit(habit)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \"\(habit.name)\" and all its logs. This cannot be undone.")
        }
    }

    // MARK: - Sub-views

    private func statPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.1))
            )
    }

    private func quickStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(hex: "F0F0F0"))
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(hex: "555555"))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
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

    private func rateBar(label: String, rate: Double) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "666666"))
                .frame(width: 52, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [habit.stat.color.opacity(0.6), habit.stat.color],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: animateStats ? geo.size.width * rate : 0, height: 6)
                        .shadow(color: habit.stat.color.opacity(0.3), radius: 3)
                }
            }
            .frame(height: 6)

            Text("\(Int(rate * 100))%")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(rateColor(rate))
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func rateColor(_ rate: Double) -> Color {
        if rate >= 0.85 { return AppTheme.accentGreen }
        if rate >= 0.5 { return AppTheme.gold }
        return AppTheme.accentDanger
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "555555"))
                .tracking(2)

            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Edit Habit View

struct EditHabitView: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var icon: String = ""
    @State private var scheduleType: CreateHabitView.ScheduleType = .daily
    @State private var selectedDays: Set<Weekday> = []
    @State private var showIconPicker = false

    private var schedule: Schedule {
        switch scheduleType {
        case .daily: return .daily
        case .specificDays: return .specificDays(selectedDays)
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(hex: "111111")))
                        }
                        Spacer()
                        Text("EDIT HABIT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "F0F0F0"))
                            .tracking(2)
                        Spacer()
                        Color.clear.frame(width: 32, height: 32)
                    }
                    .padding(.top, 8)

                    // Icon + Name
                    HStack(spacing: 14) {
                        Button { showIconPicker = true } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "111111"))
                                    .frame(width: 60, height: 60)
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(habit.stat.color)
                            }
                        }
                        .buttonStyle(.plain)

                        TextField("Habit name", text: $name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "F0F0F0"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "111111"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "1E1E1E"), lineWidth: 0.5)
                                    )
                            )
                    }

                    // Locked fields info
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Difficulty (\(habit.difficulty.label)) and Stat (\(habit.stat.label)) cannot be changed")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "444444"))

                    // Schedule
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SCHEDULE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(2)

                        HStack(spacing: 8) {
                            ForEach(CreateHabitView.ScheduleType.allCases, id: \.rawValue) { s in
                                let selected = scheduleType == s
                                Button { scheduleType = s } label: {
                                    Text(s.rawValue)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(selected ? .white : Color(hex: "666666"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selected ? Color.white.opacity(0.12) : Color(hex: "0A0A0A"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if scheduleType == .specificDays {
                            HStack(spacing: 6) {
                                ForEach(Weekday.allCases) { day in
                                    let isSelected = selectedDays.contains(day)
                                    Button {
                                        if isSelected { selectedDays.remove(day) }
                                        else { selectedDays.insert(day) }
                                    } label: {
                                        Text(String(day.shortLabel.prefix(2)))
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(isSelected ? .white : Color(hex: "555555"))
                                            .frame(width: 34, height: 34)
                                            .background(Circle().fill(isSelected ? Color.white.opacity(0.2) : Color(hex: "0A0A0A")))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "0A0A0A"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                                )
                    )

                    // Save Button
                    Button {
                        manager.updateHabit(habit, name: name.trimmingCharacters(in: .whitespaces), icon: icon, schedule: schedule)
                        dismiss()
                    } label: {
                        Text("SAVE CHANGES")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(.plain)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            name = habit.name
            icon = habit.icon
            switch habit.schedule {
            case .daily:
                scheduleType = .daily
            case .specificDays(let days):
                scheduleType = .specificDays
                selectedDays = days
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
    }
}
