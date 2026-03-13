import SwiftUI

struct AuraCheckView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    @State private var showShareTip = false

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

                    // Share button
                    Button {
                        shareAuraCard()
                    } label: {
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
                auraCard
                    .scaleEffect(animateIn ? 1 : 0.8)
                    .opacity(animateIn ? 1 : 0)

                Spacer()

                Text("Screenshot to share your aura")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                    .tracking(1)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - The Aura Card

    private var auraCard: some View {
        let info = manager.levelInfo
        let stats = manager.characterStats

        return VStack(spacing: 20) {
            // ── Rank badge ──
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [info.color.opacity(0.25), info.color.opacity(0.05), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)

                Image(info.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .shadow(color: info.color.opacity(0.5), radius: 10)
            }

            // ── Rank name ──
            VStack(spacing: 4) {
                Text(info.displayName.uppercased())
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .tracking(2)

                Text("LEVEL \(info.globalLevel)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(info.color)
                    .tracking(2)
            }

            // ── Aura Score ──
            VStack(spacing: 2) {
                Text("\(manager.totalXP)")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: info.color.opacity(0.3), radius: 12)
                Text("AURA POINTS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "555555"))
                    .tracking(4)
            }

            // ── Divider ──
            Rectangle()
                .fill(LinearGradient(colors: [.clear, info.color.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 0.5)
                .padding(.horizontal, 20)

            // ── Stats grid ──
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(stats) { stat in
                    HStack(spacing: 8) {
                        Image(systemName: stat.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(stat.color)
                            .frame(width: 20)
                        Text(stat.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "666666"))
                        Spacer()
                        Text("+\(stat.value)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 8)

            // ── Divider ──
            Rectangle()
                .fill(LinearGradient(colors: [.clear, info.color.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 0.5)
                .padding(.horizontal, 20)

            // ── Bottom stats row ──
            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.accentOrange)
                        Text("\(manager.currentStreak)")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("STREAK")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                        .tracking(2)
                }

                VStack(spacing: 2) {
                    Text("\(manager.consistencyScore)%")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    Text("CONSISTENCY")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                        .tracking(2)
                }

                VStack(spacing: 2) {
                    Text("\(manager.longestStreak)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    Text("BEST STREAK")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                        .tracking(2)
                }
            }

            // ── Branding ──
            Text("AURA")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(Color(hex: "333333"))
                .tracking(6)
                .padding(.top, 4)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0A0A0A"),
                            Color(hex: "0E0E0E"),
                            Color(hex: "080808"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [info.color.opacity(0.3), info.color.opacity(0.1), info.color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: info.color.opacity(0.15), radius: 30)
                .shadow(color: .black.opacity(0.5), radius: 20)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Share

    @MainActor
    private func shareAuraCard() {
        let renderer = ImageRenderer(content:
            auraCard
                .frame(width: 360)
                .environment(\.colorScheme, .dark)
        )
        renderer.scale = 3.0

        guard let image = renderer.uiImage else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
