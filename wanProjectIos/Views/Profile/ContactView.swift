import SwiftUI

struct ContactView: View {
    let contacts: [ContactItem] = [
        ContactItem(icon: "globe", title: "GitHub", subtitle: "@Redamancywu", url: "https://github.com/Redamancywu", color: .black),
        ContactItem(icon: "book.closed", title: "掘金", subtitle: "@Redamancywu", url: "https://juejin.cn/user/712916573884855/posts", color: .blue),
        ContactItem(icon: "newspaper", title: "CSDN", subtitle: "@Redamancywu", url: "https://blog.csdn.net/qq_44874307?spm=1010.2135.3001.5343", color: .red),
        ContactItem(icon: "bubble.left", title: "微博", subtitle: "@Redamancywu", url: "https://weibo.com/your-id", color: .orange),
        ContactItem(icon: "envelope.fill", title: "QQ邮箱", subtitle: "22340676@qq.com", url: nil, color: .blue)
    ]
    
    var body: some View {
        List {
            ForEach(contacts) { item in
                if let url = item.url {
                    Button {
                        if let url = URL(string: url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        contactItemView(item)
                    }
                } else {
                    contactItemView(item)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("联系方式")
    }
    
    private func contactItemView(_ item: ContactItem) -> some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(item.color)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .foregroundColor(.primary)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if item.url != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContactItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String?
    let url: String?
    let color: Color
    
    init(icon: String, title: String, subtitle: String? = nil, url: String? = nil, color: Color) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.color = color
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactView()
        }
    }
} 