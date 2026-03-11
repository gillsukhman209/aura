import SwiftUI
import SwiftData

@main
struct auraApp: App {
    let modelContainer: ModelContainer
    @State private var habitManager: HabitManager?

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
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    seedUserProfileIfNeeded()
                    if habitManager == nil {
                        habitManager = HabitManager(modelContext: modelContainer.mainContext)
                    }
                }
                .environment(habitManager)
        }
        .modelContainer(modelContainer)
    }

    private func seedUserProfileIfNeeded() {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<UserProfile>()

        do {
            let existing = try context.fetch(descriptor)
            if existing.isEmpty {
                let profile = UserProfile()
                context.insert(profile)
                try context.save()
            }
        } catch {
            print("Failed to seed UserProfile: \(error)")
        }
    }
}
