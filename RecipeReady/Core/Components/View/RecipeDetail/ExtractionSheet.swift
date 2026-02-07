//
//  ExtractionSheet.swift
//  RecipeReady
//
//  Sheet displayed during recipe extraction from shared video.
//

import SwiftUI
import SwiftData

struct ExtractionSheet: View {
    @Environment(ExtractionManager.self) private var extractionManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                switch extractionManager.state {
                case .idle, .processing:
                    processingView
                case .success(let recipe):
                    RecipeEditView(recipe: recipe)
                case .error(let error):
                    errorView(error)
                }
            }
            .navigationTitle("Extract Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        extractionManager.dismiss()
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled(extractionManager.state == .processing)
    }
    
    // MARK: - Views
    
    private var processingView: some View {
        VStack(spacing: 24) {
            ProgressView()
            // Make loader larger and more modern
                .controlSize(.extraLarge)
            
            VStack(spacing: 8) {
                Text("Extracting Recipe...")
                    .font(.headline)
                
                Text("Analyzing video audio and captions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    private func successView(_ recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title)
                    
                    Text("Recipe Extracted!")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.bottom)
                
                // Caption section (if available)
                if let caption = recipe.sourceCaption, !caption.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundStyle(.blue)
                            Text("Extracted Caption")
                                .font(.headline)
                        }
                        
                        Text(caption)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBlue).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Recipe preview
                VStack(alignment: .leading, spacing: 16) {
                    Text(recipe.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // Ingredients preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients (\(recipe.ingredients.count))")
                            .font(.headline)
                        
                        ForEach(recipe.ingredients.prefix(5)) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 4))
                                Text(ingredient.name)
                                if let amount = ingredient.amount {
                                    Text("- \(amount)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        if recipe.ingredients.count > 5 {
                            Text("+ \(recipe.ingredients.count - 5) more")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Steps preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps (\(recipe.steps.count))")
                            .font(.headline)
                        
                        ForEach(recipe.steps.prefix(3)) { step in
                            HStack(alignment: .top) {
                                Text("\(step.order).")
                                    .foregroundStyle(.secondary)
                                Text(step.instruction)
                                    .lineLimit(2)
                            }
                            .font(.subheadline)
                        }
                        
                        if recipe.steps.count > 3 {
                            Text("+ \(recipe.steps.count - 3) more steps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Confidence
                    if recipe.confidenceScore > 0 {
                        HStack {
                            Image(systemName: recipe.confidenceScore > 0.8 ? "checkmark.seal.fill" : "exclamationmark.triangle")
                            Text("\(Int(recipe.confidenceScore * 100))% confidence")
                        }
                        .font(.caption)
                        .foregroundStyle(recipe.confidenceScore > 0.8 ? .green : .orange)
                        .padding(.top)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        saveRecipe(recipe)
                    } label: {
                        Text("Save Recipe")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Edit Before Saving") {
                        // TODO: Navigate to edit view
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    private func errorView(_ error: ExtractionError) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon with background
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: error.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.orange)
            }
            
            VStack(spacing: 8) {
                Text(error.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(error.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    extractionManager.retry()
                } label: {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Create Manually") {
                   extractionManager.startManualCreation()
                }
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func saveRecipe(_ recipe: Recipe) {
        // Query for favorites cookbook
        let descriptor = FetchDescriptor<Cookbook>(
            predicate: #Predicate { $0.isFavorites == true }
        )
        
        if let favoritesCookbook = try? modelContext.fetch(descriptor).first {
            // Add recipe to favorites
            favoritesCookbook.recipes.append(recipe)
        }
        
        // Ensure the flag is set for the dynamic query in FavoritesCollectionCard
        recipe.isFavorite = true
        
        modelContext.insert(recipe)
        
        // Explicit save to ensure persistence immediately
        try? modelContext.save()
        extractionManager.dismiss()
        dismiss()
    }
}

#Preview {
    ExtractionSheet()
        .environment(ExtractionManager())
        .modelContainer(for: Recipe.self, inMemory: true)
}