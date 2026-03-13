import SwiftUI

struct ContentView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showMain = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
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
            if newPhase == .active {
                manager.performDayReset()
            }
        }
        .onAppear {
            manager.performDayReset()
        }
    }
}
