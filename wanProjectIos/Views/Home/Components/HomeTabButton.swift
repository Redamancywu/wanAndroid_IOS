//
//  HomeTabButton.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeTabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(text)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .fontWeight(isSelected ? .bold : .regular)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
    }
} 