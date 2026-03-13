import SwiftUI

struct OB_ResultsView: View {
    var vm: OnboardingViewModel
    @State private var showBars = false
    @State private var showText = false

    var body: some View {
        VStack(spacing: 0) {
            // Heading
            HStack(spacing: 0) {
                Text("We got some ")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("BAD")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.accentDanger)
                Text(" news...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 30)

            Text("Your responses show \(vm.scoreComparison)% **more** signs of poor lifestyle habits than the average 18 to 24 year old")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 10)

            Spacer()

            // Bar chart
            HStack(alignment: .bottom, spacing: 40) {
                // Your Score bar
                VStack(spacing: 8) {
                    Text("\(vm.disciplineScore)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.accentDanger)
                        .frame(width: 70, height: showBars ? CGFloat(vm.disciplineScore) * 2.5 : 0)

                    Text("Your Score")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                }

                // Average bar
                VStack(spacing: 8) {
                    Text("12%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.accentGreen)
                        .frame(width: 70, height: showBars ? 30 : 0)

                    Text("Average")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showBars)

            Spacer()

            // Body text
            if showText {
                Text("This is normal. People in your age group often face extra challenges with self-commitment.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity)
            }

            Spacer()

            // Disclaimer
            Text("\"This is only an observation, not a guarantee. Please seek a medical professional for actual results.\"")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textSubtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 8)

            OnboardingNextButton(title: "Let's Go", style: .white) {
                vm.next()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showBars = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.2)) {
                showText = true
            }
        }
    }
}
