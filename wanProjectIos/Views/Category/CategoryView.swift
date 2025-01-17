//
//  CategoryView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct CategoryView: View {
    @State private var selectedTab = 0
    let tabs = ["公众号", "广场", "问答", "专栏", "路线"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标签栏
            ScrollView(.horizontal, showsIndicators: false) {  // 添加滚动视图
                HStack(spacing: 30) {  // 调整间距以适应更多标签
                    ForEach(0..<tabs.count, id: \.self) { index in
                        CategoryTabButton(text: tabs[index],
                                       isSelected: selectedTab == index) {
                            withAnimation {
                                selectedTab = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
            
            // 内容视图
            TabView(selection: $selectedTab) {
                WeChatAccountView()  // 公众号视图
                    .tag(0)
                
                SquareView()  // 广场视图
                    .tag(1)
                
                QAView()  // 问答视图
                    .tag(2)
                
                ColumnView()  // 专栏视图
                    .tag(3)
                
                RoadmapView()  // 路线视图
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 自定义标签按钮
struct CategoryTabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(text)
                    .font(.headline)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .fontWeight(isSelected ? .bold : .regular)
                
                // 下划线
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
                    .frame(width: 40)
            }
        }
    }
}

// 预览
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryView()
        }
    }
} 
