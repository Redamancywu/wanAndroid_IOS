//
//  QAView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct QAView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    
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
        .task {
            await viewModel.fetchQAList()
        }
    }
}

struct QACardView: View {
    let qa: QA
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack {
                Text("问答")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(4)
                
                Text(qa.title)
                    .font(.headline)
                    .lineLimit(2)
            }
            
            // 描述
            Text(qa.desc)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 底部信息
            HStack {
                Label(qa.author, systemImage: "person.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Label("\(qa.zan)", systemImage: "hand.thumbsup")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(qa.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 