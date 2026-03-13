import SwiftUI

struct OB_SocialProofView: View {
    var vm: OnboardingViewModel

    private let testimonials: [(String, String, Int)] = [
        ("Alex M.", "This app completely changed my morning routine. I actually wake up excited to check things off.", 5),
        ("Jordan K.", "The gamification makes building habits addictive in the best way. Level 12 and counting.", 5),
        ("Sam T.", "Finally an app that doesn't feel like a chore. The streak system keeps me accountable.", 5)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Rating header
            VStack(spacing: 8) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.goldBright)
                    }
                }

                Text("4.8 out of 5")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("15,500+ ratings")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.top, 30)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(Array(testimonials.enumerated()), id: \.offset) { _, testimonial in
                        TestimonialCard(name: testimonial.0, text: testimonial.1, stars: testimonial.2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            // Community stat
            Text("Join 250K+ users leveling up")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 16)

            Spacer()

            OnboardingNextButton(title: "Continue") {
                vm.next()
            }
        }
    }
}

struct TestimonialCard: View {
    let name: String
    let text: String
    let stars: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Avatar circle
                Circle()
                    .fill(AppTheme.tabActive.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.tabActive)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 2) {
                        ForEach(0..<stars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.goldBright)
                        }
                    }
                }

                Spacer()
            }

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.bgCardBorder, lineWidth: 0.8)
                )
        )
    }
}
