//
//  CookbookView.swift
//  RecipeReady
//
//  Displays the user's saved recipe collections.
//

import SwiftUI
import SwiftData

struct CookbookView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Cookbook.createdAt, order: .forward) var cookbooks: [Cookbook]
    
    // Grid Setup: 2 columns with spacing
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var isShowingAddCookbook = false
    
    public init() {}
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header
                HStack {
                    Text("Saved")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingAddCookbook = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // MARK: - Grid Content
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(cookbooks) { cookbook in
                             NavigationLink(destination: CookbookDetailView(cookbook: cookbook)) {
                                 CollectionCard(cookbook: cookbook)
                             }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
            .onAppear {
                checkForSystemCookbooks()
            }
            .sheet(isPresented: $isShowingAddCookbook) {
                AddCookbookSheet(onSave: { newTitle in
                    let newCookbook = Cookbook(name: newTitle)
                    modelContext.insert(newCookbook)
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func checkForSystemCookbooks() {
        // Silent check for "Favorites"
        let descriptor = FetchDescriptor<Cookbook>(
            predicate: #Predicate { $0.isFavorites == true }
        )
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            if count == 0 {
                // Determine logic: Should it be first?
                // If sorting by createdAt forward (oldest first), make it very old.
                let favorites = Cookbook(
                    name: "My favourite recipes",
                    isFavorites: true,
                    createdAt: Date.distantPast
                )
                modelContext.insert(favorites)
            }
        } catch {
            // Retrieve failed, do nothing silently
        }
    }
}

// MARK: - Subviews

struct CollectionCard: View {
    let cookbook: Cookbook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Visual
            CookbookCoverView(cookbook: cookbook)
            
            // Meta Text
            VStack(alignment: .leading, spacing: 4) {
                Text(cookbook.name)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text("\(cookbook.recipes.count) items")
                    .font(.captionMeta)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Sheets

struct AddCookbookSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String) -> Void
    
    @State private var title: String = ""
    
    // Focus state for the input field to potentially drive border color
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                // Title Label
                Text("Title")
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                
                // Input Field
                TextField("Title", text: $title)
                    .padding()
                    .background(Color.inputBackground)
                    .cornerRadius(12)
                
                Spacer()
                
                // Full-width Save Button at bottom
                Button(action: {
                    if !title.isEmpty {
                        onSave(title)
                        dismiss()
                    }
                }) {
                    Text("Save cookbook")
                        .font(.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryBlue)
                        .cornerRadius(25)
                }
            }
            .padding(20)
            .navigationTitle("Create a cookbook")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CookbookView()
}