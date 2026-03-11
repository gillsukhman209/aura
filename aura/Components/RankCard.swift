import SwiftUI

struct RankCard: View {
    let rank: DisplayRank

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(rank.color.opacity(rank.isUnlocked ? 0.12 : 0.04))
                    .frame(width: 40, height: 40)
                if rank.isUnlocked {
                    Image(systemName: rank.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(rank.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSubtle)
                }
            }

            HStack(spacing: 5) {
                Text(rank.name)
                    .font(.system(size: 15, weight: rank.isCurrent ? .bold : .medium, design: .serif))
                    .foregroundColor(
                        rank.isCurrent ? .white :
                        rank.isUnlocked ? AppTheme.textMuted : AppTheme.textSubtle
                    )
                if !rank.tier.isEmpty {
                    Text(rank.tier)
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundColor(rank.color)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                if rank.isCurrent || !rank.isUnlocked {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 8))
                        .foregroundColor(rank.isCurrent ? rank.color : AppTheme.textSubtle)
                }
                Text("\(rank.threshold)%")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(
                        rank.isCurrent ? rank.color :
                        rank.isUnlocked ? AppTheme.textMuted : AppTheme.textSubtle
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(rank.isCurrent ? rank.color.opacity(0.08) : AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            rank.isCurrent ? rank.color.opacity(0.3) : AppTheme.bgCardBorder.opacity(0.3),
                            lineWidth: rank.isCurrent ? 1.5 : 0.5
                        )
                )
        )
    }
}
