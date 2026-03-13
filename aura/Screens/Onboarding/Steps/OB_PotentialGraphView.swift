import SwiftUI

struct OB_PotentialGraphView: View {
    var vm: OnboardingViewModel
    @State private var showGraph = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Your Journey Starts Now")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Graph card
            VStack(spacing: 0) {
                HStack {
                    Text("Discipline Path")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("AURA")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .tracking(2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Graph area
                ZStack {
                    DisciplinePathGraph(animate: showGraph)
                }
                .frame(height: 160)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // X-axis labels
                HStack {
                    Text("Week 1")
                    Spacer()
                    Text("Week 2")
                    Spacer()
                    Text("Week 3")
                }
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textMuted)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.bgCardBorder, lineWidth: 0.8)
                    )
            )
            .padding(.horizontal, 50)
            .padding(.top, 30)

            Spacer()

            Text("Become the person you always knew you could be.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            OnboardingNextButton(title: "Start Your Journey") {
                vm.next()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                showGraph = true
            }
        }
    }
}

struct DisciplinePathGraph: View {
    let animate: Bool

    // "With Aura" line — curves upward
    private let withAuraPoints: [CGPoint] = [
        CGPoint(x: 0.0, y: 0.7),
        CGPoint(x: 0.15, y: 0.65),
        CGPoint(x: 0.3, y: 0.55),
        CGPoint(x: 0.45, y: 0.45),
        CGPoint(x: 0.6, y: 0.35),
        CGPoint(x: 0.75, y: 0.25),
        CGPoint(x: 0.9, y: 0.15),
        CGPoint(x: 1.0, y: 0.1)
    ]

    // "Without" line — stays flat / declines
    private let withoutPoints: [CGPoint] = [
        CGPoint(x: 0.0, y: 0.7),
        CGPoint(x: 0.12, y: 0.68),
        CGPoint(x: 0.25, y: 0.72),
        CGPoint(x: 0.38, y: 0.75),
        CGPoint(x: 0.5, y: 0.73),
        CGPoint(x: 0.62, y: 0.78),
        CGPoint(x: 0.75, y: 0.82),
        CGPoint(x: 0.88, y: 0.8),
        CGPoint(x: 1.0, y: 0.85)
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // "With Aura" green line
                Path { path in
                    let points = withAuraPoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(AppTheme.accentGreen, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                // Label
                if animate {
                    Text("With Aura")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.accentGreen)
                        .position(x: w * 0.82, y: h * 0.08)
                }

                // "Without" red dotted line
                Path { path in
                    let points = withoutPoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(AppTheme.accentDanger, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 4]))

                // Label
                if animate {
                    Text("Without\nAura")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(AppTheme.accentDanger)
                        .multilineTextAlignment(.center)
                        .position(x: w * 0.88, y: h * 0.88)
                }

                // Endpoint dots
                if animate {
                    Circle()
                        .fill(AppTheme.accentGreen)
                        .frame(width: 8, height: 8)
                        .position(x: w, y: h * 0.1)

                    Circle()
                        .fill(AppTheme.accentDanger)
                        .frame(width: 8, height: 8)
                        .position(x: w, y: h * 0.85)
                }
            }
        }
    }
}
