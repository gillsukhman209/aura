import SwiftUI

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

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView { selectedHabits in
                    createStarterHabits(selectedHabits)
                    withAnimation(.easeInOut(duration: 0.6)) {
                        hasCompletedOnboarding = true
                        showMain = true
                    }
                }
                .transition(.opacity)
            } else if showMain {
                MainTabView()
                    .transition(.opacity)
            } else {
                LaunchScreenView(showMain: $showMain)
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
    }

    private func createStarterHabits(_ habits: [SuggestedHabit]) {
        for habit in habits {
            manager.createHabit(
                name: habit.name,
                type: habit.type,
                icon: habit.icon,
                difficulty: habit.difficulty,
                stat: habit.stat,
                schedule: habit.schedule,
                targetValue: habit.targetValue,
                unit: habit.unit
            )
        }
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
