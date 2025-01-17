//
//  HomeVideoView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeVideoView: View {
    let articles: [Article]
    
    // 定义网格布局
    private let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(articles) { article in
                    VideoCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// 预览
struct HomeVideoView_Previews: PreviewProvider {
    static var previews: some View {
        HomeVideoView(articles: MockData.articles)
    }
} 