import SwiftUI

struct StatBar: View {
    let stat: DisplayStat
    let isLast: Bool
    @State private var barFill: CGFloat = 0

    private var pct: CGFloat { min(CGFloat(stat.value) / CGFloat(max(1, stat.maxValue)), 1.0) }

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
                        .fill(stat.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(stat.color.opacity(0.10), lineWidth: 0.5)
                        )

                    Image(systemName: stat.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(stat.color)
                        .shadow(color: stat.color.opacity(0.3), radius: 3)
                }
                .padding(.trailing, 12)

                // ── Name + subtitle ──
                VStack(alignment: .leading, spacing: 2) {
                    Text(stat.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "C0C0C0"))

                    Text(stat.subtitle)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "444444"))
                        .tracking(1.5)
                }
                .frame(width: 95, alignment: .leading)

                // ── Bar ──
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Dark groove
                        Capsule()
                            .fill(Color(hex: "1A1A1A"))
                            .frame(height: 4)

                        // Glow layer behind fill
                        Capsule()
                            .fill(stat.color.opacity(0.3))
                            .frame(width: barFill * geo.size.width, height: 4)
                            .blur(radius: 6)
                            .opacity(0.5)

                        // Fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        stat.color.opacity(0.5),
                                        stat.color.opacity(0.7),
                                        stat.color,
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: barFill * geo.size.width, height: 4)
                            .shadow(color: stat.color.opacity(0.4), radius: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 6)

                // ── Value ──
                Text("\(stat.value)")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(Color(hex: "F0F0F0"))
                    .frame(width: 34, alignment: .trailing)
            }
            .padding(.vertical, 13)

            // ── Divider ──
            if !isLast {
                Rectangle()
                    .fill(Color(hex: "1A1A1A"))
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
