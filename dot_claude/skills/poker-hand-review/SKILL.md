---
name: poker-hand-review
description: |
  ポーカーのハンドレビューと座学を行うスキル。2つのモードを持つ。
  [review] ユーザのハンドをGTO Wizardのソルバーデータとブログ記事を根拠に多角的にレビューする。
  数学的根拠（ポットオッズ、エクイティ、EV計算）とexploit観点を含む。
  [study] 集合分析をベースとした体系的な座学を行う。個別ハンドではなくスポット全体の構造的理解が目的。
  「ハンドレビューして」「このハンドどう思う？」「レビューお願い」「hand review」
  「この判断正しかった？」→ review mode
  「座学したい」「このスポットを勉強したい」「集合分析を見たい」「study」
  「深掘りして勉強」「このスポットの全体像を知りたい」→ study mode
argument-hint: [hand-description, hand-history, or spot-description]
allowed-tools: Bash(npx agent-browser:*), Bash(python3:*), Bash(mkdir:*), Bash('/Applications/Google Chrome.app:*), Read, Write, Edit, WebFetch(https://blog.gtowizard.com/*), Fetch(https://blog.gtowizard.com/*), WebSearch, AskUserQuestion
---

# Poker Hand Review

ユーザのポーカーハンドを多角的にレビュー [review]、または集合分析ベースの体系的な座学 [study] を行う。

## Mode Selection

このスキルには2つのモードがある。ユーザの入力からモードを自動判定する。判定できない場合は AskUserQuestion で確認する。

**モードラベルの読み方:**
- `[review]` — review mode のみで実行するセクション
- `[study]` — study mode のみで実行するセクション
- ラベルなし — 両モード共通

| Mode | トリガーワード | 目的 |
|------|--------------|------|
| **review** | 「ハンドレビューして」「このハンドどう思う？」「レビューお願い」「hand review」「この判断正しかった？」 | 個別ハンドの数学的分析＋exploit観点 |
| **study** | 「座学したい」「このスポットを勉強したい」「集合分析を見たい」「study」「深掘りして勉強」「このスポットの全体像を知りたい」 | スポット全体の構造的理解 |

**引数:**
- 第1引数（任意）: [review] ハンド情報（自然言語テキスト、またはハンドヒストリーファイルのパス） / [study] スポットの説明、またはhand-review PDFのパス
- 引数なしの場合: AskUserQuestion で情報をヒアリングする

### [study] 座学メソッド（既存メソッド準拠）

1. **集合分析 → 個別スポット確認** の流れを常に守る
2. すべてのフェーズで **分類/疑問点発見 → 考察** を繰り返す
3. 発見した法則が他のポジション関係やスポットでも成り立つかを確認し、**普遍的な理解**を得る
4. 各スポットで「**Indifference（ID）はどこか？**」を常に考える
5. 均衡戦略を模倣することが目的ではなく、**実戦でEVが高いアクションをする**ための理解を得る
6. 均衡の「なぜ」を考えることで、相手の偏りに対する**exploit戦略**を導出できるようにする

**最低限抑える3つのポイント:**
1. **使用されるbet sizeとbet range**
2. **check (x) range**
3. **betした後のディフェンス側 call/fold ID帯**

## Prerequisites

- **CDP-enabled browser**: GTO Wizard のソルバーデータ取得・スクリーンショットに必要（Chrome or Vivaldi with `--remote-debugging-port=9222`）
- **GTO Wizard account**: https://app.gtowizard.com にブラウザでログイン済みであること（[study] Premium以上推奨）
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

### Step 1: 情報収集

#### [review] ハンド情報の収集

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

#### [study] スポットの特定

ユーザから座学対象のスポットを収集する。

**hand-review の出力がある場合:**
- PDFまたはHTMLを Read で読み込み、スポット情報を抽出
- レビューで課題が見つかったストリート/スポットを起点にする

**スポットを新規指定する場合:**
以下を AskUserQuestion で確認:
- ポジション関係（例: SB vs BTN, CO vs BB）
- ポットタイプ（SRP / 3bet pot / 4bet pot）
- ストリート（Preflop / Flop / Turn / River）
- ボードテクスチャの関心（例: Ahi board, low board, monotone）
- スタック深度（デフォルト: 100bb）
- ゲームタイプ（MTT / Cash）

### Step 2: CDP経由でデータ取得

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

5. **[review] 各決定ポイントでデータ取得 + スクリーンショット**:
   - ヒーローがアクションする各地点でソルバーデータを取得
   - 必要に応じてヴィランの戦略も取得
   - **同時に** CDP `Page.captureScreenshot` でハンドマトリクスのスクリーンショットを取得
   - 各クエリに対応する GTO Wizard URL を記録（Evidence Policy 参照）

6. **[study] 集合分析画面の取得**:
   - GTO Wizard の Aggregate Analysis (集合分析) ページに遷移する
   - OOP（Out of Position）の戦略集合分析を取得
   - IP（In Position）の戦略集合分析を取得
   - 必要に応じて、ディフェンス側の集合分析も取得

7. **スクリーンショット取得**:

   **重要:** GTO Wizard ページは描画が重く `npx agent-browser screenshot` がタイムアウトすることがある。Raw CDP WebSocket 経由で `Page.bringToFront` → `Page.captureScreenshot`（JPEG, quality=80）を使うこと。

   ```bash
   # [review]
   mkdir -p ./hand-review-assets
   # [study]
   mkdir -p ./study-assets
   ```

   **エラー時:** スクリーンショット取得に失敗した場合は、テキストベースのレビュー/分析のみで進める。

8. **エラーハンドリング**（[references/cdp-data-acquisition.md](references/cdp-data-acquisition.md#エラーハンドリング) 参照）:
   - CDP 接続失敗 → ブラウザ起動を案内
   - 認証切れ → `document.title` でログインページ検出、再ログインを案内
   - Fetch タイムアウト → `Page.reload({ignoreCache: true})` で強制リロード

### Step 3: ブログ記事取得

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

関連記事が見つかった場合は WebFetch で内容を取得し、分析の根拠として活用する。
最大3記事まで取得する。取得できなくても手持ちの知識で分析を進める（その旨を明記する）。

**重要: Exploit分析のプライマリソース**

Exploit に関する主張・推奨は、GTO Wizard ブログの記事データを最優先の根拠とする。
ブログ記事からの引用は以下の形式で出力に含める:

```markdown
> ポピュレーションはリバーの大きいベットに対して過剰にフォールドする傾向がある
> — [Population Tendencies: River Play](https://blog.gtowizard.com/...)
```

ブログ記事が見つからなかった場合は、一般的なポーカー理論に基づく旨を明示する。

### Step 4 [review]: 数学的分析

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

### Step 4 [study]: 集合分析から分類

集合分析を眺め、ボードを**3〜5カテゴリ**にざっくり分類する。

**分類の観点:**
- bet頻度の高低
- 使用されるbet sizeの違い
- check頻度の違い
- ボードテクスチャ（ハイカード、コネクト度、スートedness）

**例: SB vs BTN 3bp Ahi board の場合**
```
1. AThi以上（A + 2BW）: bet頻度高、small CB中心
2. A9hi以下: bet頻度やや低
3. AMM連続（A87ttなど）: bet頻度が極端に低い
4. Monotone: 別カテゴリとして分離
```

**分類の理由を考察する:**
- なぜこの分類になるのか？
- お互いのレンジがボードにどうヒットしているか？
- エクイティ分布、ナッツアドバンテージ、レンジアドバンテージの観点

**他スポットとの比較:**
- 同じ分類が他のポジション関係でも成り立つか確認
- 成り立たない場合、なぜ異なるのかを考察
- → 今後の座学テーマとして記録

### Step 5 [review]: Exploit分析

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

### Step 5 [study]: 個別ボード分析

各分類カテゴリから**代表的なボード**を1〜2個選定する。

**選定基準:**
- そのカテゴリの典型的なボード
- 自分がプレイ中に遭遇しやすいボード

**例:**
```
1. AThi以上 → AJ5r
2. A + 2BW → AQTtt
3. A9hi以下 → A94tt
4. AMM連続 → A87tt
```

各ボードについて、CDP経由でソリューションを取得し、以下を確認する。

**確認ポイント:**

1. **使用されているbet size:**
   - どのサイズが利用可能か（Progressive Discoveryで確認）
   - 各サイズの全体頻度

2. **各サイズに選定されているhand群:**
   - value rangeの構成（top pair+? overpair?）
   - bluff rangeの構成（FD? BDFD? overcards?）
   - 各ハンドカテゴリのbet頻度

3. **check rangeに入っているhand群:**
   - トラップしているstrong hands
   - check-raise candidateになるhands
   - 諦めているtrash hands

4. **各サイズのbetに対するディフェンス側のcall/fold ID帯:**
   - pure callになっているhands
   - pure foldになっているhands
   - call/foldのIDラインはどこか
   - raiseに回しているhands

5. **「なぜそうなっているのか？」を常に問う:**
   - betレンジの特定ハンドの頻度が高い/低い理由
   - 相手のディフェンス戦略から逆算した説明

**スクリーンショット:**
各ボードのハンドマトリクスを取得し、`./study-assets/{board}-{action}.jpg` に保存。

### Step 6 [study]: Turn以降の分岐分析

Flopで発生したサイズ分岐ごとに、Turn以降の戦略を分析する。

**分岐の例:**
```
Node A: Flop OOP small CB → Turn
Node B: Flop OOP large CB → Turn
Node C: Flop IP stab (OOP x → IP bet) → Turn
Node D: Flop x/x → Turn
```

**各分岐について:**

1. **Turn card別の集合分析を確認:**
   - どのカードが落ちるとbet頻度が上昇/低下するか
   - Turn cardを分類（例: 「BW」「middle paired」「low」「flush complete」「A」）

2. **Turn集合分析のスクリーンショット取得**

3. **Turn OOP/IP の戦略確認:**
   - 各Turn card分類ごとの戦略の違い
   - probe bet / second barrel の頻度と条件

4. **Turn bet後のディフェンス戦略**

5. **Turn x/x後のRiver戦略**

6. **River到達時のレンジ構成**

7. **River bet/check の戦略**

ここでも常に:
- IDはどこか？
- なぜそのハンドがそのアクションを取るのか？
- 相手のレンジのどこをいじめているのか？

### Step 7 [study]: Exploit考察

均衡解の「なぜ」を理解した上で、実戦での活用を考える。

**考察の枠組み:**

```
均衡ではXXが{action}のIDになっている
→ 実戦の相手はIDレンジをover call / over foldしていそうか？
→ over callの場合:
  - size upできるspotなのでは？
  - valueの下限を下げる余地はあるか？
  - 相手のover callをブロックしているhandのbluff EVは低下する
→ over foldの場合:
  - bluff頻度を上げられる
  - thin valueが通らなくなる → value rangeを絞る
```

**GTO Wizard ブログからのエビデンス:**
WebSearch で `site:blog.gtowizard.com` を検索し、該当スポットの exploit 記事を取得。
exploit考察には必ずブログ記事のURLを付与する（Evidence Policy準拠）。

### Step 8: HTMLレポート生成

レビュー/座学の内容を HTML として生成する。スクリーンショットは **base64 エンコード**してインラインで埋め込む（外部ファイル参照だと PDF 変換時に読み込めないため）。

**base64 変換:**

```bash
python3 -c "import base64,sys; print(base64.b64encode(open(sys.argv[1],'rb').read()).decode())" ./hand-review-assets/preflop-grid.jpg
```

#### [review] HTML テンプレート

以下のテンプレートに従い、`/tmp/hand-review-{日付}-{ハンド}-{スポット概要}.html` に Write で出力する。

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

<h4>Aggregate Analysis</h4>

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
  <tr><td>Preflop</td><td>...</td><td>...</td><td>...</td><td><a href="{URL}">GTO Wizard</a></td><td>...</td></tr>
  <tr><td>Flop</td><td>...</td><td>...</td><td>...</td><td><a href="{URL}">GTO Wizard</a></td><td>...</td></tr>
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

#### [study] HTML テンプレート

以下のテンプレートに従い、`/tmp/study-{日付}-{スポット概要}.html` に Write で出力する。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <title>Study: {スポット概要}</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown.min.css">
  <style>
    body { max-width: 980px; margin: 0 auto; padding: 30px; background: #fff; }
    .markdown-body { max-width: 100%; }
    .screenshot { max-width: 100%; border: 1px solid #d0d7de; border-radius: 6px; margin: 12px 0; }
    .insight { background: #dafbe1; border-left: 3px solid #1a7f37; padding: 12px 16px; margin: 12px 0; }
    .question { background: #fff8c5; border-left: 3px solid #bf8700; padding: 12px 16px; margin: 12px 0; }
    .exploit { background: #ffebe9; border-left: 3px solid #cf222e; padding: 12px 16px; margin: 12px 0; }
    .future-topic { background: #ddf4ff; border-left: 3px solid #0969da; padding: 12px 16px; margin: 12px 0; }
    table { border-collapse: collapse; width: 100%; margin: 12px 0; }
    th, td { border: 1px solid #d0d7de; padding: 8px 12px; }
    th { background: #f6f8fa; }
    .source-link { font-size: 0.85em; color: #656d76; }
    @media print { .page-break { page-break-before: always; } }
  </style>
</head>
<body class="markdown-body">

<h1>Study: {スポット概要}</h1>

<table>
  <tr><th>ポジション関係</th><td>{OOP} vs {IP}</td></tr>
  <tr><th>ポットタイプ</th><td>{SRP / 3bp / 4bp}</td></tr>
  <tr><th>スタック深度</th><td>{X}bb</td></tr>
  <tr><th>ゲームタイプ</th><td>{MTT / Cash}</td></tr>
</table>

<hr>
<h2>1. 集合分析 — 全体像</h2>

<img class="screenshot" src="data:image/jpeg;base64,{aggregate-base64}" alt="Aggregate Overview">

<h3>分類</h3>
<table>
  <tr><th>カテゴリ</th><th>特徴</th><th>代表ボード</th></tr>
  <tr><td>{カテゴリ1}</td><td>{特徴}</td><td>{ボード}</td></tr>
  <!-- ... -->
</table>

<div class="insight">
  <strong>分類の理由:</strong><br>
  {なぜこの分類になるのか、レンジとボードの関係から考察}
</div>

<div class="question">
  <strong>疑問点:</strong><br>
  {集合分析から生まれた疑問}
</div>

<hr>
<h2>2. 個別ボード分析</h2>

<!-- 各ボードについて繰り返す -->
<h3>Board: {ボード} （カテゴリ: {分類名}）</h3>

<h4>OOP戦略</h4>
<img class="screenshot" src="data:image/jpeg;base64,{board-oop-base64}" alt="{board} OOP Strategy">

<table>
  <tr><th>Action</th><th>Size</th><th>Frequency</th><th>主なHand群</th></tr>
  <tr><td>Bet</td><td>{size}</td><td>{freq}%</td><td>{hands}</td></tr>
  <tr><td>Check</td><td>—</td><td>{freq}%</td><td>{hands}</td></tr>
</table>

<h4>IPディフェンス — ID帯</h4>
<img class="screenshot" src="data:image/jpeg;base64,{board-ip-defense-base64}" alt="{board} IP Defense">

<table>
  <tr><th>Hand群</th><th>Action</th><th>備考</th></tr>
  <tr><td>{hands}</td><td>Pure Call</td><td>{理由}</td></tr>
  <tr><td>{hands}</td><td>Call/Fold ID</td><td>{理由}</td></tr>
  <tr><td>{hands}</td><td>Pure Fold</td><td>{理由}</td></tr>
</table>

<div class="insight">
  <strong>発見:</strong><br>
  {このボードで発見した構造的な理解}
</div>

<!-- Turn分岐分析... -->

<hr>
<h2>3. Turn以降の分岐</h2>

<h3>Node: {Flop action} → Turn</h3>

<h4>Turn card別 集合分析</h4>
<img class="screenshot" src="data:image/jpeg;base64,{turn-aggregate-base64}" alt="Turn Aggregate">

<table>
  <tr><th>Turn card分類</th><th>Bet頻度変化</th><th>Key insight</th></tr>
  <tr><td>{分類}</td><td>{変化}</td><td>{insight}</td></tr>
</table>

<!-- 各Turn分類の詳細... -->

<hr>
<h2>4. Exploit考察</h2>

<div class="exploit">
  <strong>ID帯からのexploit:</strong><br>
  {均衡のIDを起点としたexploit考察}<br>
  <span class="source-link">— <a href="{blog-url}">{記事タイトル}</a></span>
</div>

<hr>
<h2>5. 今後の座学テーマ</h2>

<div class="future-topic">
  <ul>
    <li>{分析中に発見した、今後深掘りすべきテーマ}</li>
    <li>{他ポジション関係での確認事項}</li>
    <li>{類似スポットでの検証事項}</li>
  </ul>
</div>

<h2>References</h2>
<ul>
  <li><a href="{URL}">GTO Wizard: {スポット}</a></li>
  <li><a href="{blog-url}">{ブログ記事タイトル}</a></li>
</ul>

</body>
</html>
```

### Step 9: PDF変換

HTML を Chrome の `--print-to-pdf` で PDF に変換する。

**ファイル名の構成:**

- [review]: `hand-review-{日付}-{ハンド}-{スポット概要}.pdf`
- [study]: `study-{日付}-{スポット概要}.pdf`

**日付・命名ルール:**
- `{日付}`: `YYYY-MM-DD`
- `{ハンド}`: ヒーローのハンド（例: `AKo`, `9d9c`）— review のみ
- `{スポット概要}`: スポットを特定できる短い説明（英語、ハイフン区切り、小文字）

**ファイル名例:**
- [review] `hand-review-2026-04-11-AKo-CO-vs-BTN-3bet-100bb.pdf`
- [review] `hand-review-2026-04-11-9d9c-BTN-open-30bb-bubble.pdf`
- [study] `study-2026-04-11-SBvBTN-3bp-Ahi.pdf`

```bash
'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --headless \
  --disable-gpu \
  --no-sandbox \
  --print-to-pdf=./{ファイル名}.pdf \
  --print-to-pdf-no-header \
  /tmp/{ファイル名}.html
```

**注意事項:**
- `--print-to-pdf-no-header` でヘッダー/フッター（URL・日付）を除去する
- スクリーンショットは base64 インラインなので外部参照の問題なし
- CSS の `@media print` と `.page-break` でページ区切りを制御
- github-markdown-css は CDN 参照のため、Chrome がネットワークアクセス可能であること
- PDF 生成後、ターミナルにファイルパスを出力する

**出力ファイル:**
- PDF: `./{ファイル名}.pdf`（デフォルト）
- HTML: `/tmp/{ファイル名}.html`（中間ファイル、デバッグ用に残す）

### Step 10: フォローアップ

#### [review] フォローアップ

1. ユーザに質問や追加分析の希望がないか確認する
2. 特定のストリートの深掘りや、異なるラインのシミュレーションを提案する
3. 類似スポットの学習リソース（GTO Wizard ブログ記事）を提案する
4. **座学モードへの移行を提案**: レビューで課題が見つかったスポットについて「座学したい」で study mode に移行できることを案内する

#### [study] フォローアップ

1. **今後の座学テーマ**をまとめて提示する
2. 類似スポットでの検証（他ポジション関係、他スタック深度）を提案する
3. **ウィザトレ（Wizard Training）** での復習を提案する:
   - GTO Wizard の Training > Custom でスポットを設定
   - 座学で学んだ内容を仮説として持ちながらプレイ
   - プレイ後に仮説を検証

## [study] 思考フレームワーク

各ストリートで以下の順番で思考する（ウィザトレでも同様）:

1. **相手の直前ストリートの戦略は何か**
2. **現在のお互いの残レンジはどのような状態か**
3. **打てるvalue handはどれか、いじめられる対象は相手レンジのどこか、どのようなbet sizeを用意できるか**
4. **それぞれのアクションに対して相手はどのような戦略をとってくるのか**
5. **相手ディフェンス戦略を踏まえた上で、bluff handはどこを採用すべきか**
6. **アクション決定**

## [study] 用語集

| 略語 | 意味 |
|------|------|
| x | check |
| c | call |
| r | raise |
| stab | IP BMCB (Bet Missed C-Bet) |
| probe | OOP BMCB |
| BW | Broadway |
| XXXr | rainbow board |
| XXXtt | two tone board |
| FD | flush draw |
| BDFD | back door flush draw |
| SD | straight draw |
| GSSD | gutshot straight draw |
| 3bp | 3bet pot |
| ID | indifference（コール/フォールドが同EV） |

## Deep-dive documentation

| Reference | Description |
|-----------|-------------|
| [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md) | **PRIMARY** CDP Fetch インターセプトによるデータ取得 |
| [references/poker-math.md](references/poker-math.md) | ポーカー数学リファレンス |
| [references/exploit-guide.md](references/exploit-guide.md) | Exploit戦略ガイド |
