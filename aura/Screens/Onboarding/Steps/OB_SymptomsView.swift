import SwiftUI

struct OB_SymptomsView: View {
    var vm: OnboardingViewModel

    private let mentalSymptoms = [
        "Feeling unmotivated",
        "Lack of ambition to pursue goals",
        "Difficulty concentrating",
        "Poor memory or brain fog",
        "General anxiety"
    ]

    private let physicalSymptoms = [
        "Chronic tiredness or fatigue",
        "Sleep problems",
        "Headaches or muscle tension"
    ]

    private let socialSymptoms = [
        "Social withdrawal",
        "Irritability",
        "Relationship strain"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Symptoms")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)

            // Warning banner
            Text("Procrastination can have serious negative impacts psychologically.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.accentDanger.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.accentDanger.opacity(0.5), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.top, 14)

            Text("Select all symptoms you've been experiencing:")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 12)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    symptomSection(title: "Mental", symptoms: mentalSymptoms)
                    symptomSection(title: "Physical", symptoms: physicalSymptoms)
                    symptomSection(title: "Social", symptoms: socialSymptoms)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }

            Spacer()

            OnboardingNextButton(title: "Reboot my brain", style: .danger) {
                vm.next()
            }
        }
    }

    @ViewBuilder
    private func symptomSection(title: String, symptoms: [String]) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            ForEach(symptoms, id: \.self) { symptom in
                OnboardingChecklistItem(
                    text: symptom,
                    isSelected: vm.selectedSymptoms.contains(symptom)
                ) {
                    if vm.selectedSymptoms.contains(symptom) {
                        vm.selectedSymptoms.remove(symptom)
                    } else {
                        vm.selectedSymptoms.insert(symptom)
                    }
                }
            }
        }
    }
}
