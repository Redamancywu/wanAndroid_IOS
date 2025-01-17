//
//  SystemButtons.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct SystemCategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                
                Spacer()
                
                if isSelected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.blue.opacity(isSelected ? 0.1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
}

struct SystemChildButton: View {
    let child: SystemCategory
    @StateObject private var viewModel = SystemViewModel.shared
    
    var body: some View {
        Button {
            viewModel.selectedChild = child
            Task {
                await viewModel.fetchArticles(cid: child.id, page: 0)
            }
        } label: {
            Text(child.name)
                .font(.subheadline)
                .foregroundColor(viewModel.selectedChild?.id == child.id ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.selectedChild?.id == child.id ? Color.blue : Color.gray.opacity(0.1))
                        .shadow(color: Color.black.opacity(viewModel.selectedChild?.id == child.id ? 0.1 : 0), radius: 5)
                )
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedChild?.id == child.id)
        }
    }
} 