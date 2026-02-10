//
//  SearchHelpers.swift
//  RecipeReady
//
//  Utility functions for fuzzy search and string matching.
//

import Foundation

struct SearchHelpers {
    
    // MARK: - Fuzzy Matching
    
    /// Calculates similarity score between two strings (0.0 to 1.0)
    /// 1.0 means exact match (case-insensitive after normalization)
    static func similarity(between s1: String, and s2: String) -> Double {
        let n1 = normalizeIngredient(s1)
        let n2 = normalizeIngredient(s2)
        
        if n1 == n2 { return 1.0 }
        if n1.isEmpty || n2.isEmpty { return 0.0 }
        
        // If one contains the other, give a high score but penalize for length difference
        if n1.contains(n2) || n2.contains(n1) {
            let ratio = Double(min(n1.count, n2.count)) / Double(max(n1.count, n2.count))
            return 0.8 + (0.2 * ratio) // Score between 0.8 and 1.0
        }
        
        let distance = levenshteinDistance(n1, n2)
        let maxLength = Double(max(n1.count, n2.count))
        
        return 1.0 - (Double(distance) / maxLength)
    }
    
    /// Checks if a query fuzzy matches a target string
    static func fuzzyMatch(query: String, target: String, threshold: Double = 0.75) -> Bool {
        return similarity(between: query, and: target) >= threshold
    }
    
    /// Calculatesthe Levenshtein edit distance between two strings
    /// Code adapted from classic iterative implementation
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1)
        let b = Array(s2)
        
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count {
            dist[i][0] = i
        }
        
        for j in 0...b.count {
            dist[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,     // deletion
                        dist[i][j - 1] + 1,     // insertion
                        dist[i - 1][j - 1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count][b.count]
    }
    
    // MARK: - Normalization
    
    /// Normalizes ingredient names for comparison
    /// - Lowercases
    /// - Removes common stop words
    /// - Handles simple pluralization
    static func normalizeIngredient(_ name: String) -> String {
        var str = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove stop words
        for word in stopWords {
            if str.hasPrefix(word + " ") {
                str = String(str.dropFirst(word.count + 1))
            }
        }
        
        // Simple singularization (naive)
        if str.hasSuffix("s") && !str.hasSuffix("ss") {
             // Exclude words that end in 's' but are singular or mass nouns requires a dictionary
             // For now, let's just leave it or use a very basic heuristic if length > 3
             if str.count > 3 {
                 str = String(str.dropLast())
             }
        }
        
        return str
    }
    
    private static let stopWords = [
        "fresh", "organic", "large", "small", "chopped", "diced", "sliced",
        "minced", "whole", "ground", "dried", "frozen", "raw", "cooked"
    ]
}
