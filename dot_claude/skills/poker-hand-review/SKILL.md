---
name: poker-hand-review
description: |
  ポーカーのハンドレビューを行うスキル。ユーザが受け取ったハンド・トーナメント状況を
  柔軟に受け取り、GTO Wizard のソルバーデータとブログ記事を根拠にした詳細な分析を提供する。
  数学的根拠（ポットオッズ、エクイティ、EV計算）とexploit観点を含む。
  「ハンドレビューして」「このハンドどう思う？」「レビューお願い」「hand review」
  「この判断正しかった？」でトリガーすること。
argument-hint: [hand-description or hand-history]
allowed-tools: Bash(npx agent-browser:*), Bash(python3:*), Bash(mkdir:*), Bash('/Applications/Google Chrome.app:*), Read, Write, Edit, WebFetch(https://blog.gtowizard.com/*), Fetch(https://blog.gtowizard.com/*), WebSearch, AskUserQuestion
---

# Poker Hand Review

ユーザのポーカーハンドを多角的にレビューし、数学的根拠とexploit観点を含むMarkdownレポートを生成する。

## 引数

- 第1引数（任意）: ハンド情報（自然言語テキスト、またはハンドヒストリーファイルのパス）
- 引数なしの場合: AskUserQuestion でハンド情報をヒアリングする

## Prerequisites

- **CDP-enabled browser**: GTO Wizard のソルバーデータ取得・スクリーンショットに必要（Chrome or Vivaldi with `--remote-debugging-port=9222`）
- **GTO Wizard account**: https://app.gtowizard.com にブラウザでログイン済みであること
- **agent-browser**: `npx agent-browser`（自動インストール）

## Evidence Policy（エビデンスルール）

**すべての分析・主張にはエビデンスを付与すること。エビデンスのない主張は出力に含めてはならない。**

### 1. GTO Wizard ハンドURL（ソルバーデータの根拠）

GTO Wizard CLIで取得した各ソルバーデータには、対応するWebアプリのURLを生成して付与する。

**URL構築方法:**

```
https://app.gtowizard.com/solutions?gametype={gametype}&depth={depth}&stacks={stacks}&preflop_actions={preflop_actions}[&board={board}][&flop_actions={flop_actions}][&turn_actions={turn_actions}][&river_actions={river_actions}]
```

CLIフラグとURLパラメータの対応:

| CLI Flag | URL Parameter |
|----------|--------------|
| `--gametype` | `gametype` |
| `--depth` | `depth` |
| `--stacks` | `stacks` |
| `--preflop-actions` | `preflop_actions` |
| `--board` | `board` |
| `--flop-actions` | `flop_actions` |
| `--turn-actions` | `turn_actions` |
| `--river-actions` | `river_actions` |

例:
```
gtowizard study --gametype MTTGeneral_8m --depth 100.125 --stacks 100.125-...-100.125 --preflop-actions F-F-F-F-F-R2.5-F-C --board AsKs2d
```
↓
```
https://app.gtowizard.com/solutions?gametype=MTTGeneral_8m&depth=100.125&stacks=100.125-...-100.125&preflop_actions=F-F-F-F-F-R2.5-F-C&board=AsKs2d
```

**ルール**: ソルバーデータを引用するたびに `[GTO Wizard]({URL})` 形式でリンクを付ける。

### 2. GTO Wizard ブログURL（exploit・戦略の根拠）

**Exploit に関する主張は、GTO Wizard ブログの記事をプライマリソースとする。**

- WebSearch で `site:blog.gtowizard.com` を検索し、関連記事のURLを取得する
- WebFetch で記事本文を取得し、具体的な根拠を抽出する
- 主張の横に `[出典: 記事タイトル](URL)` 形式でリンクを付ける
- ブログ記事が見つからない場合は、そのexploit主張が一般的なポーカー理論に基づくものであることを明記する

### 3. 数学的根拠（計算式の明示）

**すべての数値・計算結果には導出過程を示すこと。**

```markdown
> **ポットオッズ計算:**
> ポット = 6.5bb, ヴィランベット = 4.5bb, コール額 = 4.5bb
> 必要エクイティ = 4.5 / (6.5 + 4.5 + 4.5) = 4.5 / 15.5 = **29.0%**
> （計算式: 必要エクイティ = コール額 / コール後のポット合計）
```

計算式は [references/poker-math.md](references/poker-math.md) を参照。

## Workflow

### Step 1: ハンド情報の収集

ユーザから以下の情報を収集する。不足情報は AskUserQuestion で確認する。
必須情報が揃わない場合でも、得られた情報の範囲で最善のレビューを行う。

**必須情報:**

- ヒーローのハンド（例: AsKh, 9d9c）
- ポジション（例: BTN, CO, BB）
- プリフロップアクション（誰がオープン、3betなど）

**推奨情報:**

- ゲームタイプ（MTT / Cash / SNG）
- テーブル人数（6max / 8max / 9max）
- 有効スタック（bb単位）
- ボード（フロップ / ターン / リバー）
- 各ストリートのアクション
- ポットサイズ
- ヴィランのテンダンシー・リード（わかる範囲で）

**トーナメント固有情報（MTTの場合）:**

- ブラインドレベル / アンティ構造
- ICM状況（バブル付近、ファイナルテーブルなど）
- 残りプレイヤー数 / ペイアウト構造

### Step 2: CDP 経由でソルバーデータ取得

CDP (Chrome DevTools Protocol) の `Fetch` ドメインを使い、GTO Wizard の内部 API レスポンスをインターセプトしてソルバーデータを取得する。詳細は [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md) を参照。

1. **CDP 接続確認**:
   ```bash
   npx agent-browser connect 9222
   ```
   - 接続失敗時: ユーザに `--remote-debugging-port=9222` でブラウザを起動するよう案内

2. **GTO Wizard URL を構築**（[references/cdp-data-acquisition.md](references/cdp-data-acquisition.md#シナリオ変換ガイド) 参照）:
   - `gametype`: MTT → `MTTGeneral_8m` or `MTTGeneral_6m`, Cash → `Cash6m`
   - `depth`: 有効スタック（30bb → `30.125`, 100bb → `100.125`）
   - `stacks`: プレイヤー数分のスタック（ハイフン区切り）
   - `preflop_actions`: アクションシーケンス
   - `board`, `flop_actions`, `turn_actions`, `river_actions`: 該当する場合

3. **CDP Fetch インターセプトでデータ取得**:

   Python スクリプトで CDP WebSocket に接続し、以下の手順で構造化 JSON を取得する:

   ```
   a. Fetch.enable({patterns: [{urlPattern: "*spot-solution*", requestStage: "Response"}]})
   b. Page.navigate({url: GTO Wizard URL})
   c. Fetch.requestPaused イベントを待機
   d. Fetch.getResponseBody({requestId}) → JSON 取得
   e. Fetch.continueRequest({requestId}) → ページを再開（必須）
   f. Fetch.disable()
   ```

   取得される JSON のフォーマットは [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md#ソリューション-json-フォーマット) を参照。

4. **Progressive Bet Size Discovery（ブラウザ版）**:

   **ベットサイズを推測してはならない。** ゲームツリーの DOM から利用可能なアクションを読み取る:

   1. ページを開いた後、`npx agent-browser snapshot` でゲームツリーのテキストを読み取る
   2. `.hspot-card` 要素のテキストから利用可能なアクション（`Check`, `Bet 51%`, `Allin` 等）を発見
   3. 目的のアクションノードを `npx agent-browser eval` でクリック
   4. SPA が新しい `spot-solution` API コールを発行 → Fetch インターセプトでキャプチャ
   5. 各ストリートで繰り返す

5. **各決定ポイント**でデータ取得 + スクリーンショット:
   - ヒーローがアクションする各地点でソルバーデータを取得
   - 必要に応じてヴィランの戦略も取得
   - **同時に** CDP `Page.captureScreenshot` でハンドマトリクスのスクリーンショットを取得（Step 3 と統合）
   - 各クエリに対応する GTO Wizard URL を記録（Evidence Policy 参照）

6. エラーハンドリング（[references/cdp-data-acquisition.md](references/cdp-data-acquisition.md#エラーハンドリング) 参照）:
   - CDP 接続失敗 → ブラウザ起動を案内
   - 認証切れ → `document.title` でログインページ検出、再ログインを案内
   - Fetch タイムアウト → `Page.reload({ignoreCache: true})` で強制リロード

### Step 3: スクリーンショット取得（Step 2 と統合）

**Note:** スクリーンショット取得は Step 2 のデータ取得フローに統合済み。各決定ポイントのソルバーデータ取得時に、同じ CDP 接続を使って `Page.captureScreenshot` を実行する。

**重要:** GTO Wizard ページは描画が重く `npx agent-browser screenshot` がタイムアウトすることがある。Raw CDP WebSocket 経由で `Page.bringToFront` → `Page.captureScreenshot`（JPEG, quality=80）を使うこと。

スクリーンショット保存先:
```bash
mkdir -p ./hand-review-assets
```

**エラー時:** スクリーンショット取得に失敗した場合は、テキストベースのレビューのみで進める。

### Step 4: GTO Wizard ブログから関連記事を取得

WebSearch で GTO Wizard ブログから関連する戦略記事を検索する。

**検索クエリの構成:**

```
site:blog.gtowizard.com {spot-description}
```

例:
- `site:blog.gtowizard.com 3bet pot c-bet strategy`
- `site:blog.gtowizard.com BTN vs BB single raised pot`
- `site:blog.gtowizard.com ICM bubble play`
- `site:blog.gtowizard.com overbet strategy`

関連記事が見つかった場合は WebFetch で内容を取得し、レビューの根拠として活用する。
最大3記事まで取得する。取得できなくても手持ちの知識でレビューを進める（その旨を明記する）。

**重要: Exploit分析のプライマリソース**

Exploit に関する主張・推奨は、GTO Wizard ブログの記事データを最優先の根拠とする。
ブログ記事からの引用は以下の形式で出力に含める:

```markdown
> ポピュレーションはリバーの大きいベットに対して過剰にフォールドする傾向がある
> — [Population Tendencies: River Play](https://blog.gtowizard.com/...)
```

ブログ記事が見つからなかった場合は、一般的なポーカー理論に基づく旨を明示する。

### Step 5: 数学的分析

以下の計算を行い、各決定ポイントの数学的根拠を示す。
**すべての計算は途中式を含めて出力すること**（Evidence Policy参照）。

**4a. エクイティ分析**

- ヒーローのハンドが、想定されるヴィランのレンジに対してどの程度のエクイティを持つか
- GTO Wizard のソルバーデータから EV を参照し、各アクションの期待値を比較
- EVデータを引用する際は対応する [GTO Wizard URL]({URL}) を付与する

出力例:
```markdown
AKo の EV: Raise = +3.2bb, Call = +1.8bb, Fold = 0
— [GTO Wizard](https://app.gtowizard.com/solutions?gametype=...)
```

**4b. ポットオッズ計算**

コールを検討するスポットでは、計算過程を完全に示す:
```markdown
> **ポットオッズ:**
> ポット = {P}bb, ヴィランベット = {B}bb, コール額 = {B}bb
> 必要エクイティ = {B} / ({P} + {B} + {B}) = {B} / {合計} = **{結果}%**
> 式: 必要エクイティ = コール額 / (現在のポット + ベット + コール額)
```
- ヒーローのエクイティが必要エクイティを上回るか評価
- インプライドオッズ（スタックの深さによる追加価値）を考慮する場合も計算式を示す

**4c. ベットサイジング分析**

ベットを検討するスポットでは:
- GTO推奨サイジングと実際のサイジングを比較（ソルバーデータURLを付与）
- 各サイズにおけるフリクエンシーを示す
- MDF（Minimum Defense Frequency）を計算し式を示す:
```markdown
> **MDF:** MDF = {ポット} / ({ポット} + {ベット}) = {結果}%
```

**4d. フリクエンシー分析**

ソルバーデータから:
- ヒーローのハンドの各アクション頻度（ソルバーデータURLを付与）
- 同カテゴリのハンド群の平均フリクエンシー
- ミックス戦略の場合、その理由を説明

### Step 6: Exploit分析

GTO戦略からの逸脱が有益な状況を分析する。
**Exploit の主張には GTO Wizard ブログ記事を最優先の根拠とする**（Evidence Policy参照）。

**5a. ヴィランの傾向分析**

ユーザから得たヴィランのテンダンシー情報に基づき:
- **タイトすぎるヴィラン**: ブラフ頻度を上げる、薄いバリューベットを控える
- **ルースすぎるヴィラン**: バリューベット範囲を広げる、ブラフを減らす
- **パッシブなヴィラン**: 薄いバリューベットを増やす、チェックレイズを多用
- **アグレッシブなヴィラン**: トラップを増やす、ブラフキャッチ頻度を調整
- **情報不足の場合**: GTO戦略に従うことを推奨

各推奨には根拠を付与する:
- GTO Wizard ブログ記事がある場合 → `[出典: 記事タイトル](URL)` を付与
- ブログ記事がない場合 → `※ 一般的なポーカー理論に基づく` と明記

**5b. スポット固有のexploit**

WebSearch で以下のクエリを追加実行し、スポット固有のブログ記事を探す:
- `site:blog.gtowizard.com population tendencies {spot}`
- `site:blog.gtowizard.com exploit {spot}`
- `site:blog.gtowizard.com {bet-type} strategy` (例: overbet, donk bet, probe bet)

取得した記事のデータを根拠にexploitを分析する:
- ポピュレーションの傾向（一般的なプレイヤープールの偏り）
- ポジション別の傾向（例: BBのディフェンス頻度が低い一般プレイヤーに対する搾取）
- ベットサイズ別の傾向（例: オーバーベットに対する過剰フォールド傾向）

**5c. ICM考慮（トーナメントの場合）**

- バブルファクターの概算（計算式を示す）
- チップEV vs $EV の乖離
- リスクプレミアムの調整
- ICM関連のブログ記事: `site:blog.gtowizard.com ICM` で検索

### Step 7: HTML レビュードキュメント生成

レビュー内容を HTML として生成する。スクリーンショットは **base64 エンコード**してインラインで埋め込む（外部ファイル参照だと PDF 変換時に読み込めないため）。

**7a. スクリーンショットの base64 変換**

```bash
python3 -c "import base64,sys; print(base64.b64encode(open(sys.argv[1],'rb').read()).decode())" ./hand-review-assets/preflop-grid.jpg
```

**7b. HTML 生成**

以下のテンプレートに従い、`/tmp/hand-review-{ハンド}.html` に Write で出力する。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <title>Hand Review: {ヒーローハンド}</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown.min.css">
  <style>
    body {
      max-width: 980px;
      margin: 0 auto;
      padding: 30px;
      background: #fff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    }
    .markdown-body { max-width: 100%; }
    .screenshot { max-width: 100%; border: 1px solid #d0d7de; border-radius: 6px; margin: 12px 0; }
    .math-block { background: #f6f8fa; border-left: 3px solid #0969da; padding: 12px 16px; margin: 12px 0; font-family: monospace; }
    .assessment-good { border-left-color: #1a7f37; }
    .assessment-warn { border-left-color: #bf8700; }
    .assessment-bad  { border-left-color: #cf222e; }
    .exploit-quote { background: #fff8c5; border-left: 3px solid #bf8700; padding: 12px 16px; margin: 12px 0; }
    .source-link { font-size: 0.85em; color: #656d76; }
    table { border-collapse: collapse; width: 100%; margin: 12px 0; }
    th, td { border: 1px solid #d0d7de; padding: 8px 12px; text-align: left; }
    th { background: #f6f8fa; }
    h1 { border-bottom: 1px solid #d0d7de; padding-bottom: 8px; }
    h2 { border-bottom: 1px solid #d0d7de; padding-bottom: 6px; margin-top: 32px; }
    @media print {
      body { padding: 0; }
      .page-break { page-break-before: always; }
    }
  </style>
</head>
<body class="markdown-body">

<h1>Hand Review: {ヒーローハンド} — {スポット説明}</h1>

<table>
  <tr><th>Game Type</th><td>{MTT/Cash} {人数}max</td></tr>
  <tr><th>Effective Stack</th><td>{X}bb</td></tr>
  <tr><th>Hero Position</th><td>{ポジション}</td></tr>
  <tr><th>Hero Hand</th><td>{ハンド}</td></tr>
  <tr><th>Board</th><td>{ボード or "Preflop"}</td></tr>
</table>

<h3>Action Summary</h3>
<p>{各ストリートのアクションを時系列で記述}</p>

<hr>
<h2>Street-by-Street Analysis</h2>

<!-- ===== 各ストリートで以下を繰り返す ===== -->

<h3>Preflop</h3>

<p><strong>GTO Strategy</strong>
  (<a href="{ハンドURL}">GTO Wizard</a>):</p>

<img class="screenshot" src="data:image/jpeg;base64,{preflop-grid-base64}" alt="Preflop GTO Grid">

<ul>
  <li>{ハンド}: Raise {X}%, Call {Y}%, Fold {Z}%</li>
  <li>EV: Raise = {+A}bb, Call = {+B}bb</li>
</ul>

<h4>Aggregate Analysis（集合分析）</h4>

<img class="screenshot" src="data:image/jpeg;base64,{preflop-aggregate-base64}" alt="Preflop Aggregate">

<table>
  <tr><th>アクション</th><th>レンジ全体の頻度</th><th>コンボ数</th></tr>
  <tr><td>Raise</td><td>{X}%</td><td>{N} combos</td></tr>
  <tr><td>Call</td><td>{Y}%</td><td>{N} combos</td></tr>
  <tr><td>Fold</td><td>{Z}%</td><td>{N} combos</td></tr>
</table>

<p>{レンジ構成の特徴}</p>

<p><strong>Actual Play:</strong> {ヒーローの実際のアクション}</p>

<div class="math-block {assessment-good|assessment-warn|assessment-bad}">
  <strong>計算根拠:</strong><br>
  {具体的な計算式と途中過程}
</div>

<!-- Flop / Turn / River も同様の構造 -->
<!-- ストリート間に <div class="page-break"></div> を入れてPDFのページ送りを制御可能 -->

<hr>
<h2>Mathematical Summary</h2>

<table>
  <tr><th>Decision Point</th><th>GTO Action</th><th>Hero Action</th><th>GTO EV</th><th>Source</th><th>Assessment</th></tr>
  <tr><td>Preflop</td><td>...</td><td>...</td><td>...</td><td><a href="{URL}">GTO Wizard</a></td><td>✅/⚠️/❌</td></tr>
  <tr><td>Flop</td><td>...</td><td>...</td><td>...</td><td><a href="{URL}">GTO Wizard</a></td><td>✅/⚠️/❌</td></tr>
</table>

<hr>
<h2>Exploit Considerations</h2>

<div class="exploit-quote">
  {exploit に関する主張}<br>
  <span class="source-link">— <a href="https://blog.gtowizard.com/...">{記事タイトル}</a></span>
</div>

<!-- ブログ記事が見つからなかった場合 -->
<p><em>※ 一般的なポーカー理論に基づく推奨（GTO Wizard ブログに該当記事なし）</em></p>

<hr>
<h2>Key Takeaways</h2>

<ol>
  <li>{最も重要な学び}</li>
  <li>{改善ポイント}</li>
  <li>{良かった点}</li>
</ol>

<h2>References</h2>

<h3>GTO Wizard ソルバーデータ</h3>
<ul>
  <li><a href="{ハンドURL}">Preflop: {スポット説明}</a></li>
  <li><a href="{ハンドURL}">Flop: {スポット説明}</a></li>
</ul>

<h3>GTO Wizard ブログ記事</h3>
<ul>
  <li><a href="{URL}">{記事タイトル1}</a></li>
  <li><a href="{URL}">{記事タイトル2}</a></li>
</ul>

<h3>使用した計算式</h3>
<ul>
  <li>ポットオッズ: 必要エクイティ = コール額 / (ポット + ベット + コール額)</li>
  <li>MDF: ポット / (ポット + ベット)</li>
</ul>

</body>
</html>
```

### Step 8: PDF 変換

HTML を Chrome の `--print-to-pdf` で PDF に変換する。

**ファイル名の構成:**

```
hand-review-{日付}-{ハンド}-{スポット概要}.pdf
```

- `{日付}`: `YYYY-MM-DD`
- `{ハンド}`: ヒーローのハンド（例: `AKo`, `9d9c`）
- `{スポット概要}`: スポットを特定できる短い説明（英語、ハイフン区切り、小文字）

例:
- `hand-review-2026-04-11-AKo-CO-vs-BTN-3bet-100bb.pdf`
- `hand-review-2026-04-11-9d9c-BTN-open-30bb-bubble.pdf`
- `hand-review-2026-04-11-QJs-SRP-BTN-vs-BB-flop-cbet.pdf`

```bash
'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --headless \
  --disable-gpu \
  --no-sandbox \
  --print-to-pdf=./hand-review-{日付}-{ハンド}-{スポット概要}.pdf \
  --print-to-pdf-no-header \
  /tmp/hand-review-{日付}-{ハンド}-{スポット概要}.html
```

**注意事項:**
- `--print-to-pdf-no-header` でヘッダー/フッター（URL・日付）を除去する
- スクリーンショットは base64 インラインなので外部参照の問題なし
- CSS の `@media print` と `.page-break` でページ区切りを制御
- github-markdown-css は CDN 参照のため、Chrome がネットワークアクセス可能であること
- PDF 生成後、ターミナルにファイルパスを出力する

**出力ファイル:**
- PDF: `./hand-review-{日付}-{ハンド}-{スポット概要}.pdf`（デフォルト）
- HTML: `/tmp/hand-review-{日付}-{ハンド}-{スポット概要}.html`（中間ファイル、デバッグ用に残す）

### Step 9: フォローアップ

レビュー完了後:
1. ユーザに質問や追加分析の希望がないか確認する
2. 特定のストリートの深掘りや、異なるラインのシミュレーションを提案する
3. 類似スポットの学習リソース（GTO Wizard ブログ記事）を提案する

## Deep-dive documentation

| Reference | Description |
|-----------|-------------|
| [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md) | **PRIMARY** CDP Fetch インターセプトによるデータ取得 |
| [references/poker-math.md](references/poker-math.md) | ポーカー数学リファレンス |
| [references/exploit-guide.md](references/exploit-guide.md) | Exploit戦略ガイド |
