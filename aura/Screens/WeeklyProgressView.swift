import SwiftUI

struct WeeklyProgressView: View {
    @Environment(HabitManager.self) private var manager: HabitManager?
    @State private var animateValues = false

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("LEVEL \(manager?.level ?? 0)")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(AppTheme.textMuted)
                            .tracking(3)

                        Text("LEVEL \((manager?.level ?? 0) + 1)")
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        GeometryReader { geo in
                            let progress = manager?.profile?.levelProgress ?? 0
                            ZStack(alignment: .leading) {
                                Capsule().fill(AppTheme.barGroove).frame(height: 5)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.barFillStart, AppTheme.barFillEnd],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: animateValues ? geo.size.width * progress : 0, height: 5)
                                    .shadow(color: AppTheme.barGlow.opacity(0.4), radius: 4)
                            }
                        }
                        .frame(height: 5)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                    .padding(.top, 12)

                    HStack {
                        Text("XP GAINED THIS WEEK")
                            .font(.system(size: 11, weight: .medium, design: .serif))
                            .foregroundColor(AppTheme.textMuted)
                            .tracking(2)
                        Circle().fill(AppTheme.accentDanger).frame(width: 5, height: 5)
                    }
                    .padding(.top, 8)

                    let progress = manager?.weeklyProgress ?? []
                    if progress.isEmpty {
                        Text("Complete habits to see weekly progress")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(AppTheme.textSubtle)
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(progress) { stat in
                                HStack(spacing: 12) {
                                    Image(systemName: stat.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(stat.color)
                                        .frame(width: 24)
                                    Text(stat.name)
                                        .font(.system(size: 15, weight: .medium, design: .serif))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("+\(animateValues ? stat.xpGained : 0)")
                                        .font(.system(size: 16, weight: .bold, design: .serif))
                                        .foregroundColor(AppTheme.gold)
                                        .contentTransition(.numericText())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.bgCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(AppTheme.bgCardBorder.opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) { animateValues = true }
        }
    }
}
