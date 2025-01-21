//
//  QAView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct QAView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    @AppStorage("ReadArticles") private var readArticles: [Int] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.qaList) { qa in
                    QACardView(qa: qa)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.fetchQAList()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.errorMessage {
                ErrorView(
                    error: ApiError.message(error),
                    retryAction: {
                        Task {
                            await viewModel.fetchQAList()
                        }
                    }
                )
            } else if viewModel.qaList.isEmpty {
                EmptyPlaceholderView(
                    icon: "questionmark.circle",
                    title: "暂无问答",
                    message: "下拉刷新试试"
                )
            }
        }
        .task {
            if viewModel.qaList.isEmpty {
                await viewModel.fetchQAList()
            }
        }
    }
}

struct QACardView: View {
    let qa: QA
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack(alignment: .top, spacing: 8) {
                // 问答标签
                Text("问答")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(4)
                
                // 标题
                Text(qa.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
            
            // 描述
            if !qa.cleanDesc.isEmpty {
                Text(qa.cleanDesc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 底部信息栏
            HStack(alignment: .center) {
                // 作者
                Label(qa.author, systemImage: "person.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // 点赞数
                Label("\(qa.zan)", systemImage: "hand.thumbsup")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // 日期
                Text(qa.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // 分享按钮
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.scale)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapToOpenWeb(url: qa.link, title: qa.title)
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: qa.link) {
                ShareSheet(activityItems: [url])
            }
        }
    }
}

// 预览
struct QAView_Previews: PreviewProvider {
    static var previews: some View {
        QAView()
            .environmentObject(UserState.shared)
    }
} 