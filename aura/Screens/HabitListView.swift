import SwiftUI

struct HabitListView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var editingHabit: Habit?
    @State private var showCreate = false

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            VStack(spacing: 0) {
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
                    Text("MANAGE HABITS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "F0F0F0"))
                        .tracking(2)
                    Spacer()
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: "111111")))
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
                            .foregroundColor(Color(hex: "333333"))
                        Text("No habits yet")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "555555"))
                        Button { showCreate = true } label: {
                            Text("Create your first habit")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
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
                    .fill(habit.stat.color.opacity(0.08))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(habit.stat.color.opacity(0.12), lineWidth: 0.5)
                    )
                Image(systemName: habit.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(habit.stat.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "F0F0F0"))
                HStack(spacing: 6) {
                    Text(habit.type.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                    Text("·")
                        .foregroundColor(Color(hex: "333333"))
                    Text(habit.difficulty.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(habit.difficulty.color)
                    Text("·")
                        .foregroundColor(Color(hex: "333333"))
                    Text(habit.schedule.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                }
            }

            Spacer()

            Button { showActions = true } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "555555"))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "0A0A0A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
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
