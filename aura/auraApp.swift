import SwiftUI
import SwiftData
import SuperwallKit

@main
struct auraApp: App {
    let modelContainer: ModelContainer
    let habitManager: HabitManager

    init() {
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

            // Request notification permission
            NotificationService.shared.requestPermission()

            // Configure Superwall
            Superwall.configure(apiKey: "YOUR_SUPERWALL_API_KEY")
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
