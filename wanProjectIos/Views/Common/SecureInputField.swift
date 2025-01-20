import SwiftUI

public struct SecureInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    public init(title: String, placeholder: String, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
                
                Button {
                    isSecure.toggle()
                } label: {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// 预览
struct SecureInputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SecureInputField(
                title: "密码",
                placeholder: "请输入密码",
                text: .constant("")
            )
            
            SecureInputField(
                title: "确认密码",
                placeholder: "请再次输入密码",
                text: .constant("123456")
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 