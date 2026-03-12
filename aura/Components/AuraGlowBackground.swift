import SwiftUI

/// Ambient energy glow behind the main content — brightens with level/tier.
struct AuraGlowBackground: View {
    let levelInfo: LevelInfo
    let intensity: CGFloat

    @State private var pulse = false

    /// Higher tiers glow more strongly.
    private var tierBrightness: CGFloat {
        let base: CGFloat = 0.06
        let tierBoost = CGFloat(levelInfo.tier.rawValue) * 0.02 // 0.00 → 0.14
        return base + tierBoost
    }

    var body: some View {
        ZStack {
            // Primary radial glow from center-top
            RadialGradient(
                colors: [
                    levelInfo.color.opacity(tierBrightness * intensity * (pulse ? 1.15 : 1.0)),
                    levelInfo.color.opacity(tierBrightness * 0.4 * intensity),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.2),
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            // Secondary softer glow lower
            RadialGradient(
                colors: [
                    levelInfo.color.opacity(tierBrightness * 0.3 * intensity),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.55),
                startRadius: 10,
                endRadius: 250
            )
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
