import SwiftUI

struct FallingStar: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: CGFloat // points per second
}

struct StarfieldBackground: View {
    @State private var stars: [FallingStar] = []
    @State private var drift: CGFloat = 0
    let starCount: Int

    init(starCount: Int = 200) {
        self.starCount = starCount
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate

                Canvas { context, size in
                    for star in stars {
                        // Calculate current Y with wrap-around
                        let cycle = Double(h + 40) / Double(star.speed)
                        let progress = now.truncatingRemainder(dividingBy: cycle) / cycle
                        let currentY = (star.y + CGFloat(progress) * (h + 40)).truncatingRemainder(dividingBy: h + 40) - 20

                        let rect = CGRect(
                            x: star.x - star.size / 2,
                            y: currentY - star.size / 2,
                            width: star.size,
                            height: star.size
                        )
                        context.opacity = star.opacity
                        context.fill(Circle().path(in: rect), with: .color(.white))

                        // Glow for bigger stars
                        if star.size > 1.2 {
                            let glowRect = CGRect(
                                x: star.x - star.size * 2,
                                y: currentY - star.size * 2,
                                width: star.size * 4,
                                height: star.size * 4
                            )
                            context.opacity = star.opacity * 0.2
                            context.fill(Circle().path(in: glowRect), with: .color(.white))
                        }
                    }
                }
            }

            // ── Galaxy clouds with drift ──
            ZStack {
                // 1. Purple-blue cloud upper-right
                Ellipse()
                    .fill(AppTheme.cloudWarm)
                    .frame(width: 550, height: 380)
                    .blur(radius: 90)
                    .opacity(0.55)
                    .rotationEffect(.degrees(-25))
                    .position(x: w * 0.75 + drift * 8, y: h * 0.05 + drift * 3)

                // 2. Cool indigo upper-left
                Ellipse()
                    .fill(AppTheme.cloudCool)
                    .frame(width: 500, height: 320)
                    .blur(radius: 80)
                    .opacity(0.60)
                    .rotationEffect(.degrees(10))
                    .position(x: w * 0.18 - drift * 6, y: h * 0.10 + drift * 2)

                // 3. Purple haze behind ring
                Circle()
                    .fill(AppTheme.cloudWisp)
                    .frame(width: 320, height: 320)
                    .blur(radius: 65)
                    .opacity(0.40)
                    .position(x: w * 0.5 + drift * 4, y: h * 0.18)

                // 4. Wisp
                Ellipse()
                    .fill(AppTheme.cloudWisp)
                    .frame(width: 280, height: 50)
                    .blur(radius: 25)
                    .opacity(0.35)
                    .rotationEffect(.degrees(-40))
                    .position(x: w * 0.6 - drift * 5, y: h * 0.04)

                // 5. Mid purple
                Ellipse()
                    .fill(AppTheme.cloudWarm)
                    .frame(width: 350, height: 200)
                    .blur(radius: 70)
                    .opacity(0.30)
                    .position(x: w * 0.55 + drift * 6, y: h * 0.38 - drift * 2)

                // 6. Lower cool
                Ellipse()
                    .fill(AppTheme.cloudCool)
                    .frame(width: 450, height: 250)
                    .blur(radius: 80)
                    .opacity(0.30)
                    .position(x: w * 0.4 - drift * 4, y: h * 0.72 + drift * 2)
            }
            .allowsHitTesting(false)

            // ── Init ──
            Color.clear
                .onAppear {
                    stars = (0..<starCount).map { _ in
                        let r = Double.random(in: 0...1)
                        let isBright = r > 0.80
                        return FallingStar(
                            x: CGFloat.random(in: 0...w),
                            y: CGFloat.random(in: 0...h),
                            size: isBright ? CGFloat.random(in: 1.4...2.5) : CGFloat.random(in: 0.4...1.2),
                            opacity: isBright ? Double.random(in: 0.6...1.0) : Double.random(in: 0.12...0.4),
                            speed: CGFloat.random(in: 8...25)
                        )
                    }
                    withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                        drift = 1
                    }
                }
        }
        .background(AppTheme.bgPure)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
