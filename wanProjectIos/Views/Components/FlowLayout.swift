//
//  FlowLayout.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing,
            alignment: alignment
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: LayoutSubviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing,
            alignment: alignment
        )
        for (index, frame) in result.frames {
            subviews[index].place(at: frame.origin, proposal: ProposedViewSize(frame.size))
        }
    }
}

private struct FlowResult {
    var size: CGSize = .zero
    var frames: [(Int, CGRect)] = []
    
    init(in width: CGFloat, subviews: LayoutSubviews, spacing: CGFloat, alignment: HorizontalAlignment) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowSubviews: [(Int, CGRect)] = []
        var rowWidth: CGFloat = 0
        
        // 计算每个子视图的位置
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && !rowSubviews.isEmpty {
                // 处理当前行的对齐
                alignRow(&rowSubviews, width: width, rowWidth: rowWidth, alignment: alignment)
                frames.append(contentsOf: rowSubviews)
                rowSubviews.removeAll()
                rowWidth = 0
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            rowSubviews.append((index, CGRect(x: x, y: y, width: size.width, height: size.height)))
            x += size.width + spacing
            rowWidth = x
            maxHeight = max(maxHeight, size.height)
        }
        
        // 处理最后一行
        alignRow(&rowSubviews, width: width, rowWidth: rowWidth, alignment: alignment)
        frames.append(contentsOf: rowSubviews)
        size = CGSize(width: width, height: y + maxHeight)
    }
    
    private mutating func alignRow(_ row: inout [(Int, CGRect)], width: CGFloat, rowWidth: CGFloat, alignment: HorizontalAlignment) {
        let offset: CGFloat
        switch alignment {
        case .leading:
            offset = 0
        case .center:
            offset = (width - rowWidth + 8) / 2 // 8 是最后一个间距
        case .trailing:
            offset = width - rowWidth + 8
        default:
            offset = 0
        }
        
        if offset > 0 {
            for i in row.indices {
                row[i].1.origin.x += offset
            }
        }
    }
} 