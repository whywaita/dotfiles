---
name: poker-hand-review
description: |
  ポーカーのハンドレビューと座学を統合的に行うスキル。
  ユーザのハンドをGTO Wizardのソルバーデータとブログ記事を根拠に多角的にレビューし、
  同時に集合分析ベースの体系的な座学を実施する。
  数学的根拠（ポットオッズ、エクイティ、EV計算）とexploit観点を含む。
  「ハンドレビューして」「このハンドどう思う？」「レビューお願い」「hand review」
  「この判断正しかった？」「座学したい」「このスポットを勉強したい」
  「集合分析を見たい」「深掘りして勉強」「このスポットの全体像を知りたい」
argument-hint: [hand-description, hand-history, or spot-description]
allowed-tools: Bash(npx agent-browser:*), Bash(python3:*), Bash(mkdir:*), Bash('/Applications/Google Chrome.app:*), Read, Write, Edit, WebFetch(https://blog.gtowizard.com/*), Fetch(https://blog.gtowizard.com/*), WebSearch, AskUserQuestion
---

# Poker Hand Review

ユーザのポーカーハンドを多角的にレビュー（review）と集合分析ベースの体系的な座学（study）を**常に同一エントリで両方生成**する。

## 基本方針

- **review と study の区別は行わない。すべてのジャーナルで両方を必ず生成する。**
- 個別ハンドの数学的分析（review）と、スポット全体の構造的理解（study）は表裏一体で、
  片方だけでは実戦に活かせる学びにならない。
- ユーザの入力がハンド情報のみでも、そのスポットの集合分析まで遡って学びを得る。
- ユーザの入力がスポット指定のみでも、代表ハンドを置いて個別レビューを行う。

**引数:**
- 第1引数（任意）: ハンド情報（自然言語テキスト、ハンドヒストリーファイルのパス、またはスポット説明）
- 引数なしの場合: AskUserQuestion で情報をヒアリングする

## 座学メソッド（既存メソッド準拠）

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
- **GTO Wizard account**: https://app.gtowizard.com にブラウザでログイン済みであること（Premium以上推奨）
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

## スクリーンショット要件（必須・最重要）

**スクリーンショット取得時は以下の表示状態を必ず確認すること。条件を満たさないスクリーンショットは無効とみなし、再撮影する。**

### A. 個別ボードのスクリーンショット要件

**個別スポット（特定ボード上の特定ノード）を撮影する際は、以下2種類を必ず取得する:**

1. **Strategy + EV ビュー**
   - ハンドマトリクスの各セルに **Strategy（アクション頻度の色分け）と EV 値の両方** が表示されている状態
   - GTO Wizard 上で「Strategy」表示と「EV」表示を**同時に**有効にする
   - UI上で `EV` トグル/カラムを ON にする操作を `npx agent-browser eval` で行う
   - 撮影前に snapshot で「EV 表示が有効か」をテキストで確認する
2. **Equity Charts**
   - エクイティ分布グラフ（ヒーロー側・ヴィラン側のレンジ vs レンジのエクイティ分布）
   - GTO Wizard の "Equity" / "Equities" タブまたはボタンを開いてから撮影
   - OOP / IP 両方のレンジが表示されていることを確認する

**確認手順（撮影前ゲート）:**

```bash
# Strategy+EV ビューが有効か確認
npx agent-browser snapshot -i | grep -iE "(EV|Equity)"

# 期待: "EV" カラムまたはトグルがアクティブ状態として現れる
# 不在 → eval で EV トグルをクリック → 再 snapshot → 確認できたら撮影
```

### B. 集合分析のスクリーンショット要件

集合分析ビューでも、可能な限り **Strategy + EV** と **Equity** の両方の表示を確認する。
集合分析特有の表示として、各ボード/カードごとの戦略と EV / エクイティが俯瞰できることが重要。

### C. 失敗時のリカバリ

- スクリーンショットが取れたが Strategy+EV / Equity Charts が映っていない → **必ず再撮影する**
- それでも取得できない場合のみ、テキストベースの分析にフォールバックし、その旨を明記する

## Workflow

### Step 1: 情報収集

ユーザから以下の情報を収集する。不足情報は AskUserQuestion で確認する。
必須情報が揃わない場合でも、得られた情報の範囲で最善のレビュー＋座学を行う。

**必須情報:**

- ヒーローのハンド（例: AsKh, 9d9c）— 不明な場合は代表ハンドを置く
- ポジション関係（例: BTN vs BB, CO vs BTN）
- プリフロップアクション（誰がオープン、3betなど）

**推奨情報:**

- ゲームタイプ（MTT / Cash / SNG）
- テーブル人数（6max / 8max / 9max）
- 有効スタック（bb単位、デフォルト 100bb）
- ボード（フロップ / ターン / リバー）
- 各ストリートのアクション
- ポットサイズ
- ヴィランのテンダンシー・リード（わかる範囲で）
- ボードテクスチャの関心（study観点: Ahi, low, monotone等）

**トーナメント固有情報（MTTの場合）:**

- ブラインドレベル / アンティ構造
- ICM状況（バブル付近、ファイナルテーブルなど）
- 残りプレイヤー数 / ペイアウト構造

**hand-review の出力（既存journalや過去PDF）がある場合:**
- PDFまたはHTMLを Read で読み込み、スポット情報を抽出
- 過去のレビューで課題が見つかったストリート/スポットを起点に拡張する

### Step 2: CDP経由でデータ取得（review + study 統合フロー）

CDP (Chrome DevTools Protocol) の `Fetch` ドメインを使い、GTO Wizard の内部 API レスポンスをインターセプトしてソルバーデータを取得する。詳細は [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md) を参照。

1. **CDP 接続確認**:
   ```bash
   npx agent-browser connect 9222
   ```
   - 接続失敗時: ユーザに `--remote-debugging-port=9222` でブラウザを起動するよう案内

2. **GTO Wizard URL を構築**（[references/cdp-data-acquisition.md](references/cdp-data-acquisition.md#シナリオ変換ガイド) 参照）

3. **CDP Fetch インターセプトでデータ取得**

4. **Progressive Bet Size Discovery（ブラウザ版）**: ベットサイズを推測してはならない

5. **アセットディレクトリ作成**:
   ```bash
   mkdir -p ./poker-assets
   ```

### Step 3: ストリート進行のゲート（**最重要・必須**）

**次のストリートに進む前に、必ずそのストリートの集合分析を確認すること。**
これは review / study どちらの目的でも例外なく適用される。
個別ハンドのレビューであっても、Turn / River の落ちるカードの**全体的な系譜**を把握しないと
そのスポットの戦略変化の理由を理解できない。

**ストリートゲートの実行順序:**

```
[Preflop 確定]
   ↓
[Flop 集合分析] ← 全フロップボードの戦略傾向を確認 (OOP/IP両方)
   ↓
[Flop 個別ボード分析] ← 該当ボードの Strategy+EV と Equity Charts を撮影
   ↓
   ┌─ ここで Turn に進む前に必ず ─┐
   ↓
[Turn 集合分析] ← Flopアクション後の全Turn cardでの戦略変化を確認 (OOP/IP両方)
   ↓
[Turn 個別カード分析] ← 該当Turnでの Strategy+EV と Equity Charts を撮影
   ↓
   ┌─ ここで River に進む前に必ず ─┐
   ↓
[River 集合分析] ← Turnアクション後の全River cardでの戦略変化を確認 (OOP/IP両方)
   ↓
[River 個別カード分析] ← 該当Riverでの Strategy+EV と Equity Charts を撮影
```

**各ゲートで必ず実施すること:**

1. 集合分析ビューに切替（OOP / IP 両方）
2. 集合分析のスクリーンショットを取得（`./poker-assets/{street}-aggregate-{oop|ip}.jpg`）
3. **落ちるカードのカテゴリ別の戦略変化を観察**:
   - Turn: Broadway / Middle / Low / Paired / Flush complete などのカテゴリで頻度がどう変わるか
   - River: ポーラライズ度合い、ブラフ候補の変化、ポーラライズしたカードの傾向
4. 観察した内容を journal の該当セクションに記録（テキスト + スクリーンショット）
5. **ゲートを通過したら個別カード分析に進む**

**ゲート違反の検出:** 個別カード分析のセクションを生成する前に、対応する集合分析セクションが
journal 内に存在することを確認すること。存在しない場合は遡って取得する。

### Step 4: ブログ記事取得

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

### Step 5: 数学的分析（review 観点）

以下の計算を行い、各決定ポイントの数学的根拠を示す。
**すべての計算は途中式を含めて出力すること**（Evidence Policy参照）。

**5a. エクイティ分析**

- ヒーローのハンドが、想定されるヴィランのレンジに対してどの程度のエクイティを持つか
- GTO Wizard のソルバーデータから EV を参照し、各アクションの期待値を比較
- EVデータを引用する際は対応する [GTO Wizard URL]({URL}) を付与する
- **Equity Charts のスクリーンショット**を併せて掲載すること

出力例:
```markdown
AKo の EV: Raise = +3.2bb, Call = +1.8bb, Fold = 0
— [GTO Wizard](https://app.gtowizard.com/solutions?gametype=...)
```

**5b. ポットオッズ計算**

```markdown
> **ポットオッズ:**
> ポット = {P}bb, ヴィランベット = {B}bb, コール額 = {B}bb
> 必要エクイティ = {B} / ({P} + {B} + {B}) = {B} / {合計} = **{結果}%**
> 式: 必要エクイティ = コール額 / (現在のポット + ベット + コール額)
```

**5c. ベットサイジング分析**

- GTO推奨サイジングと実際のサイジングを比較（ソルバーデータURLを付与）
- 各サイズにおけるフリクエンシーを示す
- MDF（Minimum Defense Frequency）の式を示す:
```markdown
> **MDF:** MDF = {ポット} / ({ポット} + {ベット}) = {結果}%
```

**5d. フリクエンシー分析**

- ヒーローのハンドの各アクション頻度（ソルバーデータURLを付与）
- 同カテゴリのハンド群の平均フリクエンシー
- ミックス戦略の場合、その理由を説明

### Step 6: 集合分析からの分類（study 観点）

Step 3 のストリートゲートで取得した集合分析データを眺め、ボード/カードを **3〜5カテゴリ** にざっくり分類する。

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

### Step 7: 個別ボード/カード分析

各分類カテゴリから**代表的なボード/カード**を1〜2個選定する（ヒーローが実際に経験したボードは必ず含める）。

**選定基準:**
- そのカテゴリの典型的なボード
- 自分がプレイ中に遭遇しやすいボード
- 当該ハンド（review対象）が実際に通ったボード

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

**スクリーンショット（必須要件あり、上記「スクリーンショット要件」参照）:**

- `./poker-assets/{street}-{board}-{action}-strategy-ev.jpg` (Strategy + EV ビュー)
- `./poker-assets/{street}-{board}-{action}-equity.jpg` (Equity Charts)

### Step 8: Exploit分析

GTO戦略からの逸脱が有益な状況を分析する。
**Exploit の主張には GTO Wizard ブログ記事を最優先の根拠とする**（Evidence Policy参照）。

**8a. ヴィランの傾向分析**

- **タイトすぎるヴィラン**: ブラフ頻度を上げる、薄いバリューベットを控える
- **ルースすぎるヴィラン**: バリューベット範囲を広げる、ブラフを減らす
- **パッシブなヴィラン**: 薄いバリューベットを増やす、チェックレイズを多用
- **アグレッシブなヴィラン**: トラップを増やす、ブラフキャッチ頻度を調整
- **情報不足の場合**: GTO戦略に従うことを推奨

**8b. ID帯ベースのexploit考察（study観点）**

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

**8c. スポット固有のexploit**

WebSearch で以下のクエリを追加実行し、スポット固有のブログ記事を探す:
- `site:blog.gtowizard.com population tendencies {spot}`
- `site:blog.gtowizard.com exploit {spot}`
- `site:blog.gtowizard.com {bet-type} strategy`

**8d. ICM考慮（トーナメントの場合）**

- バブルファクターの概算（計算式を示す）
- チップEV vs $EV の乖離
- リスクプレミアムの調整
- ICM関連のブログ記事: `site:blog.gtowizard.com ICM` で検索

### Step 9: ジャーナルエントリ生成

分析結果を GitHub Pages ジャーナルのエントリとして出力する。
**review と study は同一エントリ（同一ページ）に統合され、両方のセクションが必ず含まれる。**

**出力先とテンプレート:**
- ディレクトリ構成・パス命名規則: [references/journal-structure.md](references/journal-structure.md)
- HTML テンプレート: [references/journal-template.html](references/journal-template.html)

#### 9a. 出力先の決定

1. ジャーナルルートを確認する（初回は AskUserQuestion で聞く）
2. エントリディレクトリを作成:
   ```bash
   mkdir -p {journal-root}/entries/{YYYY-MM-DD}_{slug}/screenshots
   ```
3. 同一スポットの既存エントリがあれば追記モード（既存 `index.html` を Read → 該当箇所をマージ）

#### 9b. スクリーンショットの配置

撮影済み画像を `screenshots/` に移動:
```bash
mv ./poker-assets/*.jpg {entry-dir}/screenshots/
```

ファイル名規則:
- 集合分析: `{street}-aggregate-{oop|ip}.jpg`
- 個別ボード Strategy+EV: `{street}-{board}-{action}-strategy-ev.jpg`
- 個別ボード Equity: `{street}-{board}-{action}-equity.jpg`

#### 9c. HTML 生成

[references/journal-template.html](references/journal-template.html) に従い `{entry-dir}/index.html` を Write で出力する。

**必須セクション（すべての journal で生成する）:**
- `<section id="hand-review">` Hand Review（数学的分析）
- `<section id="study">` Spot Study（集合分析と個別分析）
- `<section id="exploit">` Exploit Considerations
- `<section id="takeaways">` Key Takeaways & Next Steps
- `<section id="references">` References

**スクリーンショット参照:**
- `<img src="screenshots/{name}.jpg">` で相対パス参照（GitHub Pages で直接表示可能）
- 各個別ボードについて Strategy+EV と Equity Charts の**両方**を必ず掲載
- 各ストリートの集合分析（OOP / IP）を必ず掲載

##### Action Summary フォーマット規約

`<section id="hand-review">` 内の `<pre class="action-summary">` に以下の規約で記載する。

```
Preflop (Effective stack: {bb}bb)
{opener_pos} (Hero) open raises {size}bb
{caller_pos} calls

Flop {flop_cards} (pot {pot}bb)
{pos} bets {bb}bb ({pct}% pot)
{pos} calls

Turn {turn_card} (pot {pot}bb)
{pos} checks
{pos} checks

River {river_card} (pot {pot}bb)
{pos} bets {bb}bb ({pct}% pot)
{pos} calls

{winner_pos} win with {hand}
{loser_pos} defeat with {hand}
```

**規約:**

1. **1アクション1行。** 複数アクションを矢印（`→`）や `&rarr;` で繋げてはならない。
2. **使用する動詞は限定:**
   - `calls` / `raises` / `bets` / `folds` / `checks` / `open raises`（プリフロップの最初のレイズ）
3. **bets / raises にはサイジングを必ず併記:**
   - 形式: `bets {X}bb ({Y}% pot)` もしくは `raises to {X}bb ({Y}% pot)`
   - BB数 と ポット比率 の両方を明記する
   - `%` はベット直前のポットに対するベット額の割合（`bet / pot_before_bet × 100`）
4. **Preflop 行に Effective stack を必ず表記:**
   - 形式: `Preflop (Effective stack: {X}bb)`
5. **各ポストフロップストリートの見出し行にカードと開始時ポットを記載:**
   - 形式: `Flop {cards} (pot {X}bb)` / `Turn {card} (pot {X}bb)` / `River {card} (pot {X}bb)`
   - `pot` はそのストリート開始時（まだベットが入る前）のサイズ
   - カードは `Ts7h2d` もしくはスペース区切り `Ts 7h 2d`。Unicode suit（`♠ ♥ ♦ ♣`）を使ってもよい
6. **Hero のポジションには `(Hero)` を併記:**
   - 例: `UTG (Hero) open raises 2bb`
7. **ショーダウン行:**
   - 勝者: `{winner_pos} win with {hand}`
   - 敗者: `{loser_pos} defeat with {hand}`
   - フォールドで終局した場合は勝敗行を省略（最終アクションの `folds` で終わる）
8. **空行でストリート間を区切る。**

#### 9d. meta.json 生成

エントリディレクトリに `meta.json` を Write で出力する。
フォーマットは [references/journal-structure.md](references/journal-structure.md#metajson) 参照。

`mode` フィールドは常に `["review", "study"]` とする。
`review` と `study` の両フィールドを必ず埋める。

### Step 10: PDF変換（オプション）

ユーザが PDF 出力を希望した場合のみ実行する。

**PDF用の前処理:**
スクリーンショットを base64 インラインに変換した一時ファイルを作成する:

```bash
python3 -c "
import base64, sys, glob, os
html = open(sys.argv[1]).read()
for img in glob.glob(os.path.join(os.path.dirname(sys.argv[1]), 'screenshots', '*.jpg')):
    name = os.path.basename(img)
    b64 = base64.b64encode(open(img, 'rb').read()).decode()
    html = html.replace(f'src=\"screenshots/{name}\"', f'src=\"data:image/jpeg;base64,{b64}\"')
open('/tmp/poker-journal-print.html', 'w').write(html)
" {entry-dir}/index.html
```

**PDF生成:**
```bash
'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --headless --disable-gpu --no-sandbox \
  --print-to-pdf=./{YYYY-MM-DD}_{slug}.pdf \
  --print-to-pdf-no-header \
  /tmp/poker-journal-print.html
```

### Step 11: フォローアップ

1. ユーザに質問や追加分析の希望がないか確認する
2. 特定のストリートの深掘りや、異なるラインのシミュレーションを提案する
3. 類似スポットの学習リソース（GTO Wizard ブログ記事）を提案する
4. **今後の座学テーマ**をまとめて提示する
5. 類似スポットでの検証（他ポジション関係、他スタック深度）を提案する
6. **ウィザトレ（Wizard Training）** での復習を提案する:
   - GTO Wizard の Training > Custom でスポットを設定
   - 座学で学んだ内容を仮説として持ちながらプレイ
   - プレイ後に仮説を検証

#### 過去エントリの活用提案

`meta.json` の `tags` で類似の過去エントリを検索し、関連するエントリがあれば提示する。
過去の `future_topics` に今回のスポットが含まれていれば言及する。

## 思考フレームワーク（各ストリート共通）

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
| [references/cdp-data-acquisition.md](references/cdp-data-acquisition.md) | **PRIMARY** CDP Fetch インターセプトによるデータ取得 |
| [references/poker-math.md](references/poker-math.md) | ポーカー数学リファレンス |
| [references/exploit-guide.md](references/exploit-guide.md) | Exploit戦略ガイド |
| [references/journal-template.html](references/journal-template.html) | HTML テンプレート（review + study 統合） |
| [references/journal-structure.md](references/journal-structure.md) | ジャーナル出力構成・パス設計・meta.json スキーマ |
