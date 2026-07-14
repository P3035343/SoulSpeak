import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    @State private var showingNewEntry = false
    @State private var searchText = ""
    
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty { return entries }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SSColors.background.ignoresSafeArea()
                
                if entries.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink(destination: JournalDetailView(entry: entry)) {
                                JournalEntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search entries...")
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                JournalDetailView(entry: nil)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundColor(SSColors.textSecondary.opacity(0.5))
            Text("Your journal is empty")
                .font(SSTypography.title3)
                .foregroundColor(SSColors.textPrimary)
            Text("Start writing to capture your thoughts and feelings")
                .font(SSTypography.body)
                .foregroundColor(SSColors.textSecondary)
                .multilineTextAlignment(.center)
            SSButton(title: "Write First Entry", style: .primary, icon: "pencil") {
                showingNewEntry = true
            }
            .padding(.horizontal, 48)
        }
        .padding()
    }
    
    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(SSTypography.headline)
                    .foregroundColor(SSColors.textPrimary)
                    .lineLimit(1)
                Spacer()
                if entry.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(SSColors.love)
                }
                if entry.isEncrypted {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(SSColors.primary)
                }
            }
            Text(entry.content)
                .font(SSTypography.body)
                .foregroundColor(SSColors.textSecondary)
                .lineLimit(2)
            HStack {
                Text(entry.createdAt, style: .date)
                    .font(SSTypography.caption)
                    .foregroundColor(SSColors.textSecondary)
                Spacer()
                Text(entry.mood)
                    .font(SSTypography.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(SSColors.primary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}
