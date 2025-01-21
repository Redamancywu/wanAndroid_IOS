//
//  HomeView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var projectViewModel = ProjectViewModel()
    @State private var showSearch = false
    
    let tabs = ["短视频", "推荐文章", "所有项目", "跨平台应用", "资源聚合", "鸿蒙专栏", "教程"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                searchBar
                
                if showSearch {
                    SearchResultView(searchText: $searchText)
                } else {
                    mainContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                Task {
                    await viewModel.refreshData()
                    await projectViewModel.refreshData()
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            LoadingView("加载中...")
        } else if let error = viewModel.error {
            ErrorView(
                error: error,
                retryAction: {
                    Task {
                        await viewModel.refreshData()
                    }
                }
            )
        } else {
            contentView
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Banner 视图
            if !viewModel.banners.isEmpty {
                BannerView(banners: viewModel.banners)
                    .frame(height: 200)
                    .padding()
            }
            
            // 自定义标签栏
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        TabButton(text: tabs[index],
                                isSelected: selectedTab == index) {
                            withAnimation {
                                selectedTab = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 内容视图
            TabView(selection: $selectedTab) {
                Group {
                    HomeVideoView(articles: viewModel.articles)
                        .tag(0)
                    HomeRecommendView()
                        .tag(1)
                        .environmentObject(viewModel)
                    HomeProjectView()
                        .tag(2)
                        .environmentObject(projectViewModel)
                    HomeCrossPlatformView()
                        .tag(3)
                        .environmentObject(projectViewModel)
                    HomeResourceView()
                        .tag(4)
                        .environmentObject(projectViewModel)
                    HomeHarmonyView()
                        .tag(5)
                        .environmentObject(viewModel)
                    HomeTutorialView()
                        .tag(6)
                        .environmentObject(viewModel)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: selectedTab) { newValue in
                // 切换标签页时不触发加载
                HiLog.i("切换到标签页: \(tabs[newValue])")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索文章", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.search)
                .onSubmit {
                    // 键盘搜索按钮点击时触发搜索
                    HiLog.i("键盘搜索按钮点击，关键词：\(searchText)")
                    showSearch = true
                }
                .onChange(of: searchText) { newValue in
                    showSearch = !newValue.isEmpty
                    HiLog.i("搜索文本变化：\(newValue)")
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    showSearch = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding()
    }
}

// 自定义标签按钮
struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(text)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .fontWeight(isSelected ? .bold : .regular)
                
                // 下划线
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

// 搜索栏视图
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("搜索...", text: $text)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

// Banner 视图
struct BannerView: View {
    let banners: [Banner]
    
    var body: some View {
        TabView {
            ForEach(banners) { banner in
                AsyncImage(url: URL(string: banner.imagePath)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .cornerRadius(10)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

// 预览
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HomeViewModel())
            .environmentObject(ProjectViewModel())
            .environmentObject(UserState.shared)
            .environmentObject(ProfileViewModel())
    }
}
