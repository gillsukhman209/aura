import SwiftUI
import SuperwallKit

struct ContentView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("morningRoastHour") private var morningHour = 9
    @AppStorage("morningRoastMinute") private var morningMinute = 0
    @AppStorage("eveningRoastHour") private var eveningHour = 20
    @AppStorage("eveningRoastMinute") private var eveningMinute = 0
    @AppStorage("roastIntensity") private var intensityRaw = RoastIntensity.brutal.rawValue
    @AppStorage("inactivityRoasts") private var inactivityEnabled = true
    @State private var showMain = false
    @State private var showReviewRequest = false

    private var isPaid: Bool {
        Superwall.shared.subscriptionStatus.isActive
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        hasCompletedOnboarding = true
                    }
                    showPaywallGate()
                }
                .transition(.opacity)
            } else if isPaid && showMain {
                MainTabView()
                    .transition(.opacity)
            } else if isPaid && !showMain {
                LaunchScreenView(showMain: $showMain)
                    .transition(.opacity)
            } else {
                // Not paid — show locked screen
                LockedView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showMain = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showMain)
        .animation(.easeInOut(duration: 0.6), value: hasCompletedOnboarding)
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                manager.performDayReset()
                rescheduleNotifications()
                NotificationService.shared.cancelInactivityRoasts()
            case .background:
                let intensity = RoastIntensity(rawValue: intensityRaw) ?? .brutal
                NotificationService.shared.scheduleInactivityRoasts(
                    rank: manager.levelInfo.displayName,
                    intensity: intensity,
                    enabled: notificationsEnabled && inactivityEnabled
                )
            default:
                break
            }
        }
        .onAppear {
            manager.performDayReset()
            rescheduleNotifications()
        }
        .onChange(of: manager.shouldRequestReview) { _, shouldRequest in
            if shouldRequest {
                showReviewRequest = true
                manager.dismissReviewRequest()
            }
        }
        .fullScreenCover(isPresented: $showReviewRequest) {
            ReviewRequestView(isPresented: $showReviewRequest)
        }
    }

    private func showPaywallGate() {
        Superwall.shared.register(placement: "aura_main")
    }

    private func rescheduleNotifications() {
        let today = appNow()
        let todaysHabits = manager.todaysHabits
        let incompleteNames = todaysHabits.filter { !$0.isCompleted(on: today) }.map(\.name)
        let intensity = RoastIntensity(rawValue: intensityRaw) ?? .brutal

        NotificationService.shared.rescheduleAll(
            habitCount: todaysHabits.count,
            completedCount: manager.completedTodayCount,
            habitNames: incompleteNames,
            streak: manager.currentStreak,
            bestStreak: manager.longestStreak,
            rank: manager.levelInfo.displayName,
            consistency: manager.consistencyScore,
            discipline: manager.statValue(for: .discipline),
            allCompleted: manager.allTodayCompleted,
            morningHour: morningHour,
            morningMinute: morningMinute,
            eveningHour: eveningHour,
            eveningMinute: eveningMinute,
            intensity: intensity,
            enabled: notificationsEnabled,
            inactivityEnabled: inactivityEnabled
        )
    }
}
