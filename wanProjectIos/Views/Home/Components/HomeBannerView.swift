//
//  HomeBannerView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeBannerView: View {
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

#Preview {
    HomeBannerView(banners: MockData.banners)
} 