---
name: poker-hand-review-study
description: |
  ポーカーの座学スキル。ハンドレビューの結果や特定のスポットを起点に、
  集合分析をベースとした体系的な学習を行う。
  nihaoメソッド（集合分析→分類→理由考察→個別ボード→ストリート分岐）に準拠。
  「座学したい」「このスポットを勉強したい」「集合分析を見たい」「study」
  「深掘りして勉強」「このスポットの全体像を知りたい」でトリガーすること。
argument-hint: [spot-description or hand-review-pdf-path]
allowed-tools: Bash(npx agent-browser:*), Bash(python3:*), Bash(mkdir:*), Bash('/Applications/Google Chrome.app:*), Read, Write, Edit, WebFetch(https://blog.gtowizard.com/*), Fetch(https://blog.gtowizard.com/*), WebSearch, AskUserQuestion
---

# Hand Review Study — 集合分析ベースの座学

ハンドレビューの次のステップとして、そのスポットの**集合分析（Aggregate Analysis）**を起点に、
体系的な座学を行う。目的は個別ハンドの理解ではなく、**スポット全体の構造的理解**。

## 座学メソッド（nihaoメソッド準拠）

本スキルは以下の原則に基づく:

1. **集合分析 → 個別スポット確認** の流れを常に守る
2. すべてのフェーズで **分類/疑問点発見 → 考察** を繰り返す
3. 発見した法則が他のポジション関係やスポットでも成り立つかを確認し、**普遍的な理解**を得る
4. 各スポットで「**Indifference（ID）はどこか？**」を常に考える
5. 均衡戦略を模倣することが目的ではなく、**実戦でEVが高いアクションをする**ための理解を得る
6. 均衡の「なぜ」を考えることで、相手の偏りに対する**exploit戦略**を導出できるようにする

### 最低限抑える3つのポイント

各スポットで最低限確認するのは:
1. **使用されるbet sizeとbet range**
2. **check (x) range**
3. **betした後のディフェンス側 call/fold ID帯**

## 引数

- 第1引数（任意）: スポットの説明、またはhand-review PDFのパス
- 引数なしの場合: AskUserQuestion でスポットをヒアリングする

## Prerequisites

- **CDP-enabled browser**: GTO Wizard の集合分析・ソリューション閲覧に必要（Chrome or Vivaldi with `--remote-debugging-port=9222`）
- **GTO Wizard account**: https://app.gtowizard.com にログイン済み（Premium以上推奨）
- **agent-browser**: `npx agent-browser`

## Workflow

### Step 1: スポットの特定

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

### Step 2: 集合分析の取得とスクリーンショット

GTO Wizard の集合分析画面をCDP経由で取得する。
データ取得手順は [../poker-hand-review/references/cdp-data-acquisition.md](../poker-hand-review/references/cdp-data-acquisition.md) を参照。

1. **CDP接続:**
   ```bash
   npx agent-browser connect 9222
   ```

2. **GTO Wizard の集合分析画面にナビゲート:**

   GTO Wizard の Aggregate Analysis (集合分析) ページに遷移する。
   URL は solutions ページから集合分析ビューに切り替える形で取得する。

3. **集合分析のスクリーンショット取得:**
   ```bash
   mkdir -p ./study-assets
   npx agent-browser screenshot ./study-assets/aggregate-overview.jpg
   ```

4. **OOP / IP 両方の戦略を取得:**
   - OOP（Out of Position）の戦略集合分析
   - IP（In Position）の戦略集合分析
   - 必要に応じて、ディフェンス側の集合分析も取得

### Step 3: 集合分析からざっくり分類（nihaoメソッド ①②）

集合分析を眺め、ボードを**3〜5カテゴリ**にざっくり分類する。

**分類の観点:**
- bet頻度の高低
- 使用されるbet sizeの違い
- check頻度の違い
- ボードテクスチャ（ハイカード、コネクト度、スートedness）

**例: SB vs BTN 3bp Ahi board の場合**
```
① AThi以上（A + 2BW）: bet頻度高、small CB中心
② A9hi以下: bet頻度やや低
③ AMM連続（A87ttなど）: bet頻度が極端に低い
④ Monotone: 別カテゴリとして分離
```

**分類の理由を考察する:**
- なぜこの分類になるのか？
- お互いのレンジがボードにどうヒットしているか？
- エクイティ分布、ナッツアドバンテージ、レンジアドバンテージの観点

**他スポットとの比較:**
- 同じ分類が他のポジション関係でも成り立つか確認
- 成り立たない場合、なぜ異なるのかを考察
- → 今後の座学テーマとして記録

### Step 4: 分類ごとに個別ボードを抽出（nihaoメソッド ③）

各分類カテゴリから**代表的なボード**を1〜2個選定する。

**選定基準:**
- そのカテゴリの典型的なボード
- 自分がプレイ中に遭遇しやすいボード

**例:**
```
① AThi以上 → AJ5r
② A + 2BW → AQTtt
③ A9hi以下 → A94tt
④ AMM連続 → A87tt
```

### Step 5: 個別ボードのFlop戦略を詳細分析（nihaoメソッド ④）

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

### Step 6: Flop分岐ごとにTurn戦略を分類（nihaoメソッド ⑤⑥）

Flopで発生したサイズ分岐ごとに、Turnの戦略を分析する。

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

### Step 7: Turn以降の戦略を見る（nihaoメソッド ⑦）

各Flop分岐 × Turn card分類ごとに:

1. **Turn bet後のディフェンス戦略**
2. **Turn x/x後のRiver戦略**
3. **River到達時のレンジ構成**
4. **River bet/check の戦略**

ここでも常に:
- IDはどこか？
- なぜそのハンドがそのアクションを取るのか？
- 相手のレンジのどこをいじめているのか？

### Step 8: Exploit考察

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

### Step 9: 座学ノート生成（HTML → PDF）

以下の構造で座学ノートを HTML として生成し、Chrome で PDF に変換する。

**ファイル名:**
```
study-{日付}-{スポット概要}.pdf
```
例: `study-2026-04-11-SBvBTN-3bp-Ahi.pdf`

**HTML テンプレート構造:**

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

**PDF変換:**
```bash
'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --headless \
  --disable-gpu \
  --no-sandbox \
  --print-to-pdf=./study-{日付}-{スポット概要}.pdf \
  --print-to-pdf-no-header \
  /tmp/study-{日付}-{スポット概要}.html
```

### Step 10: フォローアップ

座学完了後:
1. **今後の座学テーマ**をまとめて提示する
2. 類似スポットでの検証（他ポジション関係、他スタック深度）を提案する
3. **ウィザトレ（Wizard Training）** での復習を提案する:
   - GTO Wizard の Training > Custom でスポットを設定
   - 座学で学んだ内容を仮説として持ちながらプレイ
   - プレイ後に仮説を検証

## 座学における思考フレームワーク

各ストリートで以下の順番で思考する（ウィザトレでも同様）:

1. **相手の直前ストリートの戦略は何か**
2. **現在のお互いの残レンジはどのような状態か**
3. **打てるvalue handはどれか、いじめられる対象は相手レンジのどこか、どのようなbet sizeを用意できるか**
4. **それぞれのアクションに対して相手はどのような戦略をとってくるのか**
5. **相手ディフェンス戦略を踏まえた上で、bluff handはどこを採用すべきか**
6. **アクション決定**

## 用語集

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
| [../poker-hand-review/references/cdp-data-acquisition.md](../poker-hand-review/references/cdp-data-acquisition.md) | CDP Fetch インターセプトによるデータ取得 |
| [../poker-hand-review/references/poker-math.md](../poker-hand-review/references/poker-math.md) | ポーカー数学リファレンス |
| [../poker-hand-review/references/exploit-guide.md](../poker-hand-review/references/exploit-guide.md) | Exploit戦略ガイド |
