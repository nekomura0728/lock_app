import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var eventManager: EventManager
    @StateObject private var storeManager = StoreManager()
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Proで\"つい忘れる\"を\n根こそぎ排除")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // ベネフィット
                    VStack(spacing: 16) {
                        BenefitRow(
                            icon: "plus.circle.fill",
                            title: "複数イベント登録",
                            description: "2つ以上のイベントを登録可能"
                        )
                        
                        BenefitRow(
                            icon: "square.grid.2x2.fill",
                            title: "ウィジェットで2つ表示",
                            description: "ホーム画面で複数イベント同時表示"
                        )
                        
                        BenefitRow(
                            icon: "xmark.circle.fill",
                            title: "シンプルな買い切り",
                            description: "一度の購入でずっと使える"
                        )
                    }
                    .padding(.horizontal)
                    
                    // 価格表示
                    VStack(spacing: 8) {
                        if let product = storeManager.proProduct {
                            Text(product.displayPrice)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                        } else {
                            Text("¥300")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        
                        Text("買い切り（一度だけ）")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    // 購入ボタン
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await purchasePro()
                            }
                        } label: {
                            HStack {
                                if storeManager.isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    if let product = storeManager.proProduct {
                                        Text("\(product.displayPrice)でProを購入")
                                    } else {
                                        Text("Proを購入")
                                    }
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(storeManager.isPurchasing ? Color.gray : Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(storeManager.isPurchasing)
                        
                        Button("購入を復元") {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }
                        .foregroundColor(.blue)
                        .disabled(storeManager.isPurchasing)
                    }
                    .padding(.horizontal)
                    
                    // 規約
                    VStack(spacing: 8) {
                        Text("一度の購入でずっと使えます。購入はiTunesアカウントに請求されます。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Button("利用規約") {
                                // 利用規約を開く
                            }
                            
                            Text("・")
                                .foregroundColor(.secondary)
                            
                            Button("プライバシーポリシー") {
                                // プライバシーポリシーを開く
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("エラー", isPresented: .constant(storeManager.errorMessage != nil)) {
                Button("OK") {
                    storeManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = storeManager.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: storeManager.isPro) { isPro in
                if isPro {
                    eventManager.updateProStatus(true)
                    dismiss()
                }
            }
        }
    }
    
    private func purchasePro() async {
        guard let product = storeManager.proProduct else {
            storeManager.errorMessage = "商品が見つかりません"
            return
        }
        
        await storeManager.purchase(product)
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}


#Preview {
    PaywallView()
        .environmentObject(EventManager())
}