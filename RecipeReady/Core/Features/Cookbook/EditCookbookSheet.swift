//
//  EditCookbookSheet.swift
//  RecipeReady
//
//  Sheet to edit cookbook details, matching AddCookbookSheet style.
//

import SwiftUI

struct EditCookbookSheet: View {
    @Environment(\.dismiss) private var dismiss
    let cookbook: CookbookItem
    var onSave: (String) -> Void
    var onDelete: () -> Void
    
    @State private var title: String
    
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    
    init(cookbook: CookbookItem, onSave: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.cookbook = cookbook
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: cookbook.title)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isDeleting {
                    // MARK: - Skeleton Loading State
                    VStack(alignment: .center, spacing: 24) {
                        // Skeleton Cover
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.softBeige)
                            .frame(width: 100, height: 125)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Skeleton Label
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.softBeige)
                                .frame(width: 50, height: 20)
                            
                            // Skeleton Input
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.inputBackground)
                                .frame(height: 50)
                        }
                        
                        Spacer()
                        
                        // Skeleton Button
                        RoundedRectangle(cornerRadius: 25) // Assuming simulated button shape or just text placeholder
                            .fill(Color.softBeige)
                            .frame(width: 120, height: 20)
                            .padding(.bottom, 8)
                    }
                    .padding(20)
                    .transition(.opacity)
                } else {
                    // MARK: - Normal Edit State
                    VStack(alignment: .center, spacing: 24) {
                        // Cover Preview
                        CookbookCoverView(cookbook: cookbook)
                            .frame(width: 100, height: 125)
                            .clipped()
                        
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
                        }
                        
                        Spacer()
                        
                        // Delete Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Text("Delete cookbook")
                                .font(.bodyRegular)
                                .foregroundColor(.red)
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isDeleting ? "" : "Edit cookbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isDeleting {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if !title.isEmpty {
                                onSave(title)
                                dismiss()
                            }
                        }) {
                            Text("Save")
                                .font(.bodyBold)
                                .foregroundColor(.primaryOrange)
                        }
                    }
                }
            }
            .alert("Are you sure?", isPresented: $showDeleteAlert) {
                Button("Delete cookbook", role: .destructive) {
                    deleteAction()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Deleting your cookbook and its contents is irreversible.")
            }
        }
    }
    
    // Simulate Network Delay
    private func deleteAction() {
        withAnimation {
            isDeleting = true
        }
        
        // Simulate delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onDelete()
            dismiss()
        }
    }
}
