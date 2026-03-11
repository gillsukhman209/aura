import SwiftUI

struct QuestCard: View {
    let quest: Quest
    @State private var showCheck = false

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
                            .stroke(AppTheme.gold.opacity(0.15), lineWidth: 0.5)
                    )

                Image(systemName: quest.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.gold)
                    .shadow(color: AppTheme.gold.opacity(0.4), radius: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(quest.title)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.textBright)

                Text("+\(quest.xpReward) \(quest.statType) XP")
                    .font(.system(size: 12, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.textGold)
            }

            Spacer()

            if quest.isCompleted {
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
            } else {
                Circle()
                    .stroke(AppTheme.bgCardBorder, lineWidth: 1.5)
                    .frame(width: 32, height: 32)
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
