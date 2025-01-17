//
//  ContentView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
            
            CategoryView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("分类")
                }
            
            SystemView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("体系")
                }
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
} 