import SwiftUI

struct StatBar: View {
    let stat: DisplayStat
    let isLast: Bool
    @State private var barFill: CGFloat = 0

    private var pct: CGFloat { CGFloat(stat.value) / CGFloat(stat.maxValue) }

    init(stat: DisplayStat, isLast: Bool = false) {
        self.stat = stat
        self.isLast = isLast
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // ── Icon ──
                ZStack {
                    Circle()
                        .fill(stat.color.opacity(0.18))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(stat.color.opacity(0.15), lineWidth: 0.5)
                        )
                    Circle()
                        .fill(stat.color.opacity(0.08))
                        .frame(width: 40, height: 40)
                        .blur(radius: 5)

                    Image(systemName: stat.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(stat.color)
                        .shadow(color: stat.color.opacity(0.4), radius: 3)
                }
                .padding(.trailing, 12)

                // ── Name + subtitle ──
                VStack(alignment: .leading, spacing: 2) {
                    Text(stat.name)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(AppTheme.textStat)
                        .shadow(color: .white.opacity(0.05), radius: 4)

                    Text(stat.subtitle)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(AppTheme.textSubtle)
                        .tracking(1.5)
                }
                .frame(width: 95, alignment: .leading)

                // ── Bar ──
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Dark groove
                        Capsule()
                            .fill(AppTheme.barGroove)
                            .frame(height: 4)
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.barGrooveBorder, lineWidth: 0.5)
                            )

                        // Glow layer behind fill
                        Capsule()
                            .fill(AppTheme.barGlow)
                            .frame(width: barFill * geo.size.width, height: 4)
                            .blur(radius: 6)
                            .opacity(0.5)

                        // Luminous fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.barFillStart,
                                        AppTheme.barFillMid1,
                                        AppTheme.barFillMid2,
                                        AppTheme.barFillEnd,
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barFill * geo.size.width, height: 4)
                            .shadow(color: AppTheme.barGlow.opacity(0.8), radius: 4)
                            .shadow(color: AppTheme.barGlow.opacity(0.3), radius: 12)

                        // Hot-edge specular
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.barHotEdge.opacity(0.0),
                                        AppTheme.barHotEdge.opacity(0.5),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barFill * geo.size.width, height: 1)
                            .offset(y: -1.5)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 6)

                // ── Value ──
                Text("\(stat.value)")
                    .font(.custom("Georgia-Bold", size: 17))
                    .foregroundColor(AppTheme.textBright)
                    .shadow(color: AppTheme.ringGlow.opacity(0.2), radius: 4)
                    .frame(width: 34, alignment: .trailing)
            }
            .padding(.vertical, 13)

            // ── Divider ──
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AppTheme.dividerColor.opacity(0.6), AppTheme.dividerColor.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
                    .padding(.leading, 52)
                    .padding(.trailing, 4)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.1).delay(0.25)) {
                barFill = pct
            }
        }
    }
}
