import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Campaign.title, order: .forward) var campaigns: [Campaign]
    @Query(sort: \Note.date, order: .reverse) var lastAccessedNotes: [Note]

    var nextSession: Campaign? {
        campaigns
            .filter { $0.nextSession != nil }
            .min { $0.nextSession! < $1.nextSession! }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    // Next Session Section
                    if let nextSession {
                        VStack(alignment: .leading) {
                            if let sessionDate = nextSession.nextSession {
                                Text("Next: \(sessionDate, formatter: dateFormatter)")
                                    .font(.headline)
                            }

                            Text("Campaign: \(nextSession.title)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

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
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal)
                    } else {
                        Text("No upcoming sessions.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
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
                                        NavigationLink(destination: NoteDetailsView(note: note)) {
                                            NoteCard(note: note)
                                        }
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

                            ScrollView{
                                if campaigns.isEmpty {
                                    Text("No campaigns yet. Add one to get started!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(campaigns) { campaign in
                                        NavigationLink(destination: CampaignView(campaign: campaign)) {
                                            CampaignRow(campaign: campaign)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                }
                .padding(.vertical)

                // Fixed Bottom Navigation Bar
                VStack {
                    Spacer()
                    BottomNavigationBar()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func addCampaign() {
        let newCampaign = Campaign(
            title: "New Campaign",
            backgroundPicture: "Nada",
            nextSession: Date()
        )
        modelContext.insert(newCampaign)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save new campaign:", error)
        }
    }

    private func showLastNote() {
        guard let lastNote = lastAccessedNotes.first else {
            print("No notes available.")
            return
        }
        // Navigate to the NoteDetailsView with the newest note
        if let window = UIApplication.shared.windows.first {
            let rootView = NoteDetailsView(note: lastNote)
            let hostingController = UIHostingController(rootView: rootView)
            window.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }

    private func showNotes() {
        guard let firstCampaign = campaigns.first else {
            print("No campaigns available.")
            return
        }
        // Navigate to the CampaignView for the first campaign
        if let window = UIApplication.shared.windows.first {
            let rootView = CampaignView(campaign: firstCampaign)
            let hostingController = UIHostingController(rootView: rootView)
            window.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }

    private func showLore() {
        guard let firstCampaign = campaigns.first else {
            print("No campaigns available.")
            return
        }
        // Navigate to the CampaignView for lore (reuse CampaignView)
        if let window = UIApplication.shared.windows.first {
            let rootView = CampaignView(campaign: firstCampaign)
            let hostingController = UIHostingController(rootView: rootView)
            window.rootViewController?.present(hostingController, animated: true, completion: nil)
        }
    }

}


// MARK: - CampaignRow

struct CampaignRow: View {
    let campaign: Campaign

    var body: some View {
        HStack(spacing: 15) {
            // Campaign background picture as a square
            Image(campaign.backgroundPicture)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 5) {
                Text(campaign.title)
                    .font(.headline)

                if let sessionDate = campaign.nextSession {
                    Text("Next Session: \(sessionDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity) // Full width
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - NoteCard

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
        .frame(width: 120, height: 120) // Adjust size for square layout
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Date Formatter

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    HomeView()
}
