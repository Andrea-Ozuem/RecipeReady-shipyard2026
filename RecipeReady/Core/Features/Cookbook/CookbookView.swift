//
//  CookbookView.swift
//  RecipeReady
//
//  Displays the user's saved recipe collections.
//

import SwiftUI

struct CookbookView: View {
    // Grid Setup: 2 columns with spacing
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // UI State
    // UI State
    @State private var isShowingAddCookbook = false
    @State private var cookbooks: [CookbookItem] = [
        CookbookItem(title: "My favourite recipes", count: 5, isFavorites: true),
        CookbookItem(
            title: "Salad",
            count: 4,
            isFavorites: false,
            imageURLs: [
                "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80",
                "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=500&q=80",
                "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80"
            ]
        ),
        CookbookItem(
            title: "Chicken",
            count: 7,
            isFavorites: false,
            imageURLs: [
                "https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500&q=80",
                "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=500&q=80",
                "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=500&q=80"
            ]
        )
    ]
    
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
                             NavigationLink(destination: CookbookDetailView(title: cookbook.title)) {
                                 CollectionCard(cookbook: cookbook)
                             }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingAddCookbook) {
                AddCookbookSheet(onSave: { newTitle in
                    let newCookbook = CookbookItem(title: newTitle, isFavorites: false)
                    cookbooks.append(newCookbook)
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Models

struct CookbookItem: Identifiable {
    let id = UUID()
    let title: String
    var count: Int = 0
    var isFavorites: Bool = false
    var imageURLs: [String] = [] // Top, Bottom Left, Bottom Right
}

// MARK: - Subviews

// MARK: - Subviews

struct CollectionCard: View {
    let cookbook: CookbookItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Visual
            ZStack {
                // Background varies: Favorites uses softBeige, Collage uses White (gap color)
                if cookbook.isFavorites {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.softBeige)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                }
                
                if cookbook.isFavorites {
                    // Favorites Style: Centered Heart
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.primaryOrange)
                } else {
                    // Collage Style: 1 Top, 2 Bottom
                    GeometryReader { geo in
                        let halfHeight = (geo.size.height - 4) / 2
                        let halfWidth = (geo.size.width - 4) / 2
                        
                        VStack(spacing: 5) {
                            // Top Half
                            Group {
                                if let urlString = cookbook.imageURLs.first, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geo.size.width, height: halfHeight)
                                                .clipped()
                                        } else {
                                            Color.softBeige
                                        }
                                    }
                                } else {
                                    Rectangle().fill(Color.softBeige)
                                }
                            }
                            .frame(height: halfHeight)
                            .clipped()
                            
                            // Bottom Half
                            HStack(spacing: 5) {
                                // Bottom Left
                                Group {
                                    if cookbook.imageURLs.count > 1, let url = URL(string: cookbook.imageURLs[1]) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: halfWidth, height: halfHeight)
                                                    .clipped()
                                            } else {
                                                Color.softBeige
                                            }
                                        }
                                    } else {
                                        Rectangle().fill(Color.softBeige)
                                    }
                                }
                                .frame(width: halfWidth, height: halfHeight)
                                
                                // Bottom Right
                                Group {
                                    if cookbook.imageURLs.count > 2, let url = URL(string: cookbook.imageURLs[2]) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: halfWidth, height: halfHeight)
                                                    .clipped()
                                            } else {
                                                Color.softBeige
                                            }
                                        }
                                    } else {
                                        Rectangle().fill(Color.softBeige)
                                    }
                                }
                                .frame(width: halfWidth, height: halfHeight)
                            }
                            .frame(height: halfHeight)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .aspectRatio(0.8, contentMode: .fill) // Vertical Aspect Ratio
            // .background(Color.white) // Removed this in favor of explicit ZStack logic logic
            // .clipShape(RoundedRectangle(cornerRadius: 16)) // Moved inside
            
            // Meta Text
            VStack(alignment: .leading, spacing: 4) {
                Text(cookbook.title)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text("\(cookbook.count) items")
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
                        .background(Color.primaryOrange)
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
