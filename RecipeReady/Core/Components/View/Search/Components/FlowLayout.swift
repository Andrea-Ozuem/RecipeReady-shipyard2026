//
//  FlowLayout.swift
//  RecipeReady
//
//  A custom layout that arranges subviews in a flow (left-to-right, wrapping to new lines).
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = rows.last?.maxY ?? 0
        
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        
        for row in rows {
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(width: element.width, height: element.height)
                )
            }
        }
    }

    // MARK: - Helper Types
    private struct Row {
        var elements: [Element]
        var y: CGFloat
        var height: CGFloat
        
        var maxY: CGFloat {
            y + height
        }
    }
    
    private struct Element {
        var subview: LayoutSubview
        var x: CGFloat
        var width: CGFloat
        var height: CGFloat
    }
    
    // MARK: - Helpers
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        var rows: [Row] = []
        var currentRowElements: [Element] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            
            if currentX + size.width > maxWidth && !currentRowElements.isEmpty {
                // New row
                rows.append(Row(elements: currentRowElements, y: currentY, height: currentRowHeight))
                currentY += currentRowHeight + spacing
                currentX = 0
                currentRowElements = []
                currentRowHeight = 0
            }
            
            currentRowElements.append(Element(
                subview: subview,
                x: currentX,
                width: size.width,
                height: size.height
            ))
            
            currentX += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
        
        if !currentRowElements.isEmpty {
            rows.append(Row(elements: currentRowElements, y: currentY, height: currentRowHeight))
        }
        
        return rows
    }
}
