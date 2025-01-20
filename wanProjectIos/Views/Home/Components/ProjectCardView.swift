//
//  ProjectCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI
import Foundation

struct ProjectCardView: View {
    let article: Article
    @StateObject private var viewModel = ProjectCardViewModel()
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.openURL) private var openURL
    
    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部内容区域（可点击）
            Button {
                if let link = article.link {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let viewController = windowScene.windows.first?.rootViewController {
                        WebViewRouter.openURL(link, title: article.title, from: viewController)
                    }
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    // 左侧封面图片
                    if let envelopePic = article.envelopePic, !envelopePic.isEmpty {
                        AsyncImage(url: URL(string: envelopePic)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: 120, height: 160)
                        .cornerRadius(8)
                        .clipped()
                    }
                    
                    // 右侧内容
                    VStack(alignment: .leading, spacing: 8) {
                        // 标题和时间
                        HStack(alignment: .top) {
                            Text(article.title)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(2)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(article.niceDate)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        // 描述
                        if let desc = article.desc?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) {
                            Text(desc)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                    }
                }
            }
            .buttonStyle(.scale)
            
            // 底部信息栏（独立区域）
            HStack(alignment: .center) {
                // 作者
                if let author = article.author {
                    Label(author, systemImage: "person.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // 项目链接 - 添加安全检查
                if let projectLink = article.projectLink,
                   !projectLink.isEmpty,  // 添加空字符串检查
                   let url = URL(string: projectLink) {  // URL 创建检查
                    Button {
                        openURL(url)
                    } label: {
                        Image(systemName: "link.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.scale)
                }
                
                // 收藏按钮
                Button {
                    Task {
                        await viewModel.toggleCollect(articleId: article.id)
                    }
                } label: {
                    Image(systemName: viewModel.isCollected ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isCollected ? .red : .gray)
                }
                .buttonStyle(.scale)
                .alert("需要登录", isPresented: $viewModel.showLoginAlert) {
                    Button("取消", role: .cancel) { }
                    Button("去登录") {
                        profileViewModel.showLogin()
                    }
                } message: {
                    Text("收藏功能需要登录后才能使用")
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .onAppear {
            viewModel.checkCollectionStatus(articleId: article.id)
        }
        .onTapToOpenWeb(url: article.link ?? "", title: article.title)
        .withTapFeedback()
    }
}

// 预览
struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProjectCardView(article: PreviewData.projectArticle)
            ProjectCardView(article: PreviewData.projectArticleNoImage)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .environmentObject(UserState.shared)
        .environmentObject(ProfileViewModel())
    }
} 
