import SwiftUI

// MARK: - Level Up Celebration

struct LevelUpOverlay: View {
    let levelInfo: LevelInfo
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var particleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                // Expanding ring burst
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(levelInfo.color.opacity(0.3), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Particles
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(levelInfo.color)
                            .frame(width: 4, height: 4)
                            .offset(y: -70)
                            .rotationEffect(.degrees(Double(i) * 45))
                            .scaleEffect(ringScale)
                            .opacity(particleOpacity)
                    }

                    // Badge icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [levelInfo.color.opacity(0.3), levelInfo.color.opacity(0.05), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 130, height: 130)

                        Image(levelInfo.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(color: levelInfo.color.opacity(0.6), radius: 15)
                    }
                    .scaleEffect(scale)
                }

                // Text
                VStack(spacing: 6) {
                    Text("RANK UP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(levelInfo.color)
                        .tracking(6)

                    Text(levelInfo.displayName)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Level \(levelInfo.globalLevel)")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(AppTheme.textMuted)
                }
                .offset(y: textOffset)
                .opacity(opacity)
            }
        }
        .onAppear {
            // Badge scale in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
            }
            // Ring burst
            withAnimation(.easeOut(duration: 0.8)) {
                ringScale = 2.5
                ringOpacity = 0.8
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                ringOpacity = 0
            }
            // Particles
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                particleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                particleOpacity = 0
            }
            // Text
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                opacity = 1
                textOffset = 0
            }
            // Auto-dismiss after 3s
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Daily Bonus Animation

struct DailyBonusOverlay: View {
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(glowPulse ? 0.2 : 0.08))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)

                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.gold, AppTheme.goldBright],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 10)
                }
                .scaleEffect(scale)

                Text("ALL QUESTS COMPLETE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.gold)
                    .tracking(4)

                Text("+40 Aura")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: AppTheme.gold.opacity(0.3), radius: 8)

                Text("Daily Completion Bonus")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Aura Lost Overlay

struct AuraLostOverlay: View {
    let amount: Int
    let onDismiss: () -> Void

    @State private var opacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentDanger.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .blur(radius: 15)

                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.accentDanger, AppTheme.accentDanger.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: AppTheme.accentDanger.opacity(0.5), radius: 10)
                }
                .scaleEffect(iconScale)
                .offset(x: shakeOffset)

                Text("AURA LOST")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.accentDanger)
                    .tracking(4)

                Text("-\(amount) Aura")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(AppTheme.accentDanger)

                Text("Streak broken — stay consistent!")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textMuted)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                opacity = 1
                iconScale = 1.0
            }
            // Shake effect
            withAnimation(.linear(duration: 0.06).repeatCount(6, autoreverses: true).delay(0.2)) {
                shakeOffset = 8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.1)) { shakeOffset = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
