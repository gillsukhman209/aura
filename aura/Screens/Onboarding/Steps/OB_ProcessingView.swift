import SwiftUI

struct OB_ProcessingView: View {
    var vm: OnboardingViewModel
    @State private var line1Opacity: Double = 0
    @State private var line2Opacity: Double = 0
    @State private var line3Opacity: Double = 0

    private let lines = [
        "Calculating your discipline score...",
        "Mapping your improvement areas...",
        "Building your personalized plan..."
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                processingLine(lines[0], opacity: line1Opacity)
                processingLine(lines[1], opacity: line2Opacity)
                processingLine(lines[2], opacity: line3Opacity)
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                line1Opacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                line2Opacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.7)) {
                line3Opacity = 1
            }

            // Auto-advance after all lines shown
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                vm.next()
            }
        }
    }

    private func processingLine(_ text: String, opacity: Double) -> some View {
        HStack(spacing: 10) {
            if opacity > 0.5 {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.accentGreen)
                    .transition(.scale.combined(with: .opacity))
            } else {
                ProgressView()
                    .tint(AppTheme.textMuted)
                    .scaleEffect(0.8)
            }

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .opacity(max(0.3, opacity))
    }
}
