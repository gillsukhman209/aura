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
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var showIconPicker = false

    enum ScheduleType: String, CaseIterable {
        case daily = "Every Day"
        case specificDays = "Specific Days"
    }

    private var schedule: Schedule {
        switch scheduleType {
        case .daily: return .daily
        case .specificDays: return .specificDays(selectedDays)
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
            Color(hex: "050505").ignoresSafeArea()

            ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // ── Header ──
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "888888"))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color(hex: "111111")))
                        }
                        Spacer()
                        Text("NEW HABIT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "F0F0F0"))
                            .tracking(2)
                        Spacer()
                        Color.clear.frame(width: 32, height: 32)
                    }
                    .padding(.top, 8)

                    // ── Icon + Name ──
                    HStack(spacing: 14) {
                        Button { showIconPicker = true } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "111111"))
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
                        .tutorialAnchor(.habitIcon)

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
                            .tutorialAnchor(.habitName)
                    }
                    .id(TutorialCoordinator.Step.habitName)

                    // ── Type ──
                    sectionCard(title: "Type") {
                        HStack(spacing: 8) {
                            ForEach(HabitType.allCases) { t in
                                chipButton(
                                    label: t.label,
                                    icon: t.icon,
                                    selected: type == t,
                                    color: type == t ? .white : Color(hex: "666666")
                                ) { type = t }
                            }
                        }

                        Text(type.description)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "444444"))
                            .padding(.top, 2)
                    }
                    .tutorialAnchor(.habitType)
                    .id(TutorialCoordinator.Step.habitType)

                    // ── Numeric fields ──
                    if type == .numeric {
                        sectionCard(title: "Target") {
                            HStack(spacing: 10) {
                                TextField("Value", text: $targetValue)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "F0F0F0"))
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "050505"))
                                    )
                                    .frame(width: 100)

                                TextField("Unit (L, min, km...)", text: $unit)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "F0F0F0"))
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "050505"))
                                    )
                            }
                        }
                        .tutorialAnchor(.numericTarget)
                        .id(TutorialCoordinator.Step.numericTarget)
                    }

                    // ── Difficulty ──
                    sectionCard(title: "Difficulty") {
                        HStack(spacing: 8) {
                            ForEach(Difficulty.allCases) { d in
                                chipButton(
                                    label: "\(d.label) (+\(d.baseXP) AP)",
                                    icon: nil,
                                    selected: difficulty == d,
                                    color: difficulty == d ? d.color : Color(hex: "666666")
                                ) { difficulty = d }
                            }
                        }
                    }
                    .tutorialAnchor(.difficulty)
                    .id(TutorialCoordinator.Step.difficulty)

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
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(stat == s ? Color(hex: "F0F0F0") : Color(hex: "666666"))
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
                    .tutorialAnchor(.stat)
                    .id(TutorialCoordinator.Step.stat)

                    // ── Schedule ──
                    sectionCard(title: "Schedule") {
                        HStack(spacing: 8) {
                            ForEach(ScheduleType.allCases, id: \.rawValue) { s in
                                chipButton(
                                    label: s.rawValue,
                                    icon: nil,
                                    selected: scheduleType == s,
                                    color: scheduleType == s ? .white : Color(hex: "666666")
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
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(isSelected ? .white : Color(hex: "555555"))
                                            .frame(width: 34, height: 34)
                                            .background(
                                                Circle()
                                                    .fill(isSelected ? Color.white.opacity(0.2) : Color(hex: "050505"))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)
                        }

                    }
                    .tutorialAnchor(.schedule)
                    .id(TutorialCoordinator.Step.schedule)

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
                        if TutorialCoordinator.shared.isActive,
                           TutorialCoordinator.shared.currentStep == .createButton {
                            TutorialCoordinator.shared.complete()
                        }
                        dismiss()
                    } label: {
                        Text("CREATE HABIT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(canSave ? .white : Color(hex: "444444"))
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(canSave ? Color.white.opacity(0.15) : Color(hex: "0A0A0A"))
                            )
                    }
                    .disabled(!canSave)
                    .buttonStyle(.plain)
                    .tutorialAnchor(.createButton)
                    .id(TutorialCoordinator.Step.createButton)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: TutorialCoordinator.shared.currentStep) { _, step in
                guard TutorialCoordinator.shared.isActive else { return }
                // Target section only exists when type is numeric — skip past it otherwise.
                if step == .numericTarget && type != .numeric {
                    TutorialCoordinator.shared.advance()
                    return
                }
                withAnimation(.easeInOut(duration: 0.4)) {
                    scrollProxy.scrollTo(step, anchor: .center)
                }
            }
            .onChange(of: type) { _, newType in
                // If the user switches away from numeric while parked on the Target step,
                // the Target section disappears — skip ahead.
                if TutorialCoordinator.shared.isActive,
                   TutorialCoordinator.shared.currentStep == .numericTarget,
                   newType != .numeric {
                    TutorialCoordinator.shared.advance()
                }
            }
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIcon: $icon)
        }
        .tutorialOverlay()
        .onAppear {
            Analytics.screen("CreateHabit")
            // If the tutorial is still on the home-screen step (user tapped + mid-tour), advance it.
            if TutorialCoordinator.shared.isActive,
               TutorialCoordinator.shared.currentStep < .habitName {
                TutorialCoordinator.shared.jump(to: .habitName)
            }
        }
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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

    // MARK: - Chip Button

    private func chipButton(label: String, icon: String?, selected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(label)
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? color.opacity(0.12) : Color(hex: "050505"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selected ? color.opacity(0.3) : Color(hex: "1E1E1E"), lineWidth: 0.5)
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
            Color(hex: "050505").ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("CHOOSE ICON")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "F0F0F0"))
                        .tracking(2)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "555555"))
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
                                    .foregroundColor(Color(hex: "555555"))
                                    .tracking(2)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                                    ForEach(categoryIcons, id: \.self) { iconName in
                                        let isSelected = selectedIcon == iconName
                                        Button {
                                            selectedIcon = iconName
                                            dismiss()
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(isSelected ? Color.white.opacity(0.12) : Color(hex: "0A0A0A"))
                                                    .frame(height: 52)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(
                                                                isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.05),
                                                                lineWidth: isSelected ? 1 : 0.5
                                                            )
                                                    )
                                                Image(systemName: iconName)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(isSelected ? .white : Color(hex: "666666"))
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
