import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchQuery: String = ""
    @State private var filteredNotes: [Note] = []
    
    var body: some View {
        VStack {
            // Beautified Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search notes...", text: $searchQuery)
                    .onChange(of: searchQuery) { _ in
                        performSearch()
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray6))
            )
            .padding(.horizontal)

            // List or Placeholder
            if filteredNotes.isEmpty {
                VStack {
                    Text("PAGE ***NOT*** FOUND")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("""
                    We live in a world of uncertainty. But certainly, the note you were looking for isn't here. \
                    Perhaps the halfling has stolen it and hidden it in another place. \
                    Try searching for what you were looking for in another realm.
                    """)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .padding()
            } else {
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
            }

            Spacer()
        }
        .navigationTitle("Search Notes")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            loadNotes()
        }
        BottomNavigationBar()
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
