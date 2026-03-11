import SwiftUI

/// GitHub-style contribution heatmap. Shows last `weeks` weeks of data.
struct HeatmapView: View {
    let data: [Date: HeatmapLevel]
    let accentColor: Color
    var weeks: Int = 16

    private let cellSize: CGFloat = 12
    private let spacing: CGFloat = 3
    private let dayLabels = ["", "M", "", "W", "", "F", ""]

    private var grid: [[HeatmapCell]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())

        // Find the most recent Sunday (start of current week column)
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToSunday = todayWeekday - 1 // weekday 1 = Sunday
        guard let currentSunday = calendar.date(byAdding: .day, value: -daysToSunday, to: today) else { return [] }

        var columns: [[HeatmapCell]] = []

        for weekOffset in stride(from: -(weeks - 1), through: 0, by: 1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: currentSunday) else { continue }
            var column: [HeatmapCell] = []

            for dayIndex in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayIndex, to: weekStart) else { continue }
                let isFuture = date > today
                let level = isFuture ? .none : (data[calendar.startOfDay(for: date)] ?? .none)
                column.append(HeatmapCell(date: date, level: level, isFuture: isFuture))
            }
            columns.append(column)
        }
        return columns
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Month labels
            monthLabels

            HStack(alignment: .top, spacing: spacing) {
                // Day labels
                VStack(spacing: spacing) {
                    ForEach(0..<7, id: \.self) { i in
                        Text(dayLabels[i])
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(AppTheme.textSubtle)
                            .frame(width: 14, height: cellSize)
                    }
                }

                // Grid
                HStack(spacing: spacing) {
                    ForEach(Array(grid.enumerated()), id: \.offset) { _, column in
                        VStack(spacing: spacing) {
                            ForEach(column, id: \.date) { cell in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cellColor(for: cell))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.system(size: 8))
                    .foregroundColor(AppTheme.textSubtle)
                ForEach(HeatmapLevel.allCases, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color(for: level))
                        .frame(width: 10, height: 10)
                }
                Text("More")
                    .font(.system(size: 8))
                    .foregroundColor(AppTheme.textSubtle)
            }
            .padding(.top, 4)
        }
    }

    private var monthLabels: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: appNow())
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToSunday = todayWeekday - 1
        guard let currentSunday = calendar.date(byAdding: .day, value: -daysToSunday, to: today) else {
            return AnyView(EmptyView())
        }

        var labels: [(String, Int)] = []
        var lastMonth = -1

        for weekOffset in stride(from: -(weeks - 1), through: 0, by: 1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: currentSunday) else { continue }
            let month = calendar.component(.month, from: weekStart)
            if month != lastMonth {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                labels.append((formatter.string(from: weekStart), weekOffset + (weeks - 1)))
                lastMonth = month
            }
        }

        return AnyView(
            HStack(spacing: 0) {
                Color.clear.frame(width: 14 + spacing) // day label offset
                ZStack(alignment: .leading) {
                    Color.clear.frame(height: 12)
                    ForEach(labels, id: \.1) { label, offset in
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(AppTheme.textSubtle)
                            .offset(x: CGFloat(offset) * (cellSize + spacing))
                    }
                }
            }
        )
    }

    private func cellColor(for cell: HeatmapCell) -> Color {
        if cell.isFuture { return AppTheme.bgCard.opacity(0.3) }
        return color(for: cell.level)
    }

    private func color(for level: HeatmapLevel) -> Color {
        switch level {
        case .none: return AppTheme.bgCard
        case .low: return accentColor.opacity(0.25)
        case .medium: return accentColor.opacity(0.5)
        case .high: return accentColor.opacity(0.75)
        case .max: return accentColor
        }
    }
}

struct HeatmapCell {
    let date: Date
    let level: HeatmapLevel
    let isFuture: Bool
}

enum HeatmapLevel: Int, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case max = 4
}
