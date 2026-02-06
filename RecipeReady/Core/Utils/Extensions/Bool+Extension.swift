//
//  Bool+Extension.swift
//  RecipeReady
//
//  Helper to make Bool comparable for sorting.
//

import Foundation

extension Bool: Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        // false (0) < true (1)
        return !lhs && rhs
    }
}
