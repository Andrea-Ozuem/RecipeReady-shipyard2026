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
                        // TODO: Add Collection Action
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
                        // "My favourite recipes" Card
                        NavigationLink(destination: RecipeListView()) {
                            CollectionCard(
                                title: "My favourite recipes",
                                count: 0, // TODO: Bind to actual count
                                icon: "heart.fill",
                                iconColor: .white // Orange heart on beige bg
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.screenBackground)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews

struct CollectionCard: View {
    let title: String
    let count: Int
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Visual
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.softBeige)
                    .aspectRatio(0.8, contentMode: .fill) // Vertical Aspect Ratio
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.primaryOrange)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Meta Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Text("\(count) recipes")
                    .font(.captionMeta)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

#Preview {
    CookbookView()
}
