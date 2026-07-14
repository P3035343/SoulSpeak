import SwiftUI
import SwiftData

struct CommunityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CommunityPost.createdAt, order: .reverse) private var posts: [CommunityPost]
    @State private var showCreatePost = false
    @State private var selectedCategory = "all"
    
    var filteredPosts: [CommunityPost] {
        if selectedCategory == "all" { return posts.filter { !$0.isHidden } }
        return posts.filter { $0.category == selectedCategory && !$0.isHidden }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    categoryFilter
                    ForEach(filteredPosts) { post in
                        CommunityPostCard(post: post)
                    }
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(SSColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["all", "share", "support", "celebrate", "question"], id: \.self) { cat in
                    Button(action: { selectedCategory = cat }) {
                        Text(cat.capitalized)
                            .font(SSTypography.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == cat ? SSColors.primary : SSColors.surface)
                            .foregroundColor(selectedCategory == cat ? .white : SSColors.textPrimary)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    
    var body: some View {
        SSCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(SSColors.primary)
                    Text(post.isAnonymous ? "Anonymous" : post.authorDisplayName)
                        .font(SSTypography.headline)
                    Spacer()
                    Text(post.createdAt, style: .relative)
                        .font(SSTypography.caption)
                        .foregroundColor(SSColors.textSecondary)
                }
                Text(post.content)
                    .font(SSTypography.body)
                    .foregroundColor(SSColors.textPrimary)
                HStack {
                    Button(action: {}) {
                        Label("\(post.likesCount)", systemImage: "heart")
                            .font(SSTypography.caption)
                    }
                    Spacer()
                    Text(post.category.capitalized)
                        .font(SSTypography.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(SSColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct CreatePostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var category = "share"
    @State private var isAnonymous = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Post") {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                }
                Section("Settings") {
                    Picker("Category", selection: $category) {
                        ForEach(["share", "support", "celebrate", "question"], id: \.self) {
                            Text($0.capitalized)
                        }
                    }
                    Toggle("Post Anonymously", isOn: $isAnonymous)
                }
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let post = CommunityPost(
                            authorDisplayName: "Current User",
                            content: content,
                            category: category,
                            isAnonymous: isAnonymous
                        )
                        modelContext.insert(post)
                        dismiss()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}
