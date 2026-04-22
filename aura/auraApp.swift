import SwiftUI
import SwiftData
import SuperwallKit
import PostHog

@main
struct auraApp: App {
    let modelContainer: ModelContainer
    let habitManager: HabitManager

    init() {
        // Configure Firebase first — AuthService.bootstrap() depends on it.
        FirebaseService.shared.configure()
        AuthService.shared.bootstrap()

        do {
            let schema = Schema([
                Habit.self,
                HabitLog.self,
                UserProfile.self,
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            let container = try ModelContainer(
                for: schema,
                configurations: [config]
            )
            self.modelContainer = container

            // Seed UserProfile before creating HabitManager
            let context = container.mainContext
            let descriptor = FetchDescriptor<UserProfile>()
            let existing = try context.fetch(descriptor)
            if existing.isEmpty {
                let profile = UserProfile()
                context.insert(profile)
                try context.save()
            }

            self.habitManager = HabitManager(modelContext: context)

            // Configure PostHog analytics
            let phConfig = PostHogConfig(apiKey: "phc_5nCtyU7r4W6BaaVywCI3QA6mrkpoLw4eHnt5DGyt9ZM", host: "https://us.i.posthog.com")
            phConfig.captureScreenViews = true
            phConfig.captureApplicationLifecycleEvents = true
            PostHogSDK.shared.setup(phConfig)

            // Request notification permission
            NotificationService.shared.requestPermission()

            // Configure Superwall
            Superwall.configure(apiKey: "pk_tEFN-xARl1D3Cv-yil8CH") // Use your pk_ key from dashboard
            Superwall.shared.delegate = SubscriptionManager.shared
        } catch {
            fatalError("Failed to initialize app: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(habitManager)
        }
        .modelContainer(modelContainer)
    }
}
