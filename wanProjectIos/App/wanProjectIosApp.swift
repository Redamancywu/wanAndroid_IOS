//
//  wanProjectIosApp.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

@main
struct wanProjectIosApp: App {
    // 创建共享的状态对象
    @StateObject private var userState = UserState.shared
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userState)
                .environmentObject(profileViewModel)
        }
    }
} 