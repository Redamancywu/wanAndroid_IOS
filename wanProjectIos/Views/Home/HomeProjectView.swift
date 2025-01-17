//
//  HomeProjectView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeProjectView: View {
    let articles: [Article]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(articles) { article in
                    ProjectCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// 预览
struct HomeProjectView_Previews: PreviewProvider {
    static var previews: some View {
        HomeProjectView(articles: MockData.articles)
    }
} 