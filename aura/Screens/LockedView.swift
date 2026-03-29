import SwiftUI
import SuperwallKit

struct LockedView: View {
    let onUnlocked: () -> Void

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var featuresOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var glowPulse = false

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("flame.fill", "Habit Tracking", "Build and quit habits with XP rewards"),
        ("chart.bar.fill", "Detailed Stats", "Track your progress across all areas"),
        ("bell.badge.fill", "Smart Roasts", "Personalized notifications that keep you accountable"),
        ("trophy.fill", "Rank System", "40 levels from Wood to Olympian"),
        ("sparkles", "Aura Check", "Shareable card showing your growth"),
    ]

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()
            StarfieldBackground(starCount: 150)
                .opacity(0.3)

            VStack(spacing: 0) {
                Spacer()

                // Lock icon with glow
                ZStack {
                    Circle()
                        .fill(AppTheme.accentPurple.opacity(glowPulse ? 0.15 : 0.08))
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)

                    ZStack {
                        Circle()
                            .fill(Color(hex: "0A0A0A"))
                            .frame(width: 90, height: 90)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [AppTheme.accentPurple.opacity(0.5), AppTheme.goldBright.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )

                        Image(systemName: "lock.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.accentPurple, AppTheme.goldBright],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer().frame(height: 28)

                // Title
                VStack(spacing: 10) {
                    Text("Subscribe to Unlock")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Get access to everything Aura has to offer.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .opacity(contentOpacity)

                Spacer().frame(height: 32)

                // Feature list
                VStack(spacing: 0) {
                    ForEach(Array(features.enumerated()), id: \.offset) { i, feature in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentPurple.opacity(0.1))
                                    .frame(width: 38, height: 38)

                                Image(systemName: feature.icon)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.accentPurple)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(feature.subtitle)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppTheme.textMuted)
                            }

                            Spacer()

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.accentGreen)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)

                        if i < features.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.04))
                                .frame(height: 0.5)
                                .padding(.leading, 70)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "0A0A0A"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 20)
                .opacity(featuresOpacity)

                Spacer()

                // Upgrade button
                VStack(spacing: 14) {
                    Button {
                        Superwall.shared.register(placement: "aura_main") {
                            onUnlocked()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                            Text("View Plans")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.goldBright, Color(hex: "FFA500")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: AppTheme.goldBright.opacity(0.3), radius: 12, y: 4)
                        )
                    }

                            }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                contentOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                featuresOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                buttonOpacity = 1
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}
