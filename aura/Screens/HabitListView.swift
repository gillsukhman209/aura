import SwiftUI

struct HabitListView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var editingHabit: Habit?
    @State private var showCreate = false

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppTheme.bgCard))
                    }
                    Spacer()
                    Text("Manage Habits")
                        .font(.custom("Georgia-Bold", size: 18))
                        .foregroundColor(AppTheme.textBright)
                    Spacer()
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.gold)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppTheme.bgCard))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

                if manager.habits.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "list.bullet.circle")
                            .font(.system(size: 44, weight: .ultraLight))
                            .foregroundColor(AppTheme.textSubtle)
                        Text("No habits yet")
                            .font(.custom("Georgia", size: 15))
                            .foregroundColor(AppTheme.textMuted)
                        Button { showCreate = true } label: {
                            Text("Create your first habit")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .foregroundColor(AppTheme.tabActive)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(manager.habits) { habit in
                                HabitListRow(habit: habit, onEdit: {
                                    editingHabit = habit
                                }, onArchive: {
                                    manager.archiveHabit(habit)
                                }, onDelete: {
                                    manager.deleteHabit(habit)
                                })
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateHabitView()
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(habit: habit)
        }
    }
}

// MARK: - Habit List Row

struct HabitListRow: View {
    let habit: Habit
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void

    @State private var showActions = false
    @State private var showDetail = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.bgCard)
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(habit.stat.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.textBright)
                HStack(spacing: 6) {
                    Text(habit.type.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSubtle)
                    Text("·")
                        .foregroundColor(AppTheme.textSubtle)
                    Text(habit.difficulty.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(habit.difficulty.color)
                    Text("·")
                        .foregroundColor(AppTheme.textSubtle)
                    Text(habit.schedule.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSubtle)
                }
            }

            Spacer()

            Button { showActions = true } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.bgCardBorder.opacity(0.5), lineWidth: 0.5)
                )
        )
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) {
            HabitDetailView(habit: habit)
        }
        .confirmationDialog("Manage Habit", isPresented: $showActions) {
            Button("Edit") { onEdit() }
            Button("Archive") { onArchive() }
            Button("Delete", role: .destructive) { onDelete() }
        }
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
    @State private var timesPerWeek: Int = 3
    @State private var showIconPicker = false

    private var schedule: Schedule {
        switch scheduleType {
        case .daily: return .daily
        case .specificDays: return .specificDays(selectedDays)
        case .timesPerWeek: return .timesPerWeek(timesPerWeek)
        }
    }

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(AppTheme.bgCard))
                        }
                        Spacer()
                        Text("Edit Habit")
                            .font(.custom("Georgia-Bold", size: 18))
                            .foregroundColor(AppTheme.textBright)
                        Spacer()
                        Color.clear.frame(width: 32, height: 32)
                    }
                    .padding(.top, 8)

                    // Icon + Name
                    HStack(spacing: 14) {
                        Button { showIconPicker = true } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.bgCard)
                                    .frame(width: 60, height: 60)
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(habit.stat.color)
                            }
                        }
                        .buttonStyle(.plain)

                        TextField("Habit name", text: $name)
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.textBright)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.bgCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppTheme.bgCardBorder, lineWidth: 0.5)
                                    )
                            )
                    }

                    // Locked fields info
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Difficulty (\(habit.difficulty.label)) and Stat (\(habit.stat.label)) cannot be changed")
                            .font(.system(size: 11, design: .serif))
                    }
                    .foregroundColor(AppTheme.textSubtle)

                    // Schedule
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SCHEDULE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.textSubtle)
                            .tracking(1.5)

                        HStack(spacing: 8) {
                            ForEach(CreateHabitView.ScheduleType.allCases, id: \.rawValue) { s in
                                let selected = scheduleType == s
                                Button { scheduleType = s } label: {
                                    Text(s.rawValue)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(selected ? AppTheme.tabActive : AppTheme.textMuted)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selected ? AppTheme.tabActive.opacity(0.12) : AppTheme.bgPure)
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
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(isSelected ? .white : AppTheme.textMuted)
                                            .frame(width: 34, height: 34)
                                            .background(Circle().fill(isSelected ? AppTheme.tabActive.opacity(0.3) : AppTheme.bgPure))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if scheduleType == .timesPerWeek {
                            HStack {
                                Text("Times per week:")
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(AppTheme.textMuted)
                                Spacer()
                                HStack(spacing: 12) {
                                    Button {
                                        if timesPerWeek > 1 { timesPerWeek -= 1 }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(AppTheme.textMuted)
                                    }
                                    .buttonStyle(.plain)
                                    Text("\(timesPerWeek)")
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .foregroundColor(AppTheme.textBright)
                                        .frame(width: 30)
                                    Button {
                                        if timesPerWeek < 7 { timesPerWeek += 1 }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(AppTheme.tabActive)
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
                            .fill(AppTheme.bgCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.bgCardBorder.opacity(0.5), lineWidth: 0.5)
                            )
                    )

                    // Save Button
                    Button {
                        manager.updateHabit(habit, name: name.trimmingCharacters(in: .whitespaces), icon: icon, schedule: schedule)
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.tabActive)
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
            case .timesPerWeek(let count):
                scheduleType = .timesPerWeek
                timesPerWeek = count
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
    }
}
