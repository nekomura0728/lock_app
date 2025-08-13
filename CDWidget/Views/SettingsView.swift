import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Pro状態
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(eventManager.settings.isPro ? "Pro" : "無料版")
                                .font(.headline)
                                .foregroundColor(eventManager.settings.isPro ? .yellow : .primary)
                            
                            if eventManager.settings.isPro {
                                Text("すべての機能をご利用いただけます")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("1件まで作成可能")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if eventManager.settings.isPro {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                // Pro関連
                if !eventManager.settings.isPro {
                    Section {
                        Button("Proにアップグレード") {
                            showingPaywall = true
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    Section {
                        Button("購入を復元") {
                            restorePurchases()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // 設定
                Section("設定") {
                    Picker("期限後表示", selection: .constant(eventManager.settings.postDueDisplay)) {
                        ForEach(PostDueDisplayPolicy.allCases, id: \.self) { policy in
                            Text(policy.localizedTitle).tag(policy)
                        }
                    }
                    
                    Picker("自動選択", selection: .constant(eventManager.settings.widgetAutoSelectPolicy)) {
                        ForEach(WidgetSelectPolicy.allCases, id: \.self) { policy in
                            Text(policy.localizedTitle).tag(policy)
                        }
                    }
                }
                
                // 通知
                Section("通知") {
                    NavigationLink("通知設定") {
                        NotificationSettingsView()
                    }
                    
                    Text("締切の直前だけ、静かにお知らせします。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // ヘルプ
                Section("ヘルプ") {
                    NavigationLink("ウィジェット追加ガイド") {
                        WidgetGuideView()
                    }
                    
                    Link("利用規約", destination: URL(string: "https://example.com/terms")!)
                    
                    Link("プライバシーポリシー", destination: URL(string: "https://example.com/privacy")!)
                }
                
                // バージョン情報
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(eventManager)
            }
        }
    }
    
    private func restorePurchases() {
        // StoreKit実装後に処理を追加
    }
}


struct WidgetGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("ウィジェット追加方法")
                    .font(.title)
                    .fontWeight(.bold)
                
                GuideStep(
                    number: 1,
                    title: "ホーム画面を長押し",
                    description: "アプリアイコンが震え始めるまで長押ししてください。"
                )
                
                GuideStep(
                    number: 2,
                    title: "「+」ボタンをタップ",
                    description: "画面左上の「+」ボタンをタップします。"
                )
                
                GuideStep(
                    number: 3,
                    title: "「カウントダウン」を検索",
                    description: "ウィジェット一覧から「カウントダウン」を選択します。"
                )
                
                GuideStep(
                    number: 4,
                    title: "サイズを選択",
                    description: "Small、Medium、Largeから好きなサイズを選択してください。"
                )
                
                GuideStep(
                    number: 5,
                    title: "「ウィジェットを追加」",
                    description: "「ウィジェットを追加」をタップして完了です。"
                )
            }
            .padding()
        }
        .navigationTitle("ウィジェット追加ガイド")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(EventManager())
}