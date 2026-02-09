//
//  IngredientScaler.swift
//  RecipeReady
//
//  Utility for scaling ingredient amounts.
//

import Foundation

struct IngredientScaler {
    
    /// Scales an amount string based on the ratio of target servings to original servings.
    /// - Parameters:
    ///   - amount: The original amount string (e.g., "1/2 cup", "2.5 kg").
    ///   - originalServings: The original number of servings.
    ///   - targetServings: The target number of servings.
    /// - Returns: A formatted string with the scaled amount, or the original string if parsing fails.
    static func scale(amount: String?, from originalServings: Int, to targetServings: Int) -> String {
        guard let amount = amount, !amount.isEmpty, originalServings > 0, targetServings > 0 else {
            return amount ?? ""
        }
        
        // If servings unchanged, return original
        if originalServings == targetServings {
            return amount
        }
        
        let ratio = Double(targetServings) / Double(originalServings)
        
        // 1. Separate numeric part from text (unit)
        // We look for the first continuous block of numbers/fractions at the START of the string.
        // E.g. "1 1/2 cups" -> "1 1/2" and "cups"
        // E.g. "Salt to taste" -> no match -> return original
        
        let (numericPart, textPart) = extractNumericAndText(from: amount)
        
        guard let numberString = numericPart else {
            return amount // No number found to scale
        }
        
        // 2. Parse the number string into a Double
        guard let baseValue = parseValue(numberString) else {
            return amount // Failed to parse number
        }
        
        // 3. Scale
        let scaledValue = baseValue * ratio
        
        // 4. Format back to string
        let formattedValue = formatValue(scaledValue)
        
        // 5. Reassemble
        if let text = textPart, !text.isEmpty {
            return "\(formattedValue) \(text)"
        } else {
            return formattedValue
        }
    }
    
    // MARK: - Private Helpers
    
    /// Extracts "1 1/2" from "1 1/2 cups"
    private static func extractNumericAndText(from input: String) -> (String?, String?) {
        // Regex to match a number at the start:
        // Patterns:
        // "1"
        // "1.5"
        // "1/2"
        // "1 1/2"
        // "1-2" (Range - currently treating as range, picking average or just first? Let's scale both if possible, or just fail for MVP safety)
        
        // Simplified approach: Iterate characters until we hit a non-numeric/non-separator char that isn't part of a fraction/decimal.
        // Valid chars: 0-9, ., /, whitespace (if between numbers)
        
        // Better: Use regex `^[\d\s/.]+` verify it looks like a number.
        // Challenge: "1 1/2" has a space. "1 cup" has a space.
        
        // Heuristic:
        // Split by space.
        // Item 1: Must be number/fraction.
        // Item 2: Can be fraction (if Item 1 was integer) OR unit.
        
        let parts = input.split(separator: " ")
        if parts.isEmpty { return (nil, nil) }
        
        let first = String(parts[0])
        
        // Check first part validity
        if isValidNumberChunk(first) {
            // Check second part if it exists
            if parts.count > 1 {
                let second = String(parts[1])
                // if "1 1/2", second part is "1/2" which is also a number chunk
                // if "1 cup", second part is "cup" which is NOT
                if isFraction(second) {
                    // It's a mixed number: "1 1/2"
                    let numberPart = "\(first) \(second)"
                    let textPart = parts.dropFirst(2).joined(separator: " ")
                    return (numberPart, textPart)
                }
            }
            
            // Just the first part is the number
            let numberPart = first
            let textPart = parts.dropFirst(1).joined(separator: " ")
            return (numberPart, textPart)
        }
        
        return (nil, nil)
    }
    
    private static func isValidNumberChunk(_ chunk: String) -> Bool {
        // Simple check: contains only digits, dot, slash
        let allowed = CharacterSet(charactersIn: "0123456789./")
        return chunk.unicodeScalars.allSatisfy { allowed.contains($0) } && !chunk.isEmpty && chunk != "." && chunk != "/"
    }
    
    private static func isFraction(_ chunk: String) -> Bool {
        return chunk.contains("/") && isValidNumberChunk(chunk)
    }
    
    /// Parses "1", "1.5", "1/2", "1 1/2" into Double
    private static func parseValue(_ input: String) -> Double? {
        // Handle Mixed Number "1 1/2"
        if input.contains(" ") {
            let parts = input.split(separator: " ")
            if parts.count == 2, let whole = Double(parts[0]), let frac = parseFraction(String(parts[1])) {
                return whole + frac
            }
        }
        
        // Handle Fraction "1/2"
        if input.contains("/") {
            return parseFraction(input)
        }
        
        // Handle Decimal/Integer
        return Double(input)
    }
    
    private static func parseFraction(_ input: String) -> Double? {
        let parts = input.split(separator: "/")
        if parts.count == 2, let num = Double(parts[0]), let denom = Double(parts[1]), denom != 0 {
            return num / denom
        }
        return nil
    }
    
    /// Formats double back to nice string.
    /// Tries to use common fractions if close enough.
    private static func formatValue(_ value: Double) -> String {
        // Tolerance for rounding errors
        let epsilon = 0.01
        
        // Check for whole number
        if abs(value - rounded(value)) < epsilon {
            return String(format: "%.0f", value)
        }
        
        // Check for common fractions
        // Eighths: 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875
        let fractionPart = value.truncatingRemainder(dividingBy: 1)
        let wholePart = value - fractionPart
        
        // Map decimal remainder to fraction string
        if let fracString = closestFraction(fractionPart, epsilon: epsilon) {
            if wholePart >= 1.0 - epsilon {
                 return "\(Int(wholePart)) \(fracString)"
            } else {
                return fracString
            }
        }
        
        // Fallback to decimal
        // If 1.5 -> "1.5"
        // If 1.3333 -> "1.3"
        return String(format: "%.2g", value) // General format, removes trailing zeros
    }
    
    // Quick helper for nearest integer
    private static func rounded(_ val: Double) -> Double {
        return val.rounded()
    }
    
    private static func closestFraction(_ val: Double, epsilon: Double) -> String? {
        let fractions: [(Double, String)] = [
            (1.0/4.0, "1/4"),
            (1.0/3.0, "1/3"),
            (1.0/2.0, "1/2"),
            (2.0/3.0, "2/3"),
            (3.0/4.0, "3/4"),
            (1.0/8.0, "1/8"), // Optional, maybe too granular?
        ]
        
        for (fVal, fStr) in fractions {
            if abs(val - fVal) < epsilon {
                return fStr
            }
        }
        return nil
    }
}
