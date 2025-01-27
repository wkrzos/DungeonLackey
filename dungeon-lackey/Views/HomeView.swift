import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var campaigns: [Campaign] = []
    @State private var lastAccessedNotes: [Note] = []
    @State private var nextSession: Campaign? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Next Session Section
                    if let nextSession = nextSession {
                        VStack(alignment: .leading) {
                            Text("Next Session")
                                .font(.title2)
                                .bold()
                            
                            Text("Campaign: \(nextSession.title)")
                                .font(.headline)
                            if let sessionDate = nextSession.nextSession {
                                Text("Date: \(sessionDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Button(action: showLastNote) {
                                    Text("Last Note")
                                }
                                .buttonStyle(.bordered)
                                
                                Button(action: showNotes) {
                                    Text("Notes")
                                }
                                .buttonStyle(.bordered)
                                
                                Button(action: showLore) {
                                    Text("Lore")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    } else {
                        Text("No upcoming sessions.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    // Jump Back In Section
                    VStack(alignment: .leading) {
                        Text("Jump Back In")
                            .font(.headline)
                        
                        if lastAccessedNotes.isEmpty {
                            Text("No recently accessed notes.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(lastAccessedNotes) { note in
                                        NoteCard(note: note)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Campaigns Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Campaigns")
                                .font(.headline)
                            Spacer()
                            Button(action: addCampaign) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                            }
                        }
                        
                        if campaigns.isEmpty {
                            Text("No campaigns yet. Add one to get started!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(campaigns) { campaign in
                                CampaignRow(campaign: campaign, deleteAction: deleteCampaign)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .onAppear(perform: loadData)
        }
    }
    
    private func loadData() {
        // Load campaigns, notes, and determine the next session campaign
        campaigns = (try? modelContext.fetch(FetchDescriptor<Campaign>())) ?? []
        lastAccessedNotes = getLastAccessedNotes()
        nextSession = getNextSessionCampaign()
    }
    
    private func getLastAccessedNotes() -> [Note] {
        // Mock logic to fetch the last accessed notes
        return [] // Replace with actual implementation
    }
    
    private func getNextSessionCampaign() -> Campaign? {
        // Determine the campaign with the closest upcoming session
        return campaigns.filter { $0.nextSession != nil }
            .min(by: { $0.nextSession! < $1.nextSession! })
    }
    
    private func showLastNote() {
        // Show the last note of the next session campaign
    }
    
    private func showNotes() {
        // Show all notes of the next session campaign
    }
    
    private func showLore() {
        // Show lore-related notes of the next session campaign
    }
    
    private func addCampaign() {
        // Logic to add a new campaign
    }
    
    private func deleteCampaign(_ campaign: Campaign) {
        // Logic to delete a campaign
        if let index = campaigns.firstIndex(where: { $0.id == campaign.id }) {
            modelContext.delete(campaigns[index])
            campaigns.remove(at: index)
        }
    }
}

// A reusable card for displaying notes
struct NoteCard: View {
    let note: Note
    
    var body: some View {
        VStack {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            Text(note.date, formatter: dateFormatter)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 120, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// A reusable row for displaying campaigns
struct CampaignRow: View {
    let campaign: Campaign
    let deleteAction: (Campaign) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(campaign.title)
                    .font(.headline)
                if let sessionDate = campaign.nextSession {
                    Text("Next Session: \(sessionDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: { deleteAction(campaign) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// Formatter for displaying dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview{
    HomeView()
}
