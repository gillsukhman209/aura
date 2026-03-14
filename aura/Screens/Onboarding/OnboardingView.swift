import SwiftUI

struct OnboardingView: View {
    let onComplete: ([SuggestedHabit]) -> Void
    @State private var vm = OnboardingViewModel()
    @State private var direction: Int = 1 // 1 = forward, -1 = back
    @State private var previousStep: Int = 0

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 200)

            VStack(spacing: 0) {
                // DEBUG: Skip entire onboarding
                #if DEBUG
                HStack {
                    Spacer()
                    Button("Skip All") {
                        onComplete([])
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textSubtle)
                    .padding(.trailing, 16)
                    .padding(.top, 4)
                }
                #endif
                // MARK: - Top Bar (progress + back + XP)
                if vm.showProgressBar || vm.showBackButton {
                    HStack(spacing: 12) {
                        // Back button
                        if vm.showBackButton {
                            Button {
                                vm.back()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }

                        // Progress bar
                        if vm.showProgressBar {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 5)

                                    Capsule()
                                        .fill(AppTheme.tabActive)
                                        .frame(width: max(0, geo.size.width * progressFraction), height: 5)
                                        .animation(.easeInOut(duration: 0.3), value: vm.currentStep)
                                }
                            }
                            .frame(height: 5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }

                // MARK: - Step Content
                ZStack {
                    stepView
                        .id(vm.currentStep)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: direction > 0 ? .trailing : .leading).combined(with: .opacity),
                                removal: .move(edge: direction > 0 ? .leading : .trailing).combined(with: .opacity)
                            )
                        )
                }
                .animation(.easeInOut(duration: 0.35), value: vm.currentStep)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: vm.currentStep) { oldValue, newValue in
            direction = newValue > oldValue ? 1 : -1
        }
    }

    private var progressFraction: CGFloat {
        // Steps 1-18 show progress bar; map to 0...1
        guard vm.totalSteps > 2 else { return 0 }
        return CGFloat(vm.currentStep) / CGFloat(vm.totalSteps - 1)
    }

    @ViewBuilder
    private var stepView: some View {
        switch vm.currentStep {
        case 0:  OB_WelcomeView(vm: vm)
        case 1:  OB_SatisfactionView(vm: vm)
        case 2:  OB_LifeGoalView(vm: vm)
        case 3:  OB_DistractionsView(vm: vm)
        case 4:  OB_ImpactView(vm: vm)
        case 5:  OB_SymptomsView(vm: vm)
        case 6:  OB_QuitHabitsView(vm: vm)
        case 7:  OB_RoutineView(vm: vm)
        case 8:  OB_ProductivityView(vm: vm)
        case 9:  OB_SleepView(vm: vm)
        case 10: OB_ExerciseView(vm: vm)
        case 11: OB_RebootView(vm: vm)
        case 12: OB_AnalysisLoadingView(vm: vm)
        case 13: OB_ProcessingView(vm: vm)
        case 14: OB_ResultsView(vm: vm)
        case 15: OB_PotentialGraphView(vm: vm)
        case 16: OB_MotivationView(vm: vm)
        case 17: OB_SocialProofView(vm: vm)
        case 18: OB_AchievementView(vm: vm)
        case 19: OB_StarterPlanView(vm: vm)
        case 20: OB_FinalView(vm: vm) { onComplete(vm.selectedStarterHabits) }
        default: EmptyView()
        }
    }
}

// MARK: - XP Badge
struct OnboardingXPBadge: View {
    let xp: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.goldBright)
            Text("\(xp) XP")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.bgCard)
                .overlay(
                    Capsule()
                        .stroke(AppTheme.bgCardBorder, lineWidth: 1)
                )
        )
        .contentTransition(.numericText())
    }
}

// MARK: - Reusable Option Card (single-select)
struct OnboardingOptionCard: View {
    let index: Int
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text("\(index + 1).")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(AppTheme.tabActive)
                    .frame(width: 24)

                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.tabActive.opacity(0.15) : AppTheme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? AppTheme.tabActive.opacity(0.7) : AppTheme.tabActive.opacity(0.25),
                                lineWidth: isSelected ? 1.5 : 0.8
                            )
                    )
            )
            .shadow(color: isSelected ? AppTheme.tabActive.opacity(0.2) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reusable Checklist Item (multi-select)
struct OnboardingChecklistItem: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(isSelected ? AppTheme.tabActive : Color.clear)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppTheme.tabActive : Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .overlay(
                        isSelected ?
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        : nil
                    )

                Text(text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? AppTheme.tabActive.opacity(0.5) : AppTheme.bgCardBorder,
                                lineWidth: 0.8
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom Action Button
struct OnboardingNextButton: View {
    let title: String
    var isEnabled: Bool = true
    var style: OnboardingButtonStyle = .filled
    let action: () -> Void

    enum OnboardingButtonStyle {
        case filled      // Blue filled
        case white       // White filled (welcome screen)
        case danger      // Red filled
    }

    private var bgColor: Color {
        switch style {
        case .filled: return AppTheme.tabActive
        case .white: return .white
        case .danger: return AppTheme.accentDanger
        }
    }

    private var textColor: Color {
        switch style {
        case .filled: return AppTheme.bgPure
        case .white: return AppTheme.bgPure
        case .danger: return .white
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? textColor : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isEnabled ? bgColor : Color.white.opacity(0.1))
                )
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}
