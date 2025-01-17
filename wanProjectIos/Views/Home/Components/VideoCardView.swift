//
//  VideoCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct VideoCardView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 视频缩略图区域
            ZStack {
                // 背景图片
                AsyncImage(url: URL(string: article.shareUser ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 180)
                .clipped()
                
                // 播放按钮
                Button(action: {
                    // 播放视频的动作（暂时不实现）
                    HiLog.i("点击播放视频: \(article.title)")
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 52, height: 52)
                        )
                }
            }
            
            // 视频信息
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if let desc = article.desc {
                    Text(desc)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if let author = article.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(article.niceDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// 预览
struct VideoCardView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCardView(article: MockData.articles[0])
            .padding()
            .previewLayout(.sizeThatFits)
    }
} 