import SwiftUI

struct CoinView: View {
    @StateObject private var viewModel = CoinViewModel()
    @EnvironmentObject private var userState: UserState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 积分信息卡片
                coinInfoCard
                    .padding()
                
                // 积分记录列表
                if viewModel.records.isEmpty && !viewModel.isLoading {
                    EmptyPlaceholderView(
                        icon: "dollarsign.circle",
                        title: "暂无积分记录",
                        message: "快去完成任务赚取积分吧"
                    )
                } else {
                    recordsList
                }
            }
            .navigationTitle("我的积分")
        }
        .task {
            await viewModel.refresh()
        }
    }
    
    // 积分信息卡片
    private var coinInfoCard: some View {
        VStack(spacing: 16) {
            // 总积分
            Text("\(userState.coinCount)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.orange)
            
            Text("当前积分")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 等级和排名
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("Lv.\(userState.level)")
                        .font(.headline)
                    Text("等级")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 4) {
                    Text(userState.rank)
                        .font(.headline)
                    Text("排名")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    // 积分记录列表
    private var recordsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.records) { record in
                    CoinRecordCard(record: record)
                }
                
                if viewModel.hasMoreData {
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// 积分记录卡片
struct CoinRecordCard: View {
    let record: CoinRecord
    
    var body: some View {
        HStack {
            // 积分信息
            VStack(alignment: .leading, spacing: 8) {
                Text(record.desc)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Text(formatDate(record.date))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 积分数量
            Text("+\(record.coinCount)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    private func formatDate(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
} 