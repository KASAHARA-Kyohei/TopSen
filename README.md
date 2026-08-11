# TopSen

TopSenは、ほかのアプリをフルスクリーンで使用している間も、すべてのmacOS Space上に小さなメモを表示するmacOS専用アプリです。

## 現在の機能

- 通常ウインドウより前面に表示される単一メモパネル
- すべてのデスクトップSpaceと、ほかのアプリのフルスクリーンSpaceへの表示
- パネルの移動、自由なリサイズ、表示・非表示
- 日本語IME、複数行入力、選択、コピー＆ペースト、スクロール
- メモ内容とウインドウ位置・サイズの自動保存と再起動時の復元
- ディスプレイ構成変更時の画面外フレーム補正
- メニューバーからの表示、非表示、確認付き消去、終了
- `⇧⌘M`によるグローバルな表示・非表示の切り替え

## 技術構成

- Swift / SwiftUI
- AppKit `NSPanel`によるウインドウ管理
- `UserDefaults`によるローカル永続化
- 外部ライブラリなし
- Xcode 26.1.1、macOS 26.1 SDK、Deployment Target macOS 26.1

画面は`MemoView`、メモ保存は`MemoStore`、ウインドウ状態保存は`WindowStateStore`、パネル制御は`MemoPanelController`に分離しています。TopSenはDockに表示されないアクセサリアプリとして動作し、メニューバーのメモアイコンから操作します。

パネルは`.nonactivatingPanel`で生成し、レベルを`.screenSaver`、Collection Behaviorを`.canJoinAllSpaces`、`.canJoinAllApplications`、`.fullScreenAuxiliary`、`.stationary`、`.ignoresCycle`に設定しています。

## ビルド方法

1. Xcode 26.1.1以降で`TopSen.xcodeproj`を開きます。
2. Schemeに`TopSen`、実行先に`My Mac`を選択します。
3. `Command + R`でビルド・実行します。

コマンドラインから署名なしでビルドする場合：

```sh
xcodebuild \
  -project TopSen.xcodeproj \
  -scheme TopSen \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Unit TestはXcodeの`Command + U`、または次のコマンドで実行できます。

```sh
xcodebuild \
  -project TopSen.xcodeproj \
  -scheme TopSen \
  -destination 'platform=macOS' \
  test
```

## 手動テスト方法

### 常時前面・フォーカス

1. TopSenを起動し、メモパネルが表示されることを確認します。
2. メニューバーにTopSenのメモアイコンが表示され、DockとアプリスイッチャーにはTopSenが表示されないことを確認します。
3. Safari、Chrome、Xcodeなどをクリックしてアクティブにします。
4. TopSenが表示されたままで、入力前には相手アプリがキーボード操作を受け取ることを確認します。
5. TopSenの編集領域をクリックし、日本語IME入力、変換確定、改行、文字選択、コピー＆ペースト、スクロールを確認します。

### グローバルショートカット

1. Safariなど別のアプリをアクティブにした状態で`⇧⌘M`を押し、TopSenが非表示になることを確認します。
2. もう一度`⇧⌘M`を押し、相手アプリのフォーカスを維持したままTopSenが表示されることを確認します。
3. 通常Spaceと別アプリのフルスクリーンSpaceの両方で同じ操作を確認します。
4. TopSen終了後、`⇧⌘M`が解放されていることを確認します。

### Space・フルスクリーン

1. 複数のデスクトップSpaceを作成し、Spaceを切り替えてもTopSenが表示されることを確認します。
2. Safari、Chrome、QuickTime、XcodeなどをmacOS標準のフルスクリーン表示にします。
3. 各フルスクリーンSpaceへ移動し、TopSenが前面に表示されることを確認します。
4. YouTubeなどの動画フルスクリーンでも前面表示を確認します。

### 永続化・画面構成変更

1. メモを入力し、パネルを移動・リサイズします。
2. TopSenを終了して再起動し、内容、位置、サイズが復元されることを確認します。
3. 外部ディスプレイ上へパネルを移動して終了します。
4. 外部ディスプレイを外して再起動し、パネルがメインディスプレイ内へ戻ることを確認します。

### メニュー

メニューバーのTopSenアイコンから表示、非表示、内容消去を確認します。内容消去では確認ダイアログの「キャンセル」と「消去」の両方を確認してください。「TopSenを終了」も同じステータスメニューから実行できます。

## macOS上の既知の制約

- 他アプリのフルスクリーン上へ表示するため、パネルレベルは`.screenSaver`です。通常のシステムダイアログより上に表示される場合があります。
- ロック画面、セキュア入力画面、macOSが保護するシステム画面への表示は保証されません。
- Mission ControlやSpace切替のアニメーション中、一時的にパネルが非表示または移動したように見える場合があります。
- macOS標準ではない独自の排他的フルスクリーン表示では、前面表示が保証されません。
- パネルは表示だけではフォーカスを奪いません。クリック時には日本語IME入力のためTopSenを明示的にアクティブ化します。
- アクセサリアプリのためDock、通常のアプリメニュー、`Command + Tab`のアプリスイッチャーには表示されません。
- `⇧⌘M`がほかのアプリやmacOSで予約されている場合は登録できません。その場合は起動時に警告を表示します。

## 今後の候補機能

- 複数メモとメモ一覧
- メモごとの背景色と透明度
- Markdown表示
- ショートカットのカスタマイズ
- iCloud同期
- 検索、書き出し、バックアップ
