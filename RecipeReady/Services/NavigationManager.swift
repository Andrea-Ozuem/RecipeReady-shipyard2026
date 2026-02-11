//
//  NavigationManager.swift
//  RecipeReady
//
//  Created for programmatic navigation.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case cookbooks
        case groceryList
        case profile
    }
}
