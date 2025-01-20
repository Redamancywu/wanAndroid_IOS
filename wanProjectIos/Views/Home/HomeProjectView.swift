//
//  HomeProjectView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeProjectView: View {
    @EnvironmentObject var viewModel: ProjectViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.projectArticles) { article in
                    ProjectCardView(article: article)
                        .padding(.horizontal)
                }
                
                // 加载更多指示器
                if !viewModel.projectArticles.isEmpty {
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.loadMoreProjects()
                            }
                        }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

// 预览
struct HomeProjectView_Previews: PreviewProvider {
    static var previews: some View {
        HomeProjectView()
            .environmentObject(ProjectViewModel())
    }
} 