import SwiftUI

struct CreateHabitView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: HabitType = .build
    @State private var icon = "star.fill"
    @State private var difficulty: Difficulty = .medium
    @State private var stat: StatType = .strength
    @State private var scheduleType: ScheduleType = .daily
    @State private var selectedDays: Set<Weekday> = []
    @State private var timesPerWeek = 3
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var showIconPicker = false

    enum ScheduleType: String, CaseIterable {
        case daily = "Every Day"
        case specificDays = "Specific Days"
        case timesPerWeek = "X Times / Week"
    }

    private var schedule: Schedule {
        switch scheduleType {
        case .daily: return .daily
        case .specificDays: return .specificDays(selectedDays)
        case .timesPerWeek: return .timesPerWeek(timesPerWeek)
        }
    }

    private var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if scheduleType == .specificDays, selectedDays.isEmpty { return false }
        if type == .numeric {
            guard let val = Double(targetValue), val > 0, !unit.isEmpty else { return false }
        }
        return true
    }

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // ── Header ──
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textMuted)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(AppTheme.bgCard))
                        }
                        Spacer()
                        Text("New Habit")
                            .font(.custom("Georgia-Bold", size: 18))
                            .foregroundColor(AppTheme.textBright)
                        Spacer()
                        // Balance spacer
                        Color.clear.frame(width: 32, height: 32)
                    }
                    .padding(.top, 8)

                    // ── Icon + Name ──
                    HStack(spacing: 14) {
                        Button { showIconPicker = true } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.bgCard)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(stat.color.opacity(0.2), lineWidth: 0.5)
                                    )
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(stat.color)
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

                    // ── Type ──
                    sectionCard(title: "Type") {
                        HStack(spacing: 8) {
                            ForEach(HabitType.allCases) { t in
                                chipButton(
                                    label: t.label,
                                    icon: t.icon,
                                    selected: type == t,
                                    color: type == t ? AppTheme.tabActive : AppTheme.textMuted
                                ) { type = t }
                            }
                        }

                        Text(type.description)
                            .font(.system(size: 11, design: .serif))
                            .foregroundColor(AppTheme.textSubtle)
                            .padding(.top, 2)
                    }

                    // ── Numeric fields ──
                    if type == .numeric {
                        sectionCard(title: "Target") {
                            HStack(spacing: 10) {
                                TextField("Value", text: $targetValue)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 15, weight: .medium, design: .serif))
                                    .foregroundColor(AppTheme.textBright)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppTheme.bgPure)
                                    )
                                    .frame(width: 100)

                                TextField("Unit (L, min, km...)", text: $unit)
                                    .font(.system(size: 15, weight: .medium, design: .serif))
                                    .foregroundColor(AppTheme.textBright)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppTheme.bgPure)
                                    )
                            }
                        }
                    }

                    // ── Difficulty ──
                    sectionCard(title: "Difficulty") {
                        HStack(spacing: 8) {
                            ForEach(Difficulty.allCases) { d in
                                chipButton(
                                    label: "\(d.label) (+\(d.baseXP) AP)",
                                    icon: nil,
                                    selected: difficulty == d,
                                    color: difficulty == d ? d.color : AppTheme.textMuted
                                ) { difficulty = d }
                            }
                        }
                    }

                    // ── Stat ──
                    sectionCard(title: "Stat") {
                        VStack(spacing: 8) {
                            ForEach(StatType.allCases) { s in
                                Button {
                                    stat = s
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: s.icon)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(s.color)
                                            .frame(width: 20)
                                        Text(s.label)
                                            .font(.system(size: 14, weight: .medium, design: .serif))
                                            .foregroundColor(stat == s ? AppTheme.textBright : AppTheme.textMuted)
                                        Spacer()
                                        if stat == s {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(s.color)
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // ── Schedule ──
                    sectionCard(title: "Schedule") {
                        HStack(spacing: 8) {
                            ForEach(ScheduleType.allCases, id: \.rawValue) { s in
                                chipButton(
                                    label: s.rawValue,
                                    icon: nil,
                                    selected: scheduleType == s,
                                    color: scheduleType == s ? AppTheme.tabActive : AppTheme.textMuted
                                ) { scheduleType = s }
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
                                            .background(
                                                Circle()
                                                    .fill(isSelected ? AppTheme.tabActive.opacity(0.3) : AppTheme.bgPure)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)
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
                            .padding(.top, 4)
                        }
                    }

                    // ── Create Button ──
                    Button {
                        manager.createHabit(
                            name: name.trimmingCharacters(in: .whitespaces),
                            type: type,
                            icon: icon,
                            difficulty: difficulty,
                            stat: stat,
                            schedule: schedule,
                            targetValue: type == .numeric ? Double(targetValue) : nil,
                            unit: type == .numeric ? unit : nil
                        )
                        dismiss()
                    } label: {
                        Text("Create Habit")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(canSave ? .white : AppTheme.textSubtle)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(canSave ? AppTheme.tabActive : AppTheme.bgCard)
                            )
                    }
                    .disabled(!canSave)
                    .buttonStyle(.plain)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSubtle)
                .tracking(1.5)

            content()
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
    }

    // MARK: - Chip Button

    private func chipButton(label: String, icon: String?, selected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? color.opacity(0.12) : AppTheme.bgPure)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selected ? color.opacity(0.3) : AppTheme.bgCardBorder, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon Picker

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let icons: [(String, [String])] = [
        ("Fitness", ["dumbbell.fill", "figure.run", "figure.strengthtraining.traditional", "figure.yoga", "figure.boxing", "figure.swimming", "bicycle", "figure.walk"]),
        ("Mind", ["brain.head.profile.fill", "book.fill", "pencil.and.outline", "eyeglasses", "puzzlepiece.fill", "lightbulb.fill", "graduationcap.fill", "music.note"]),
        ("Health", ["heart.fill", "drop.fill", "leaf.fill", "bed.double.fill", "pill.fill", "cross.fill", "lungs.fill", "stethoscope"]),
        ("Habits", ["xmark.circle.fill", "nosign", "smoke.fill", "cup.and.saucer.fill", "fork.knife", "wineglass", "cart.fill", "dollarsign.circle.fill"]),
        ("Productivity", ["laptopcomputer", "keyboard.fill", "clock.fill", "calendar", "checklist", "doc.text.fill", "folder.fill", "briefcase.fill"]),
        ("Social", ["person.2.fill", "phone.fill", "envelope.fill", "bubble.left.fill", "hand.raised.fill", "globe", "airplane", "house.fill"]),
    ]

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Choose Icon")
                        .font(.custom("Georgia-Bold", size: 18))
                        .foregroundColor(AppTheme.textBright)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(icons, id: \.0) { category, categoryIcons in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textSubtle)
                                    .tracking(1.5)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                                    ForEach(categoryIcons, id: \.self) { iconName in
                                        let isSelected = selectedIcon == iconName
                                        Button {
                                            selectedIcon = iconName
                                            dismiss()
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(isSelected ? AppTheme.tabActive.opacity(0.15) : AppTheme.bgCard)
                                                    .frame(height: 52)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(
                                                                isSelected ? AppTheme.tabActive.opacity(0.4) : AppTheme.bgCardBorder.opacity(0.5),
                                                                lineWidth: isSelected ? 1 : 0.5
                                                            )
                                                    )
                                                Image(systemName: iconName)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(isSelected ? AppTheme.tabActive : AppTheme.textMuted)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
    }
}
