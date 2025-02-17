import SwiftUI
import SwiftData

@main
struct dungeon_lackeyApp: App {
    var sharedModelContainer: ModelContainer = {
        // Add Campaign to the schema array below
        let schema = Schema([
            Note.self,
            Tag.self,
            Campaign.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
