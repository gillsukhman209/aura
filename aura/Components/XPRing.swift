import SwiftUI

struct XPRing: View {
    let level: Int
    let currentXP: Int
    let maxXP: Int

    @State private var prog: CGFloat = 0
    @State private var pulse = false

    private let dia: CGFloat = 200
    private let sw: CGFloat = 10

    private var target: CGFloat { CGFloat(currentXP) / CGFloat(maxXP) }

    var body: some View {
        ZStack {
            // ── 1. Warm atmospheric haze ──
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.cloudWarm.opacity(pulse ? 0.12 : 0.06),
                            AppTheme.cloudWarm.opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: dia / 2 - 10,
                        endRadius: dia / 2 + 60
                    )
                )
                .frame(width: dia + 120, height: dia + 120)

            // ── 2. Deep track shadow ──
            Circle()
                .stroke(AppTheme.ringTrackDark, lineWidth: sw + 16)
                .frame(width: dia, height: dia)

            // ── 3. Track outer shadow ──
            Circle()
                .stroke(AppTheme.ringTrackShadow, lineWidth: sw + 11)
                .frame(width: dia, height: dia)

            // ── 4. Track body — angular metallic ──
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            AppTheme.ringTrackBody,
                            AppTheme.ringTrackBodyAlt,
                            Color(hex: "16161A"),
                            Color(hex: "0A0A0E"),
                            AppTheme.ringTrackBody,
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: sw + 3)
                )
                .frame(width: dia, height: dia)

            // ── 5. Track inner bevel ──
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.ringBevel.opacity(0.25), Color(hex: "060608").opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
                .frame(width: dia - sw - 3, height: dia - sw - 3)

            // ── 6. Track outer bevel ──
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "0A0A12").opacity(0.15), AppTheme.bgCardBorder.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
                .frame(width: dia + sw + 3, height: dia + sw + 3)

            // ── 7. Progress wide bloom ──
            Circle()
                .trim(from: 0, to: prog)
                .stroke(
                    AppTheme.ringGlowWide.opacity(0.20),
                    style: StrokeStyle(lineWidth: sw + 28, lineCap: .round)
                )
                .frame(width: dia, height: dia)
                .rotationEffect(.degrees(-90))
                .blur(radius: 20)

            // ── 8. Progress near-bloom ──
            Circle()
                .trim(from: 0, to: prog)
                .stroke(
                    AppTheme.ringGlow.opacity(0.40),
                    style: StrokeStyle(lineWidth: sw + 14, lineCap: .round)
                )
                .frame(width: dia, height: dia)
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)

            // ── 9. Main arc ──
            Circle()
                .trim(from: 0, to: prog)
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: AppTheme.arcBlueDeep, location: 0.00),
                            .init(color: AppTheme.arcBlue, location: 0.04),
                            .init(color: AppTheme.arcBlueBright, location: 0.12),
                            .init(color: AppTheme.arcBluePeak, location: 0.25),
                            .init(color: AppTheme.arcBlueMid, location: 0.40),
                            .init(color: AppTheme.arcBlueSoft1, location: 0.52),
                            .init(color: AppTheme.arcBlueSoft2, location: 0.62),
                            .init(color: AppTheme.arcFade, location: 0.70),
                            .init(color: AppTheme.arcTransition, location: 0.78),
                            .init(color: AppTheme.arcGoldStart, location: 0.86),
                            .init(color: AppTheme.arcGoldMid, location: 0.93),
                            .init(color: AppTheme.arcGoldEnd, location: 1.00),
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: sw, lineCap: .round)
                )
                .frame(width: dia, height: dia)
                .rotationEffect(.degrees(-90))

            // ── 10. Arc specular highlight ──
            Circle()
                .trim(from: 0, to: prog)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.14), .white.opacity(0.02)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 0.75, lineCap: .round)
                )
                .frame(width: dia + sw * 0.4, height: dia + sw * 0.4)
                .rotationEffect(.degrees(-90))

            // ── 11. Gold tip ──
            Circle()
                .fill(AppTheme.ringGoldTip)
                .frame(width: 5.5, height: 5.5)
                .shadow(color: AppTheme.ringGoldTip.opacity(0.9), radius: 2.5)
                .shadow(color: AppTheme.ringGoldTip.opacity(0.35), radius: 7)
                .offset(y: -(dia / 2))
                .rotationEffect(.degrees(Double(prog) * 360.0 - 90.0))
                .opacity(prog > 0.02 ? 1 : 0)

            // ── 12. Center text ──
            VStack(spacing: 0) {
                Text("LEVEL")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(AppTheme.textDim)
                    .tracking(6)

                Text("\(level)")
                    .font(.system(size: 58, weight: .thin, design: .serif))
                    .foregroundColor(AppTheme.textBright)
                    .shadow(color: .white.opacity(0.08), radius: 12)
                    .shadow(color: AppTheme.ringGlow.opacity(0.15), radius: 20)
                    .padding(.top, -6)
                    .padding(.bottom, -8)

                Text("\(currentXP) / \(maxXP)")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundColor(AppTheme.textGold)
                    .shadow(color: AppTheme.textGold.opacity(0.3), radius: 4)
                    .tracking(2)
            }
        }
        .frame(width: dia + 120, height: dia + 80)
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).delay(0.3)) {
                prog = target
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
