import SwiftUI

struct TrainingCategoryCard: View {
    let category: TrainingCategory
    @State private var glowPulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color.opacity(0.15),
                                AppTheme.barGroove,
                                AppTheme.bgPure
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)

                Image(systemName: category.icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(category.color.opacity(0.3))

                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, AppTheme.bgCard],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 40)
                }
            }
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                Text(category.subtitle)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(AppTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(category.color.opacity(glowPulse ? 0.3 : 0.1), lineWidth: 1)
        )
        .shadow(color: category.color.opacity(glowPulse ? 0.15 : 0.05), radius: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}
