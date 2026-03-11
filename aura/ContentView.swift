import SwiftUI

struct ContentView: View {
    @Environment(HabitManager.self) private var manager
    @Environment(\.scenePhase) private var scenePhase
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                MainTabView()
                    .transition(.opacity)
            } else {
                LaunchScreenView(showMain: $showMain)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showMain)
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
