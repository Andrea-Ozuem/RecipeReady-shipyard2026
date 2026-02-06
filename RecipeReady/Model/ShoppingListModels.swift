//
//  ShoppingListModels.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 06/02/2026.
//

import Foundation
import SwiftData

@Model
final class ShoppingListRecipe {
    var id: UUID
    var originalRecipeID: UUID?
    var title: String
    var imageURL: String?
    var servings: Int
    var isExpanded: Bool
    
    @Relationship(deleteRule: .cascade) var items: [ShoppingListItem] = []
    
    init(id: UUID = UUID(), originalRecipeID: UUID? = nil, title: String, imageURL: String? = nil, servings: Int = 1, isExpanded: Bool = true) {
        self.id = id
        self.originalRecipeID = originalRecipeID
        self.title = title
        self.imageURL = imageURL
        self.servings = servings
        self.isExpanded = isExpanded
    }
    
    @Transient
    var totalItems: Int {
        items.count
    }
    
    @Transient
    var missingItems: Int {
        items.filter { !$0.isChecked }.count
    }
}

@Model
final class ShoppingListItem {
    var id: UUID
    var name: String
    var quantity: String
    var isChecked: Bool
    var section: String?
    
    var recipe: ShoppingListRecipe?
    
    init(id: UUID = UUID(), name: String, quantity: String, isChecked: Bool = false, section: String? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.section = section
    }
}
