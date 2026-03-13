import SwiftUI

/// Simple calendar grid showing check/x for each day.
struct ActivityGridView: View {
    let habit: Habit
    var weeks: Int = 6

    private let spacing: CGFloat = 4
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private struct DayCell: Identifiable {
        let id: Date
        let completed: Bool
        let missed: Bool
        let isFuture: Bool
        let isBeforeCreation: Bool
    }

    private var rows: [[DayCell]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())
        let createdDay = calendar.startOfDay(for: habit.createdAt)

        let todayWeekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (todayWeekday + 5) % 7
        guard let currentMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }

        var result: [[DayCell]] = []

        for weekOffset in stride(from: -(weeks - 1), through: 0, by: 1) {
            guard let weekMonday = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: currentMonday) else { continue }
            var row: [DayCell] = []

            for dayIndex in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayIndex, to: weekMonday) else { continue }
                let startOfDay = calendar.startOfDay(for: date)
                let isFuture = startOfDay > today
                let isBeforeCreation = startOfDay < createdDay
                let scheduled = !isFuture && !isBeforeCreation && habit.isScheduled(on: date)
                let completed = scheduled && habit.isCompleted(on: date)
                let missed = scheduled && !completed && !isFuture

                row.append(DayCell(
                    id: startOfDay,
                    completed: completed,
                    missed: missed,
                    isFuture: isFuture,
                    isBeforeCreation: isBeforeCreation
                ))
            }
            result.append(row)
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Day-of-week column headers
            HStack(spacing: spacing) {
                ForEach(0..<7, id: \.self) { i in
                    Text(dayLabels[i])
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .frame(maxWidth: .infinity)
                }
            }

            // Grid rows
            VStack(spacing: spacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(row) { cell in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(cellBackground(for: cell))
                                .frame(maxWidth: .infinity)
                                .frame(height: 28)
                        }
                    }
                }
            }
        }
    }

    private func cellBackground(for cell: DayCell) -> Color {
        if cell.isFuture || cell.isBeforeCreation {
            return Color(hex: "0A0A0A").opacity(0.3)
        }
        if cell.completed {
            return AppTheme.accentGreen.opacity(0.45)
        }
        if cell.missed {
            return AppTheme.accentDanger.opacity(0.3)
        }
        return Color(hex: "0A0A0A")
    }
}
