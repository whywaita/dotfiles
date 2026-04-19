# CDP データ取得リファレンス

**PRIMARY DATA SOURCE** — CDP Fetch インターセプトによるソルバーデータ取得。

CDP (Chrome DevTools Protocol) の `Fetch` ドメインを使い、GTO Wizard の内部 API レスポンスを直接インターセプトしてソルバーデータを取得する。

## 概要

ブラウザが GTO Wizard のソリューションページを読み込む際に発行される `spot-solution` API コールをインターセプトし、レスポンス JSON をそのまま取得する。

## 前提条件

- CDP 対応ブラウザが `--remote-debugging-port=9222` で起動していること
- GTO Wizard にログイン済みであること
- `npx agent-browser` が利用可能であること

## 接続

### ページ一覧の取得

```bash
curl -s http://127.0.0.1:9222/json
```

レスポンスは JSON 配列。各要素に `webSocketDebuggerUrl` が含まれる:

```json
[
  {
    "id": "PAGE_ID",
    "title": "GTO Wizard",
    "url": "https://app.gtowizard.com/...",
    "webSocketDebuggerUrl": "ws://127.0.0.1:9222/devtools/page/PAGE_ID"
  }
]
```

### agent-browser 接続

```bash
npx agent-browser connect 9222
```

### Raw CDP WebSocket

Fetch インターセプトには Raw WebSocket 接続が必要:

```
ws://127.0.0.1:9222/devtools/page/{PAGE_ID}
```

## GTO Wizard URL 構築

URL パラメータの仕様は以下の通り。

```
https://app.gtowizard.com/solutions?gametype={gametype}&depth={depth}&stacks={stacks}&preflop_actions={preflop_actions}[&board={board}][&flop_actions={flop_actions}][&turn_actions={turn_actions}][&river_actions={river_actions}]
```

### スタック深度の表記

| 口語 | depth 値 |
|------|----------|
| 30bb | `30.125` |
| 40bb | `40` |
| 100bb | `100.125` |

`.125` はアンティ構造を考慮した値。30bb と 100bb で付加される。

## Fetch インターセプトプロトコル

CDP `Fetch` ドメインを使い、`spot-solution` API レスポンスをキャプチャする手順:

```
1. Fetch.enable({
     patterns: [{
       urlPattern: "*spot-solution*",
       requestStage: "Response"
     }]
   })

2. ページナビゲーション (Page.navigate または SPA 内クリック)

3. Fetch.requestPaused イベントを待機

4. Fetch.getResponseBody({ requestId }) → { body, base64Encoded }

5. base64Encoded が true の場合: body を base64 デコード

6. JSON パース（フォーマットは本ドキュメント末尾「ソリューション JSON フォーマット」参照）

7. Fetch.continueRequest({ requestId }) → ページを再開

8. 完了後: Fetch.disable()
```

### 重要な注意点

- `Fetch.continueRequest` を呼ばないとページが停止する。必ず呼ぶこと
- `requestStage: "Response"` を指定することでレスポンスボディの読み取りが可能になる
- 複数のリクエストが発生する場合があるため、各 `requestPaused` イベントに対して処理すること

## スクリーンショット取得

GTO Wizard のページは描画が重く、agent-browser の screenshot コマンドがタイムアウトすることがある。Raw CDP WebSocket 経由で直接取得する。

### 表示状態の必須要件（最重要）

**スクリーンショットを撮影する前に、以下の表示状態を必ず確保すること。**

#### Strategy + EV ビューを有効化

ハンドマトリクスの個別スポット撮影では、各セルに **アクション頻度（Strategy）と EV 値の両方** を表示すること。

```bash
# 1. EV 表示が有効か snapshot で確認
npx agent-browser snapshot -i | grep -iE "(EV|expected value)"

# 2. 無効ならトグル/タブをクリック
npx agent-browser eval "
  // 候補セレクタ（GTO Wizard のUI更新で変わる可能性あり）
  const candidates = [
    '[data-testid=\"ev-toggle\"]',
    'button[aria-label*=\"EV\"]',
    'button[title*=\"EV\"]'
  ];
  for (const sel of candidates) {
    const el = document.querySelector(sel);
    if (el && !el.classList.contains('active')) { el.click(); break; }
  }
"

# 3. 反映を待ってから再 snapshot で確認 → OK なら撮影
```

**撮影後の検査:** スクリーンショット内に EV 値（数字 + bb 表記）が描画されていることを目視確認する。映っていなければ再撮影。

#### Equity Charts を表示

エクイティ分布グラフ（OOP / IP のレンジ vs レンジ）を表示してから撮影すること。

```bash
# Equity タブ/パネルを開く
npx agent-browser eval "
  const candidates = [
    '[data-testid=\"equity-tab\"]',
    'button[aria-label*=\"Equity\"]',
    'button[title*=\"Equity\"]'
  ];
  for (const sel of candidates) {
    const el = document.querySelector(sel);
    if (el) { el.click(); break; }
  }
"

# snapshot で Equity チャートが描画されているか確認
npx agent-browser snapshot -i | grep -iE "(equity|distribution)"
```

**撮影後の検査:** Equity Charts は通常、横軸エクイティ % × 縦軸頻度のヒストグラムまたはCDFラインとして描画される。OOP / IP 両方のラインが見えていることを目視確認する。

**ファイル名規則:**
- Strategy+EV: `{street}-{board}-{action}-strategy-ev.jpg`
- Equity Charts: `{street}-{board}-{action}-equity.jpg`
- 集合分析（OOP/IP別）: `{street}-aggregate-{oop|ip}.jpg`

### ビューポートサイズ: ブラウザ実測値を使う

**`Emulation.setDeviceMetricsOverride` は使わないこと。** 固定値を上書きすると GTO Wizard のレイアウトが崩れてスクリーンショットが壊れる。

代わりに、ブラウザのネイティブビューポートサイズを実測して記録する:

```
Runtime.evaluate({
  expression: "JSON.stringify({innerW: window.innerWidth, innerH: window.innerHeight, dpr: window.devicePixelRatio})"
})
```

実測値の例（環境依存）:
```json
{"innerW": 1552, "innerH": 1075, "dpr": 2}
```

- GTO Wizard はこのネイティブサイズで正常にレンダリングされる
- 実ピクセルは `innerW * dpr` × `innerH * dpr`（例: 3104x2150）
- ブラウザウィンドウのサイズを変えなければ、セッション中は一定

### 撮影手順

```
1. Page.bringToFront()            // ページをフォアグラウンドに
2. Page.captureScreenshot({
     format: "jpeg",              // JPEG 推奨（軽量・高速）
     quality: 80
   })
```

レスポンスの `data` フィールドに base64 エンコードされた画像が含まれる。
スクリーンショットの解像度はブラウザのネイティブビューポート × devicePixelRatio で決まる。

## 集合分析（Aggregate Analysis）データ取得

### 概要

集合分析は GTO Wizard のソリューションページ内のビューモードで、**個別ハンドではなくレンジ全体の戦略をボード群・カード群で俯瞰する**。study mode の根幹データ。

個別ソリューション（`spot-solution`）は「特定ボードでの各ハンドの戦略」を返すのに対し、集合分析は「全ボード（or 全Turn card / 全River card）にわたる戦略の傾向」を返す。

### ストリート別の集合分析

| Street | 集合分析の内容 | 取得タイミング |
|--------|--------------|--------------|
| **Flop** | 全フロップボードにおける bet/check/raise 頻度のヒートマップ | プリフロップ解法ページからAggregate viewに切替 |
| **Turn** | 特定フロップ＋Flopアクション後の、全52枚中の残りTurn cardごとの戦略変化 | Flopアクション後のノードからTurn Aggregate viewに切替 |
| **River** | 特定Turn＋Turnアクション後の、全残りRiver cardごとの戦略変化 | Turnアクション後のノードからRiver Aggregate viewに切替 |

### ストリート進行ゲート（必須プロトコル）

**個別カード分析に進む前に、必ず該当ストリートの集合分析データを取得すること。**

順序の鉄則:

```
[Flop 集合分析 (OOP/IP)] → [Flop 個別ボード分析]
                              ↓
                        [Turn 集合分析 (OOP/IP)] → [Turn 個別カード分析]
                                                      ↓
                                                [River 集合分析 (OOP/IP)] → [River 個別カード分析]
```

各ゲートでは:
1. 集合分析ビューに切替
2. OOP / IP 両視点のスクリーンショットを取得
3. **落ちるカードのカテゴリ別の戦略変化を観察してメモ**（Turn なら Broadway / Middle / Low / Paired / Flush complete など）
4. メモが取れて初めて個別カード分析に進む

このゲートを飛ばして個別カード分析だけを行うことは禁止。Turn / River のカードがどのような系譜で戦略変化を引き起こしているか俯瞰する目的。

### Aggregate View へのナビゲーション

GTO Wizard の Aggregate Analysis は solutions ページ内のビュー切替で表示する。

**手順:**

1. solutions ページに通常通りナビゲート（Step 2 の URL構築参照）
2. `npx agent-browser snapshot` で UI 要素を確認
3. "Aggregate" / "Overview" / バーチャートアイコン等のトグルを発見
4. `npx agent-browser eval` でクリックして Aggregate view に切替
5. ビュー切替時に新たな API コールが発生する → Fetch インターセプトで取得

**UI要素の発見例:**

```bash
# snapshot でページ構造を確認し、Aggregate トグルを探す
npx agent-browser snapshot -i

# 発見した要素をクリック（セレクタはページ構造に応じて調整）
npx agent-browser eval "document.querySelector('[data-testid=\"aggregate-tab\"]')?.click() || document.querySelector('button[aria-label*=\"Aggregate\"]')?.click()"
```

**注意:** セレクタは GTO Wizard のアップデートで変わる可能性がある。snapshot で実際の DOM を確認してからクリックすること。

### API インターセプトパターン

集合分析のデータは `spot-solution` とは**異なるエンドポイント**から返される場合がある。幅広いパターンでインターセプトする:

```
Fetch.enable({
  patterns: [
    { urlPattern: "*spot-solution*",  requestStage: "Response" },
    { urlPattern: "*aggregate*",      requestStage: "Response" },
    { urlPattern: "*overview*",       requestStage: "Response" },
    { urlPattern: "*report*",         requestStage: "Response" }
  ]
})
```

**エンドポイント発見のフォールバック:** 上記パターンで捕捉できない場合、`Network.enable` + `Network.responseReceived` でページ内の全APIコールを監視し、Aggregate view 切替時に発生するリクエストURLを特定する:

```
1. Network.enable()
2. Aggregate viewに切替（UI要素クリック）
3. Network.responseReceived イベントを収集
4. URL に "api" や "solution" を含むレスポンスを確認
5. 発見したURLパターンで Fetch.enable を再設定
```

### Flop 集合分析の取得

プリフロップのアクションシーケンスが確定した状態で、全フロップボードの戦略を俯瞰する。

**取得手順:**

```
1. solutions ページにナビゲート（board パラメータなし）
   URL例: ?gametype=MTTGeneral_8m&depth=100.125&stacks=...&preflop_actions=F-F-F-F-F-R2.5-F-C

2. ページロード完了を待つ（sleep 8-10秒）

3. Fetch.enable（上記の広めのパターン）

4. Aggregate view トグルをクリック
   → API コールが発生 → Fetch.requestPaused でキャプチャ

5. レスポンス JSON を取得
   → ボードごとの bet/check 頻度データ

6. スクリーンショットを撮影
   → screenshots/flop-aggregate-oop.jpg

7. OOP/IP 切替（後述）→ もう一方も同様に取得
   → screenshots/flop-aggregate-ip.jpg
```

**Flop 集合分析から読み取るデータ:**

| データ | 分析用途 |
|--------|---------|
| ボード別 bet 頻度 | ボードをカテゴリ分類する基準（Step 4 [study]） |
| ボード別 check 頻度 | check range の太さを確認 |
| 使用される bet size 分布 | small CB / large CB / overbet の傾向 |
| ボードテクスチャとの相関 | ハイカード構成・コネクト度・スート構成と戦略の関係 |

### Turn 集合分析の取得

特定のフロップ＋Flopアクション後に、全Turn cardでの戦略変化を確認する。

**前提:** Flopのアクションノードまで進んだ状態（ゲームツリーで該当ノードをクリック済み）

**取得手順:**

```
1. Flopアクション後のノードに遷移済みの状態
   （例: Flop AJ5r で OOP が small CB → IP が call した後のノード）

2. Turn ストリートの Aggregate view に切替
   → Flopアクション後のノードで Aggregate トグルをクリック

3. Fetch インターセプトでデータ取得

4. スクリーンショットを撮影
   → screenshots/turn-aggregate-{flop}-{action}.jpg
   例: turn-aggregate-AJ5r-smallCB-call.jpg
```

**Turn 集合分析から読み取るデータ:**

| データ | 分析用途 |
|--------|---------|
| Turn card 別 bet 頻度 | どのカードで second barrel / probe が増減するか |
| Turn card の分類 | BW / middle paired / low / flush complete / A 等 |
| 頻度変化の大きい card | 戦略が大きく変わるランクの特定 |
| OOP/IP 各プレイヤーの反応差 | ポジション差がTurnで拡大/縮小するか |

**Turn card の自然分類（参考）:**

```
Broadway (BW): A, K, Q, J, T     — ハイカードが増えるとレンジにヒットする組合せが変化
Middle:        9, 8, 7            — ストレートドローの完成/進行
Low:           6, 5, 4, 3, 2     — 多くのレンジに影響が少ない
Paired:        Flopとペアになるカード — ボードペアはベット頻度を下げることが多い
Flush complete: 3枚目のスート     — フラッシュ完成で戦略が大きく変化
```

### River 集合分析の取得

Turn アクション後の全 River card での戦略変化を確認する。

**取得手順:**

```
1. Turnアクション後のノードに遷移済みの状態

2. River ストリートの Aggregate view に切替

3. Fetch インターセプトでデータ取得

4. スクリーンショットを撮影
   → screenshots/river-aggregate-{flop}-{turn}-{action}.jpg
```

**River 集合分析から読み取るデータ:**

| データ | 分析用途 |
|--------|---------|
| River card 別 bet 頻度 | どのカードで value bet / bluff が増減するか |
| ポーラライズ度合い | bet range がポーラライズ or マージか |
| ブラフ候補の変化 | ミスドドローがブラフに使われるか |
| check range の強度 | SDV（ショーダウンバリュー）のあるハンドの分布 |

### OOP / IP の切替

集合分析は**プレイヤー視点ごと**に別のデータを持つ。両方を取得すること。

```
1. 集合分析を表示した状態で snapshot
2. OOP/IP の切替 UI を発見
   - ポジション名（例: "SB", "BTN"）のタブ
   - "OOP" / "IP" のトグル
3. クリックして切替 → 新しいデータが表示
4. 切替後にスクリーンショットとデータを取得
```

**OOP / IP で確認する観点の違い:**

| 視点 | 主に確認すること |
|------|----------------|
| **OOP** | bet range の構成、check range にトラップしているハンド、bet size の選択 |
| **IP** | ディフェンス戦略（call/fold/raise）、ID帯の位置、raise に回すハンド |

### 集合分析の Fetch フロー（まとめ）

```
1. Target.createTarget(url) → 新タブを作成
2. /json から新ページ WS 取得 → 接続
3. sleep(8-10秒) でページロード待ち
4. Fetch.enable({
     patterns: [
       { urlPattern: "*spot-solution*", requestStage: "Response" },
       { urlPattern: "*aggregate*",     requestStage: "Response" },
       { urlPattern: "*overview*",      requestStage: "Response" },
       { urlPattern: "*report*",        requestStage: "Response" }
     ]
   })
5. Aggregate view トグルをクリック
6. Fetch.requestPaused → getResponseBody → JSON パース
7. Fetch.continueRequest（必須）
8. Page.captureScreenshot → OOP のスクリーンショット保存
9. OOP/IP 切替 → 再度 Fetch.requestPaused → データ取得
10. Page.captureScreenshot → IP のスクリーンショット保存
11. 必要に応じてゲームツリーを進め、Turn/River の集合分析を繰り返す
```

### ボードテクスチャフィルタ

GTO Wizard の集合分析にはボードテクスチャのフィルタ機能がある。特定のテクスチャに絞った分析が可能:

- **ハイカード構成:** Ahi / Khi / Qhi / low board
- **ペアボード:** paired / unpaired
- **スート構成:** rainbow / two-tone / monotone
- **コネクト度:** connected / disconnected

snapshot で filter UI を発見し、`eval` でクリックしてフィルタを適用する。フィルタ適用後にスクリーンショットを取得する。

## ゲームツリーナビゲーション

GTO Wizard は SPA のため、ゲームツリーのノードクリックで新しいソリューションデータが非同期に取得される。

### ノードのクリック

```bash
npx agent-browser eval "document.querySelectorAll('.hspot-card').forEach(el => { const t = el.textContent; if (t.includes('Check') && t.includes('SB')) el.click(); })"
```

- `.hspot-card` 要素がゲームツリーの各ノード
- テキスト内容でフィルタして目的のアクションをクリック
- クリック後、SPA が新しい `spot-solution` API コールを発行する（インターセプト可能）

### 利用可能アクションの読み取り

agent-browser の snapshot からゲームツリーのテキストを読み取り、利用可能なアクションとベットサイズを発見できる:

```bash
npx agent-browser snapshot -i
```

## Progressive Bet Size Discovery

**ベットサイズを推測してはならない。** 利用可能なベットサイズはスポットごとに異なり、ソルバーが決定する。

ゲームツリーの DOM から利用可能なアクションを読み取り、段階的に発見する:

1. プリフロップの URL にナビゲート
2. snapshot からゲームツリーのテキストを読み取り、利用可能なアクション・ベットサイズを発見
3. 目的のアクションノードをクリック
4. Fetch インターセプトで新しい `spot-solution` レスポンスをキャプチャ
5. 各ストリートで繰り返す

ゲームツリーの DOM を直接参照できるため、事前にクエリを発行する必要がない。

## レスポンスフォーマット

取得される JSON のフォーマットは以下の通り。

- ポストフロップ: 1326 要素の配列（全 2 カードコンビネーション）
- プリフロップ: 169 要素の配列（13x13 マトリクス）

## エラーハンドリング

| 状況 | 原因 | 対処 |
|------|------|------|
| CDP 接続失敗 | ブラウザが CDP 有効で起動していない | `--remote-debugging-port=9222` でブラウザを再起動するようユーザに案内 |
| 認証セッション切れ | ログインページにリダイレクトされている | `document.title` でページタイトルを確認し、ログインページなら再ログインを案内 |
| Fetch タイムアウト | データがキャッシュされており API コールが発生しない | ページを強制リロード（`Page.reload({ ignoreCache: true })`） |
| レスポンスデコードエラー | base64 デコードが必要 | `base64Encoded` フラグを確認し、`true` なら base64 デコードしてから JSON パース |
| ページ一覧が空 | ブラウザにタブがない | GTO Wizard のタブを開くようユーザに案内 |

## 実践上の注意点（2026-04-11 セッションより）

### SPA キャッシュ回避

GTO Wizard は SPA のため、既存タブで `Page.navigate` や `window.location.assign` を使っても**旧ソリューションがキャッシュ表示され続ける**ことがある。

**対策:** 新しいシナリオには必ず**新タブを `Target.createTarget` で作成**する。ブラウザレベルの WebSocket（`ws://127.0.0.1:9222/devtools/browser/{id}`、`/json/version` で取得）に接続して実行する。

```python
# ブラウザ WS に接続して新タブ作成
async with websockets.connect(browser_ws) as ws:
    await ws.send(json.dumps({
        "id": 1,
        "method": "Target.createTarget",
        "params": {"url": target_url}
    }))
```

その後 `/json` から新タブの `webSocketDebuggerUrl` を取得してページ WS に接続する。

### 初回ロードは常にプリフロップ

URL に `board` や `flop_actions` パラメータを含めても、**最初の `spot-solution` API コールはプリフロップのデータを返す**。

- `flop_actions=X` 等を URL に含めると、2番目の API コールで対応スポットのデータが返ることがある
- ポストフロップデータを確実に取るには、ページロード後に **`.hspot-card` をクリックして対応スポットの API コールをトリガー**する

### 推奨フロー

```
1. Target.createTarget(url) → /json から新ページ WS 取得
2. ページ WS に接続 → sleep(8-10秒) でページロード待ち
3. Fetch.enable(patterns: [{urlPattern: "*spot-solution*", requestStage: "Response"}])
4. .hspot-card をクリック（Runtime.evaluate で）
5. Fetch.requestPaused → getResponseBody → JSON パース
6. Fetch.continueRequest（必須、204でも200でも）
7. 次のスポットがあれば 4-6 を繰り返し
8. Page.captureScreenshot でスクリーンショット取得
9. Fetch.disable
```

1回の WS 接続で複数スポットを順次取得できる。各スポット間で `Fetch.disable` → `Fetch.enable` のサイクルは不要（`continueRequest` さえ呼べば連続取得可能）。

### 204 レスポンスの扱い

- `spot-solution` の 204 = **未計算スポット or 重複リクエスト**。データは空。
- 204 でも **`Fetch.continueRequest` は必ず呼ぶ**（呼ばないとページ停止）
- 204 の後に 200 が来ることが多い。200 のみ処理すればよい

### JS Fetch Interceptor は使えない

`window.fetch` をオーバーライドするアプローチは、ページリロード（`location.assign` 等）でクリアされるため**使えない**。CDP `Fetch` ドメインのみが信頼できるインターセプト手段。

### 3-Way ポストフロップの制限

- LJ open → SB call → BB call 等の 3-way SRP は「**preflop only**」（ポストフロップ解法なし）のケースがある
- ゲームツリーの `.hspot-card` に「This solution is currently preflop only Solve postflop with AI」と表示される
- **フォールバック:** LJ vs BB ヘッズアップ SRP（`preflop_actions=F-F-R2-F-F-F-F-C`）を参照解として使用

### ボードカードの並び替え

サーバーはボードカードを独自の順序に並び替える。例: 入力 `board=3h5s5d` → レスポンス `board=5s5d3h`。URL パラメータの順序と API レスポンスの順序は一致しないことがある。

### hspot-card の構造

```javascript
// ポジション・アクション情報はテキストに含まれる
// 例: "BB 28Check Bet 62% (3.4)"
// 例: "LJ 28Check Bet 20% (1.1)"
// 例: "flop 5.5553AI solve" (pot=5.5, board=553, AI solve available)

// ポストフロップスポットの特定:
document.querySelectorAll('.hspot-card').forEach((el, i) => {
    const t = el.textContent.trim();
    if (t.includes('LJ') && t.includes('Check')) el.click();
});
```

---

## ソリューション JSON フォーマット

### トップレベル構造

| Field | Description |
|-------|-------------|
| `game` | 現在のゲーム状態（プレイヤー、ストリート、ポット、ボード、アクティブポジション） |
| `action_solutions[]` | 利用可能なアクションごとの GTO 戦略（頻度、EV、エクイティ） |
| `players_info[]` | フォールドしていないプレイヤーのレンジデータ |
| `hand_categories_range` | 1326 コンボの各ハンドカテゴリインデックス |
| `draw_categories_range` | 1326 コンボの各ドローカテゴリインデックス |

### 1326 コンボ配列

ポストフロップのレスポンスには長さ **1326** の配列が含まれる（C(52,2) = 1326 の全 2 カードコンビネーション）。プリフロップでは **169** 要素（13x13 マトリクス）。

**インデックスマッピング:** カード `i < j`（0-indexed）のコンボインデックス:

```
index = i * (103 - i) / 2 + j - i - 1
```

### `action_solutions[]`

各アクションの主要フィールド:

| Field | Type | Description |
|-------|------|-------------|
| `action` | object | アクション識別子（`code`, `display_name`, `betsize` 等） |
| `total_frequency` | float | レンジ全体でこのアクションを取る頻度 |
| `strategy` | float[] | 各コンボがこのアクションを取る頻度（0.0〜1.0） |
| `ev` | float[] | 各コンボがこのアクションを取った場合の期待値 |

### 結果の表示方法

1. **全体頻度**: `total_frequency` から `Raise 65.2% | Call 20.1% | Fold 14.7%`
2. **特定ハンド**: 該当コンボの `strategy` 値を読み取り `AKo: Raise 85%, Call 12%, Fold 3%`
3. **EV 比較**: `ev` 配列から `AKo: Raise (EV: +3.2bb) vs Call (EV: +1.8bb)`

---

## シナリオ変換ガイド

### ポジション順序

#### 8max MTT

```
UTG, UTG+1, LJ, HJ, CO, BTN, SB, BB
 1     2     3   4   5   6   7   8
```

#### 6max Cash

```
LJ, HJ, CO, BTN, SB, BB
 1   2   3   4   5   6
```

### ゲームタイプ識別子

| Identifier | Description |
|------------|-------------|
| `MTTGeneral_8m` | MTT 8-max general |
| `MTTGeneral_6m` | MTT 6-max general |
| `Cash6m` | Cash game 6-max |

### スタック表記

ハイフン区切り。全員 30bb: `30.125-30.125-30.125-30.125-30.125-30.125-30.125-30.125`

`100.125`, `30.125` の `.125` はアンティ構造を考慮した値。

### プリフロップアクション変換

アクションコード:

| Code | Meaning |
|------|---------|
| `F` | Fold |
| `C` | Call |
| `R{size}` | Raise to {size} bb |

一般的なシナリオ（8max MTT）:

| Scenario | `preflop_actions` |
|----------|-------------------|
| UTG opens | `R2.5` |
| BTN opens | `F-F-F-F-F-R2.5` |
| BTN opens, SB 3bets | `F-F-F-F-F-R2.5-R7.5` |
| BTN opens, BB calls | `F-F-F-F-F-R2.5-F-C` |
| CO opens, BTN 3bets, CO calls | `F-F-F-F-R2.5-R7.5-F-F-C` |

### ポストフロップアクション

| Code | Meaning |
|------|---------|
| `X` | Check |
| `C` | Call |
| `F` | Fold |
| `R{size}` | Bet/Raise to {size} bb |
| `RAI` | All-in |

### ボード表記

各カード 2 文字（ランク + スート）を連結:

- フロップ: `AsKs2d`（6 文字）
- ターン: `AsKs2dTh`（8 文字）
- リバー: `AsKs2dTh9c`（10 文字）

ランク: `A`, `K`, `Q`, `J`, `T`, `9`, `8`, `7`, `6`, `5`, `4`, `3`, `2`
スート: `s`(spades), `h`(hearts), `d`(diamonds), `c`(clubs)
