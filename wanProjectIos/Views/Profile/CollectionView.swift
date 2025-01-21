import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var userState: UserState
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if !userState.isLoggedIn {
                EmptyPlaceholderView(
                    icon: "person.crop.circle.badge.exclamationmark",
                    title: "未登录",
                    message: "登录后查看收藏"
                )
            } else if userState.collectedArticles.isEmpty {
                EmptyPlaceholderView(
                    icon: "star",
                    title: "暂无收藏",
                    message: "去首页收藏感兴趣的文章吧"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(userState.collectedArticles) { article in
                            ArticleCard(article: article)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .task {
            if userState.isLoggedIn {
                await userState.loadCollectedArticles()
            }
        }
        .alert("收藏失败", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// 收藏文章卡片
struct CollectedArticleCard: View {
    let article: Article
    let onUncollect: () -> Void
    let onShare: () -> Void
    @AppStorage("ReadArticles") private var readArticles: [Int] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(article.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(readArticles.contains(article.id) ? .gray : .primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // 分割线
            Divider()
                .padding(.vertical, 4)
            
            // 底部信息和操作栏
            HStack(spacing: 12) {
                // 作者
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.medium)
                    Text(article.author ?? article.shareUser ?? "匿名")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                }
                .frame(height: 32)
                
                Spacer()
                
                // 日期
                Text(article.niceDate)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(height: 32)
                
                // 操作按钮组
                HStack(spacing: 16) {
                    // 取消收藏按钮
                    Button(action: onUncollect) {
                        Image(systemName: "heart.slash.fill")
                            .foregroundColor(.red)
                            .imageScale(.medium)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // 分享按钮
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.secondary)
                            .imageScale(.medium)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .frame(height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .contentShape(Rectangle())
        .onTapToOpenWeb(url: article.link ?? "", title: article.title)
    }
} 
