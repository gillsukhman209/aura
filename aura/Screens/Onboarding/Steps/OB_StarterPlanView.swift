import SwiftUI

struct OB_StarterPlanView: View {
    var vm: OnboardingViewModel
    @State private var headerOpacity: Double = 0
    @State private var cardsOpacity: Double = 0
    @State private var staggerIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──
            VStack(spacing: 8) {
                Text("YOUR STARTER PLAN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.accentGreen)
                    .tracking(4)

                Text("Based on your answers, here's\nyour personalized habit plan.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Toggle off any you don't want")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
                    .padding(.top, 2)
            }
            .opacity(headerOpacity)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // ── Habit Count ──
            HStack(spacing: 6) {
                Text("\(vm.selectedStarterHabits.count)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                Text("habits selected")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.bottom, 12)
            .opacity(cardsOpacity)

            // ── Habit Cards ──
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Array(vm.starterHabits.enumerated()), id: \.element.id) { index, habit in
                        starterHabitCard(habit: habit, index: index)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .opacity(cardsOpacity)

            // ── Continue Button ──
            OnboardingNextButton(
                title: "Start with \(vm.selectedStarterHabits.count) Habits",
                isEnabled: !vm.selectedStarterHabits.isEmpty
            ) {
                vm.next()
            }
        }
        .onAppear {
            // Generate habits when this screen appears
            if vm.starterHabits.isEmpty {
                vm.generateStarterPlan()
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                headerOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                cardsOpacity = 1
            }
        }
    }

    // MARK: - Habit Card

    private func starterHabitCard(habit: SuggestedHabit, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.toggleHabit(habit)
            }
        } label: {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(habit.isSelected ? habit.stat.color.opacity(0.15) : Color(hex: "1A1A1A"))
                        .frame(width: 42, height: 42)
                    Image(systemName: habit.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(habit.isSelected ? habit.stat.color : Color(hex: "444444"))
                }

                // Name + reason
                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(habit.isSelected ? Color(hex: "E0E0E0") : Color(hex: "555555"))

                    Text(habit.reason)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "555555"))
                }

                Spacer()

                // Metadata pills
                VStack(alignment: .trailing, spacing: 4) {
                    // Type + Difficulty
                    HStack(spacing: 4) {
                        Text(habit.type.label.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                            .tracking(0.5)
                        Text("·")
                            .foregroundColor(Color(hex: "333333"))
                        Text(habit.difficulty.label.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(habit.difficulty.color.opacity(habit.isSelected ? 1 : 0.4))
                            .tracking(0.5)
                    }

                    // XP
                    Text("+\(habit.difficulty.baseXP) AP")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(habit.isSelected ? AppTheme.gold : Color(hex: "333333"))
                }

                // Toggle indicator
                ZStack {
                    Circle()
                        .fill(habit.isSelected ? AppTheme.accentGreen : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(habit.isSelected ? AppTheme.accentGreen : Color(hex: "333333"), lineWidth: 1.5)
                        )

                    if habit.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(habit.isSelected ? Color(hex: "0A0A0A") : Color(hex: "080808"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                habit.isSelected ? habit.stat.color.opacity(0.2) : Color(hex: "151515"),
                                lineWidth: 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
