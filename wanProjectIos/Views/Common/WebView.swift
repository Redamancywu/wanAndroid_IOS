import SwiftUI
import WebKit
import SafariServices

// WebView 配置管理器
class WebViewManager {
    static let shared = WebViewManager()
    private var webViewCache: [String: WKWebView] = [:]
    private let processPool = WKProcessPool()
    
    private init() {}
    
    func getWebView(for url: String) -> WKWebView {
        if let cachedWebView = webViewCache[url] {
            return cachedWebView
        }
        
        let configuration = WKWebViewConfiguration()
        configuration.processPool = processPool
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // 设置缓存策略
        let dataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = dataStore
        
        webViewCache[url] = webView
        return webView
    }
    
    func clearCache() {
        webViewCache.removeAll()
        
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        dataStore.removeData(ofTypes: types, modifiedSince: date) { }
    }
}

// WebView 包装器
struct WebView: View {
    let url: String
    let title: String
    
    var body: some View {
        SafariView(url: URL(string: url)!)
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
    }
}

// SafariView 包装器
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.preferredControlTintColor = .systemBlue
        safariViewController.dismissButtonStyle = .close
        
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // 不需要更新
    }
}

// 网页视图容器
struct WebViewContainer: View {
    let url: String
    let title: String
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: url, title: title)
                
                if isLoading {
                    LoadingView("加载中...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let url = URL(string: url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "safari")
                    }
                }
            }
        }
    }
}

// 网页打开工具
enum WebViewRouter {
    // 使用 SFSafariViewController 打开（当前方式）
    static func openURL(_ urlString: String, title: String, from viewController: UIViewController) {
        if let url = URL(string: urlString) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            viewController.present(vc, animated: true)
        }
    }
    
    // 使用内置 WebView 打开
    static func openWebView(_ urlString: String, title: String) -> some View {
        WebViewContainer(url: urlString, title: title)
    }
    
    // 直接在外部浏览器打开
    static func openInBrowser(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// 使用示例
extension View {
    func onTapToOpenWeb(url: String, title: String) -> some View {
        self.onTapGesture {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let viewController = windowScene.windows.first?.rootViewController {
                WebViewRouter.openURL(url, title: title, from: viewController)
            }
        }
    }
}

struct WebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContainer(url: "https://example.com", title: "示例网页")
            .environmentObject(UserState.shared)
    }
}

// 预览
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WebView(url: "https://www.example.com", title: "示例网页")
        }
    }
} 