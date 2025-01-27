import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchQuery: String = ""
    @State private var filteredNotes: [Note] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search notes...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchQuery) { _ in
                        performSearch()
                    }
                
                // List of filtered notes
                List(filteredNotes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text("Date: \(note.date, formatter: dateFormatter)")
                            .font(.subheadline)
                        Text("Tags: \(note.tags.map { $0.name }.joined(separator: ", "))")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                .navigationTitle("Search Notes")
            }
        }
        .onAppear {
            loadNotes()
        }
    }
    
    private func performSearch() {
        guard !searchQuery.isEmpty else {
            filteredNotes = []
            return
        }
        
        let allNotes = try? modelContext.fetch(FetchDescriptor<Note>())
        
        filteredNotes = allNotes?.filter { note in
            let combinedString = """
            \(note.title.lowercased()) \
            \(dateFormatter.string(from: note.date).lowercased()) \
            \(note.tags.map { $0.name.lowercased() }.joined(separator: " "))
            """
            return combinedString.contains(searchQuery.lowercased())
        } ?? []
    }
    
    private func loadNotes() {
        // Load all notes initially or perform any setup logic here
        filteredNotes = (try? modelContext.fetch(FetchDescriptor<Note>())) ?? []
    }
}

// Formatter for displaying dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()



#Preview {
    SearchView()
}

