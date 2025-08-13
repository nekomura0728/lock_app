# CDWidget - カウントダウンウィジェット

ロック画面とホーム画面に残り日数を表示するiOSアプリ

## プロジェクト設定

### Bundle Identifiers
- **メインアプリ**: `com.lizaria.countdown.CDWidget`
- **Widget Extension**: `com.lizaria.countdown.CDWidget.extension`

### App Groups
- **App Group ID**: `group.com.lizaria.countdown.CDWidget`

### URL Scheme
- **URL Scheme**: `cdwidget://`
- **Deep Link Format**: `cdwidget://event/<event-id>`

## Xcodeでの設定手順

### 1. App Groups設定

#### Developer Portalでの設定
1. Apple Developer Portal → Certificates, Identifiers & Profiles
2. Identifiers → App Groups → "+" をクリック
3. App Group作成:
   - Description: `CDWidget App Group`
   - Identifier: `group.com.lizaria.countdown.CDWidget`

4. App IDs設定:
   - メインアプリ (`com.lizaria.countdown.CDWidget`) 
   - Widget Extension (`com.lizaria.countdown.CDWidget.extension`)
   - 両方にApp Groupsを有効化して `group.com.lizaria.countdown.CDWidget` を選択

#### Xcodeでの設定
1. **メインアプリ Target**:
   - Signing & Capabilities → "+" → App Groups
   - `group.com.lizaria.countdown.CDWidget` をチェック

2. **Widget Extension Target**:
   - Signing & Capabilities → "+" → App Groups  
   - `group.com.lizaria.countdown.CDWidget` をチェック

### 2. ファイルのTarget Membership設定

Xcodeでプロジェクトを開いて、各ファイルのTarget Membershipを設定：

#### メインアプリのみ (CDWidget Target)
- `CDWidgetApp.swift`
- `ContentView.swift`
- `EventListView.swift`
- `EventEditView.swift`
- `PaywallView.swift`
- `SettingsView.swift`

#### Widget Extensionのみ (CDWidgetExtension Target)
- `CDWidget.swift`
- `CDProvider.swift`
- `CDWidgetEntryView.swift`

#### 両方のTarget
- `Event.swift`
- `AppSettings.swift`
- `DataManager.swift`
- `EventManager.swift`
- `CountdownFormatter.swift`
- `CDEntry.swift`
- `Date+Extensions.swift`
- `Color+Extensions.swift`

### 3. ビルド設定

1. **Deployment Target**: iOS 17.0
2. **Swift Version**: Swift 5
3. **Bundle Identifiers**: 上記の通り設定
4. **Code Signing**: 開発者アカウントで設定

### 4. 実行・テスト

1. **ビルド**: ⌘ + B
2. **実行**: ⌘ + R
3. **Widget テスト**: 
   - シミュレーターのホーム画面長押し
   - "+" → "CDWidget" を追加

## 機能概要

- イベント作成・編集・削除
- 5つのWidget種類対応
- Deep Link対応 (`cdwidget://event/<id>`)
- 無料版制限 (1件まで)
- Pro版ペイウォール
- ローカルデータ保存 (App Groups使用)

## 次の実装ステップ

1. StoreKit 2実装
2. AdMob広告統合
3. ローカル通知機能
4. アクセシビリティ対応