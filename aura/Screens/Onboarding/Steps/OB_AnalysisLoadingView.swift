import SwiftUI
import UIKit

struct OB_AnalysisLoadingView: View {
    var vm: OnboardingViewModel
    @State private var progress: Double = 0
    @State private var displayPercent: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Circular progress ring
            ZStack {
                // Track
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 150, height: 150)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppTheme.tabActive,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))

                // Percentage text
                Text("\(displayPercent)%")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }

            Text("Analyzing your responses...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 30)

            Spacer()
        }
        .onAppear {
            startAnalysis()
        }
    }

    private func startAnalysis() {
        let totalDuration = 3.0
        let steps = 100
        let interval = totalDuration / Double(steps)
        let lightImpact = UIImpactFeedbackGenerator(style: .light)
        let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        lightImpact.prepare()
        heavyImpact.prepare()

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                withAnimation(.linear(duration: interval)) {
                    progress = Double(i) / Double(steps)
                }
                displayPercent = i

                // Vibrate at intervals as it progresses
                if i % 10 == 0 {
                    lightImpact.impactOccurred()
                }

                // Heavy vibrate at completion
                if i == steps {
                    heavyImpact.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        vm.next()
                    }
                }
            }
        }
    }
}
