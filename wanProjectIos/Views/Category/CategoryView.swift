//
//  CategoryView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct CategoryView: View {
    @State private var selectedTab = 0
    let tabs = ["体系", "公众号"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标签栏
            HStack(spacing: 30) {
                Spacer()
                ForEach(0..<tabs.count, id: \.self) { index in
                    CategoryTabButton(text: tabs[index],
                                   isSelected: selectedTab == index) {
                        withAnimation {
                            selectedTab = index
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .shadow(radius: 1)
            
            // 内容视图
            TabView(selection: $selectedTab) {
                Text("体系页面开发中...")
                    .tag(0)
                Text("公众号页面开发中...")
                    .tag(1)
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
            VStack(spacing: 4) {
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
        CategoryView()
    }
} 
