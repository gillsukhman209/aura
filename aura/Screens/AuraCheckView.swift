import SwiftUI

// MARK: - Standalone Shareable Card (no @Environment, works with ImageRenderer)

struct AuraShareCard: View {
    let rankName: String
    let rankImageName: String
    let rankColor: Color
    let globalLevel: Int
    let totalXP: Int
    let streak: Int
    let consistency: Int
    let bestStreak: Int
    let stats: [(name: String, icon: String, color: Color, value: Int)]
    let date: String

    var body: some View {
        VStack(spacing: 0) {
            // ── Rank Badge ──
            ZStack {
                // Ambient glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [rankColor.opacity(0.3), rankColor.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 260, height: 260)

                Image(rankImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: rankColor.opacity(0.6), radius: 24)
            }
            .padding(.top, 20)

            // ── Rank Title ──
            VStack(spacing: 6) {
                Text(rankName.uppercased())
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)
                    .tracking(3)
                    .shadow(color: rankColor.opacity(0.4), radius: 8)

                Text("LEVEL \(globalLevel)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(rankColor)
                    .tracking(3)
            }
            .padding(.top, 2)

            // ── Aura Points ──
            VStack(spacing: 4) {
                Text(formattedNumber(totalXP))
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "CCCCCC")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: rankColor.opacity(0.25), radius: 16)

                Text("AURA POINTS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color(hex: "444444"))
                    .tracking(5)
            }
            .padding(.top, 8)

            // ── Stats Grid ──
            VStack(spacing: 0) {
                // Top divider
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, rankColor.opacity(0.25), .clear],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                        HStack(spacing: 8) {
                            Image(systemName: stat.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(stat.color)
                                .frame(width: 18)
                            Text(stat.name)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "555555"))
                            Spacer()
                            Text("+\(stat.value)")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)

                // Bottom divider
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, rankColor.opacity(0.25), .clear],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }

            // ── Bottom Stats Row ──
            HStack(spacing: 0) {
                bottomStat(
                    icon: "flame.fill",
                    iconColor: Color(hex: "FF6B35"),
                    value: "\(streak)",
                    label: "STREAK"
                )
                bottomStat(
                    icon: nil,
                    iconColor: .clear,
                    value: "\(consistency)%",
                    label: "CONSISTENCY"
                )
                bottomStat(
                    icon: nil,
                    iconColor: .clear,
                    value: "\(bestStreak)",
                    label: "BEST STREAK"
                )
            }
            .padding(.vertical, 14)

            // ── Footer ──
            VStack(spacing: 6) {
                Rectangle()
                    .fill(Color(hex: "1A1A1A"))
                    .frame(height: 0.5)
                    .padding(.horizontal, 24)

                HStack {
                    Text("AURA")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(hex: "2A2A2A"))
                        .tracking(6)
                    Spacer()
                    Text(date)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(hex: "2A2A2A"))
                        .tracking(1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0D0D0D"),
                            Color(hex: "080808"),
                            Color(hex: "0A0A0A"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    rankColor.opacity(0.4),
                                    rankColor.opacity(0.1),
                                    rankColor.opacity(0.05),
                                    rankColor.opacity(0.15),
                                    rankColor.opacity(0.35),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: rankColor.opacity(0.12), radius: 40, y: 10)
                .shadow(color: .black.opacity(0.6), radius: 20)
        )
    }

    private func bottomStat(icon: String?, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(iconColor)
                }
                Text(value)
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .foregroundColor(Color(hex: "3A3A3A"))
                .tracking(2)
        }
        .frame(maxWidth: .infinity)
    }

    private func formattedNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - Main Screen

struct AuraCheckView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false

    private var shareCard: AuraShareCard {
        let info = manager.levelInfo
        let stats = manager.characterStats
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        return AuraShareCard(
            rankName: info.displayName,
            rankImageName: info.imageName,
            rankColor: info.color,
            globalLevel: info.globalLevel,
            totalXP: manager.totalXP,
            streak: manager.currentStreak,
            consistency: manager.consistencyScore,
            bestStreak: manager.longestStreak,
            stats: stats.map { (name: $0.name, icon: $0.icon, color: $0.color, value: $0.value) },
            date: formatter.string(from: appNow())
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: "111111")))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("AURA CHECK")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .tracking(4)

                    Spacer()

                    Button { renderAndShare() } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "888888"))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: "111111")))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // ── The Card ──
                shareCard
                    .padding(.horizontal, 28)
                    .scaleEffect(animateIn ? 1 : 0.85)
                    .opacity(animateIn ? 1 : 0)

                Spacer()

                // ── Share CTA ──
                Button { renderAndShare() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("SHARE YOUR AURA")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                    }
                    .foregroundColor(Color(hex: "555555"))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0A0A0A"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "1A1A1A"), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.15)) {
                animateIn = true
            }
        }
    }

    // MARK: - Share

    @MainActor
    private func renderAndShare() {
        let cardToRender = shareCard
            .padding(20)
            .background(Color.black)
            .frame(width: 400)

        let renderer = ImageRenderer(content: cardToRender)
        renderer.scale = 3.0

        guard let image = renderer.uiImage else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        // Walk to the topmost presented controller so it doesn't conflict with sheets
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        activityVC.popoverPresentationController?.sourceView = topVC.view
        topVC.present(activityVC, animated: true)
    }
}
