import SwiftUI

struct WeeklyXPChart: View {
    let data: [(label: String, xp: Int)]
    let animate: Bool

    private var maxXP: Int {
        max(data.map(\.xp).max() ?? 1, 1)
    }

    private var totalWeekXP: Int {
        data.map(\.xp).reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("THIS WEEK")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
                    .tracking(2)
                Spacer()
                Text("\(totalWeekXP) AP")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(AppTheme.accentGreen)
            }
            .padding(.horizontal, 4)

            // Bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<data.count, id: \.self) { i in
                    let item = data[i]
                    let height: CGFloat = item.xp > 0
                        ? max(CGFloat(item.xp) / CGFloat(maxXP) * 80, 4)
                        : 4

                    VStack(spacing: 4) {
                        if item.xp > 0 {
                            Text("\(item.xp)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppTheme.textMuted)
                        }

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                item.xp > 0
                                    ? LinearGradient(
                                        colors: [AppTheme.accentGreen, AppTheme.accentGreen.opacity(0.6)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                    : LinearGradient(
                                        colors: [AppTheme.barGroove, AppTheme.barGroove],
                                        startPoint: .top, endPoint: .bottom
                                    )
                            )
                            .frame(height: animate ? height : 4)
                            .shadow(color: item.xp > 0 ? AppTheme.accentGreen.opacity(0.2) : .clear, radius: 3)

                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.bgCard.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.bgCardBorder.opacity(0.3), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 4)
    }
}
