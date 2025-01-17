//
//  FlowLayout.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var position = bounds.origin
        var lineHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if position.x + size.width > bounds.maxX {
                position.x = bounds.origin.x
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: position, proposal: .unspecified)
            
            lineHeight = max(lineHeight, size.height)
            position.x += size.width + spacing
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> CGSize {
        var position = CGPoint.zero
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        let width = proposal.width ?? .infinity
        
        for size in sizes {
            if position.x + size.width > width {
                position.x = 0
                position.y += lineHeight + spacing
                lineHeight = 0
            }
            
            lineHeight = max(lineHeight, size.height)
            position.x += size.width + spacing
        }
        
        totalHeight = position.y + lineHeight
        
        return CGSize(width: width, height: totalHeight)
    }
} 