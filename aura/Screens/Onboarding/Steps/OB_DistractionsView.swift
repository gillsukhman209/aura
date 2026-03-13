import SwiftUI

struct OB_DistractionsView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("How many hours a week do you waste on distractions in life?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 30)

            Text("Eg. doom scrolling, procrastinating...")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 8)

            Spacer()

            // Gauge visualization
            DistractionGauge(hours: Int(vm.distractionHours))
                .frame(width: 260, height: 180)

            Spacer()
                .frame(height: 50)

            // Slider
            Slider(value: $vm.distractionHours, in: 1...40, step: 1)
                .tint(AppTheme.accentDanger)
                .padding(.horizontal, 30)

            Spacer()

            OnboardingNextButton(title: "Next") {
                vm.next()
            }
        }
    }
}

// Semi-circular gauge
struct DistractionGauge: View {
    let hours: Int

    private var fraction: Double {
        Double(hours) / 40.0
    }

    var body: some View {
        ZStack {
            // Background arc with tick marks
            ForEach(0..<30, id: \.self) { i in
                let angle = Angle.degrees(180.0 + (Double(i) / 29.0) * 180.0)
                let isFilled = Double(i) / 29.0 <= fraction
                Rectangle()
                    .fill(isFilled ? AppTheme.accentDanger : Color.white.opacity(0.2))
                    .frame(width: 3, height: isFilled ? 18 : 12)
                    .offset(y: -100)
                    .rotationEffect(angle)
            }

            // Center circle
            Circle()
                .fill(AppTheme.bgCard)
                .frame(width: 110, height: 110)
                .overlay(
                    Circle()
                        .stroke(AppTheme.accentDanger.opacity(0.3), lineWidth: 1)
                )

            // Value text
            Text("\(hours)h")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(AppTheme.accentDanger)
        }
    }
}
