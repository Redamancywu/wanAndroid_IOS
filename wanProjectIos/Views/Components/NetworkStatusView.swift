import SwiftUI

struct NetworkStatusView: View {
    @ObservedObject private var monitor = NetworkMonitor.shared
    
    var body: some View {
        Group {
            if !monitor.isConnected {
                VStack {
                    HStack {
                        Image(systemName: "wifi.slash")
                        Text("网络连接已断开")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding()
                .animation(.easeInOut, value: monitor.isConnected)
                .transition(.move(edge: .top))
            }
        }
    }
} 