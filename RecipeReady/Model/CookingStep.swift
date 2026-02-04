//
//  CookingStep.swift
//  RecipeReady
//
//  Models a single cooking instruction step.
//

import Foundation

/// A single step in a recipe's cooking instructions.
struct CookingStep: Codable, Hashable, Identifiable {
    var id = UUID()
    var order: Int
    var instruction: String
    
    init(order: Int, instruction: String) {
        self.order = order
        self.instruction = instruction
    }
}
