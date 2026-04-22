import SwiftUI
import SuperwallKit

struct ContentView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.scenePhase) private var scenePhase
    private var auth = AuthService.shared
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

    private var subscription = SubscriptionManager.shared

    /// Main UI is gated until the user claims a username (anonymous auth is fine,
    /// but we need a handle to enable the friends system).
    private var needsUsername: Bool {
        auth.isReady && auth.currentUsername == nil
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        hasCompletedOnboarding = true
                    }
                    showPaywallGate()
                    // Kick off the first-launch tutorial once the main UI appears.
                    TutorialCoordinator.shared.startIfNeeded()
                }
                .transition(.opacity)
            } else if !auth.isReady {
                ZStack {
                    AppTheme.bgPure.ignoresSafeArea()
                    ProgressView().tint(.white)
                }
                .transition(.opacity)
            } else if needsUsername {
                UsernameSetupView {
                    startFriendsServices()
                }
                .transition(.opacity)
            } else if subscription.isPaidUser {
                MainTabView()
                    .transition(.opacity)
                    .onAppear {
                        startFriendsServices()
                        // Covers users who completed onboarding pre-tutorial update.
                        TutorialCoordinator.shared.startIfNeeded()
                    }
            } else {
                // Not paid — show locked screen
                LockedView {
                    // Will auto-navigate when subscription.isPaidUser becomes true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: subscription.isPaidUser)
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
        #if DEBUG
        return
        #else
        Superwall.shared.register(placement: "aura_main")
        #endif
    }

    private func startFriendsServices() {
        guard let uid = auth.currentUID else { return }
        FriendService.shared.start(forUID: uid)
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
