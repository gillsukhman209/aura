import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var animateStats = false

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

                    // ── Heatmap ──
                    sectionCard(title: "Activity") {
                        HeatmapView(
                            data: analytics.heatmapData(),
                            accentColor: habit.stat.color
                        )
                    }

                    // ── Recent History ──
                    sectionCard(title: "Recent Logs") {
                        let recentLogs = habit.logs
                            .sorted { $0.date > $1.date }
                            .prefix(10)

                        if recentLogs.isEmpty {
                            Text("No logs yet")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "555555"))
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(recentLogs), id: \.id) { log in
                                    logRow(log)
                                    if log.id != recentLogs.last?.id {
                                        Rectangle()
                                            .fill(Color(hex: "1A1A1A"))
                                            .frame(height: 0.5)
                                    }
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { animateStats = true }
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

    private func logRow(_ log: HabitLog) -> some View {
        HStack(spacing: 10) {
            Image(systemName: statusIcon(log.status))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor(log.status))
                .frame(width: 20)

            Text(log.date.formatted(.dateTime.month(.abbreviated).day()))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "F0F0F0"))

            Spacer()

            if let value = log.value, habit.type == .numeric {
                Text("\(String(format: "%.1f", value)) \(habit.unit ?? "")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
            }

            Text(log.status.rawValue.capitalized)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(statusColor(log.status))
        }
        .padding(.vertical, 8)
    }

    private func statusIcon(_ status: LogStatus) -> String {
        switch status {
        case .completed: return "checkmark.circle.fill"
        case .partial: return "circle.bottomhalf.filled"
        case .relapsed: return "xmark.circle.fill"
        case .skipped: return "minus.circle"
        }
    }

    private func statusColor(_ status: LogStatus) -> Color {
        switch status {
        case .completed: return AppTheme.accentGreen
        case .partial: return AppTheme.gold
        case .relapsed: return AppTheme.accentDanger
        case .skipped: return Color(hex: "555555")
        }
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
