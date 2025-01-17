//
//  HomeCrossPlatformView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeCrossPlatformView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(projectViewModel.crossPlatformArticles) { article in
                    ProjectCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    HomeCrossPlatformView()
} 