import SwiftUI

struct DailyQuestsView: View {
    @Environment(HabitManager.self) private var manager
    @State private var showBonus = false
    @State private var bonusProgress: CGFloat = 0

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text("DAILY QUESTS")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)
                        .padding(.top, 12)

                    ForEach(manager.todaysHabits) { habit in
                        HabitCard(habit: habit)
                    }

                    // Daily Completion Bonus
                    if manager.allTodayCompleted, !manager.todaysHabits.isEmpty {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Daily Completion Bonus")
                                    .font(.system(size: 13, weight: .medium, design: .serif))
                                    .foregroundColor(AppTheme.textMuted)
                                Spacer()
                                Text("+40")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(AppTheme.gold)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(AppTheme.barGroove).frame(height: 4)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.barFillStart, AppTheme.barFillEnd],
                                                startPoint: .leading, endPoint: .trailing
                                            )
                                        )
                                        .frame(width: bonusProgress * geo.size.width, height: 4)
                                        .shadow(color: AppTheme.barGlow.opacity(0.4), radius: 3)
                                }
                            }
                            .frame(height: 4)

                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentGreen.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.accentGreen)
                                }
                                .scaleEffect(showBonus ? 1 : 0)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.bgCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.gold.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) { bonusProgress = 1.0 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.2)) { showBonus = true }
        }
    }
}
