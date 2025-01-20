//
//  HomeResourceView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeResourceView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(projectViewModel.resourceArticles) { article in
                    ProjectCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}
