import SwiftUI

struct LoadingView: View {
    let text: String
    
    init(_ text: String = "加载中...") {
        self.text = text
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView("加载中...")
            .environmentObject(UserState.shared)
    }
} 
