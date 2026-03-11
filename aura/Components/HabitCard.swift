import SwiftUI

struct HabitCard: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager: HabitManager?
    @State private var showCheck = false

    private var isCompletedToday: Bool {
        habit.isCompleted(on: Date())
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
                    let current = habit.log(for: Date())?.value ?? 0
                    let unit = habit.unit ?? ""
                    Text("\(String(format: "%.1f", current))/\(String(format: "%.0f", target)) \(unit)")
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            Spacer()

            // Completion indicator
            if isCompletedToday {
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
            } else if habit.type == .quit {
                // Quit habit: show relapse button
                Button {
                    manager?.logRelapse(habit)
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentDanger.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.accentDanger.opacity(0.7))
                    }
                }
            } else {
                // Build / numeric: tap to complete
                Button {
                    if habit.type == .build {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            manager?.completeBuildHabit(habit)
                            showCheck = true
                        }
                    }
                    // Numeric habits need a separate input flow (Phase 4)
                } label: {
                    Circle()
                        .stroke(AppTheme.bgCardBorder, lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                }
            }
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
    }
}
