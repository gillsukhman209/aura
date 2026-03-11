import SwiftUI

struct HabitCard: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager
    @State private var showCheck = false
    @State private var showNumericInput = false
    @State private var numericText = ""
    @State private var showDetail = false

    /// Whether this habit has an explicit completed log today.
    /// Quit habits use separate logic (no log = going strong, not "completed").
    private var hasBuildOrNumericCompletion: Bool {
        guard habit.type != .quit else { return false }
        return habit.isCompleted(on: appNow())
    }

    /// Whether a quit habit has relapsed today.
    private var hasRelapsedToday: Bool {
        guard habit.type == .quit else { return false }
        return habit.log(for: appNow())?.status == .relapsed
    }

    var body: some View {
        HStack(spacing: 12) {
            // Cinematic thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.bgCardBorder, AppTheme.bgCard],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(habit.stat.color.opacity(0.15), lineWidth: 0.5)
                    )

                Image(systemName: habit.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(habit.stat.color)
                    .shadow(color: habit.stat.color.opacity(0.4), radius: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.textBright)

                HStack(spacing: 4) {
                    Text("+\(habit.baseXP)")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(AppTheme.textGold)
                    Text(habit.stat.label + " XP")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(AppTheme.textGold)
                }

                // Numeric progress
                if habit.type == .numeric, let target = habit.targetValue {
                    let current = habit.log(for: appNow())?.value ?? 0
                    let unit = habit.unit ?? ""
                    Text("\(String(format: "%.1f", current))/\(String(format: "%.0f", target)) \(unit)")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(AppTheme.textMuted)
                }

                // Quit habit status
                if habit.type == .quit {
                    Text(hasRelapsedToday ? "Relapsed" : "Going strong")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(hasRelapsedToday ? AppTheme.accentDanger : AppTheme.accentGreen)
                }
            }

            Spacer()

            // ── Completion indicator ──
            completionIndicator
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.bgCardBorder.opacity(0.5), lineWidth: 0.5)
                )
        )
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            HabitDetailView(habit: habit)
        }
        .alert("Log \(habit.unit ?? "value")", isPresented: $showNumericInput) {
            TextField("Amount", text: $numericText)
                .keyboardType(.decimalPad)
            Button("Add") {
                if let val = Double(numericText), val > 0 {
                    manager.logNumericProgress(habit, value: val)
                }
                numericText = ""
            }
            Button("Cancel", role: .cancel) { numericText = "" }
        } message: {
            if let target = habit.targetValue, let unit = habit.unit {
                let current = habit.log(for: appNow())?.value ?? 0
                Text("Current: \(String(format: "%.1f", current))/\(String(format: "%.0f", target)) \(unit)")
            }
        }
    }

    @ViewBuilder
    private var completionIndicator: some View {
        switch habit.type {
        case .build:
            if hasBuildOrNumericCompletion {
                checkmark
            } else {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        manager.completeBuildHabit(habit)
                        showCheck = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.bgCardBorder, lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }

        case .quit:
            if hasRelapsedToday {
                // Relapsed — show red indicator
                ZStack {
                    Circle()
                        .fill(AppTheme.accentDanger.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.accentDanger)
                }
            } else {
                // Going strong — show relapse button
                Button {
                    manager.logRelapse(habit)
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentDanger.opacity(0.08))
                            .frame(width: 44, height: 44)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.accentDanger.opacity(0.6))
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }

        case .numeric:
            if hasBuildOrNumericCompletion {
                checkmark
            } else {
                Button {
                    showNumericInput = true
                } label: {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.bgCardBorder, lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accentGreen.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.accentGreen)
        }
        .scaleEffect(showCheck ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
                showCheck = true
            }
        }
    }
}
