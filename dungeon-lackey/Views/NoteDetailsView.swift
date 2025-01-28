import SwiftUI
import SwiftData

struct NoteDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext // SwiftData context

    @Bindable var note: Note // Bindable ensures changes are tracked
    @State private var showDeleteConfirmation: Bool = false // Controls the delete confirmation dialog

    var body: some View {
        VStack {
            // Header Section
            VStack(alignment: .leading, spacing: 8) {
                TextField("Note Title", text: $note.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text("Created")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 70, alignment: .leading)
                        Text(note.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "tag")
                            .foregroundColor(.gray)
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 70, alignment: .leading)
                        Text(note.tags.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Divider()
            }
            .padding(.horizontal)

            // Content Section
            ZStack(alignment: .topLeading) {
                if note.content.isEmpty {
                    Text("Write your note here...")
                        .foregroundColor(.gray)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                TextEditor(text: $note.content)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(4)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle(note.title)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this note?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Note", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onDisappear {
            saveNote()
        }
    }

    private func saveNote() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save the note: \(error.localizedDescription)")
        }
    }

    private func deleteNote() {
        modelContext.delete(note)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete the note: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NoteDetailsView(note: Note(title: "Sample Note", date: Date(), content: "This is a sample note."))
}
