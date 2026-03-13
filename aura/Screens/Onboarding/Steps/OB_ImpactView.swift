import SwiftUI

struct OB_ImpactView: View {
    var vm: OnboardingViewModel
    @State private var animatedYears: Int = 0
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Your distractions can cost you")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            // Big red number
            Text("\(animatedYears) years")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(AppTheme.accentDanger)
                .padding(.top, 20)
                .contentTransition(.numericText())

            Text("in an average lifetime")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 4)

            Spacer()
                .frame(height: 60)

            // Achievement text
            if showDetails {
                VStack(spacing: 4) {
                    HStack(spacing: 0) {
                        Text("With ")
                            .foregroundColor(AppTheme.textMuted)
                        Text("\(Int(vm.distractionHours)) hours every week")
                            .foregroundColor(AppTheme.accentDanger)
                        Text(", you could have")
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .font(.system(size: 14))

                    Text(vm.impactAchievement + ".")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .transition(.opacity.combined(with: .offset(y: 10)))
            }

            Spacer()

            OnboardingNextButton(title: "Next") {
                vm.next()
            }
        }
        .onAppear {
            // Animated count-up
            animatedYears = 0
            let target = vm.yearsLost
            let duration = 1.5
            let steps = min(target, 30)
            let interval = duration / Double(steps)

            for i in 1...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        animatedYears = Int(Double(target) * Double(i) / Double(steps))
                    }
                }
            }

            withAnimation(.easeOut(duration: 0.6).delay(1.8)) {
                showDetails = true
            }
        }
    }
}
