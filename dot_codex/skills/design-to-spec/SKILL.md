---
name: design-to-spec
description: |
  設計ドキュメント（Design Doc）を実装可能な仕様書（Spec）に変換するスキル。
  「なぜ作るか」を「何を作るか」に変換し、実装者・QA・保守者が参照できる明確な仕様を生成する。
  「スペックにまとめて」「仕様書にして」「実装仕様を書いて」「specに変換して」でトリガーすること。
  dig で曖昧さを解消してから使用すると最も効果的。
argument-hint: <design-doc-path> [decisions-path] [output-path]
---

# design-to-spec

Design Doc を実装可能な Spec に変換する。
「なぜ作るか」を「何を作るか」に変換し、実装者・QA・保守者が参照できる明確な仕様を生成する。

## 引数

- 第1引数（必須）: 設計ドキュメントのパス（例: `docs/design.md`）
- 第2引数（任意）: Decisions ファイルのパス（dig の出力）。省略時は `<doc-basename>-decisions.md` を自動検出
- 第3引数（任意）: 出力先パス。省略時は `<doc-basename>-spec.md`

## Workflow

### Step 1: 入力読み込み

1. 指定されたパスの Design Doc を読み込む
2. Decisions ファイルの検出:
   - 第2引数が指定されていればそのパスを読み込む
   - 省略時は `<doc-basename>-decisions.md` を検索し、存在すれば読み込む
   - Decisions ファイルがない場合はその旨を伝え、dig の利用を提案する（必須ではない）
3. ユーザーの使用言語を判定し、以降のやり取りはその言語で行う

### Step 2: Gap 分析

Spec に必要だが Design Doc（+ Decisions）に欠けている情報を特定する。

**分類:**

- **Blocking**: この情報がないと Spec が書けない（例: 認証方式が未定義）
- **Non-blocking**: Open Questions として記載できる（例: 将来の拡張計画）

**対応:**

- Blocking な項目のみ AskUserQuestion で質問する
  - 各選択肢に pros/cons を付記する
  - 「未定」も受容し、Open Questions に記録する
- Non-blocking な項目は Open Questions セクションに記載する

### Step 3: Spec 生成

以下の構造で仕様書を生成する。ドキュメントの内容に応じて不要なセクションは省略してよい。

```markdown
# Spec: <タイトル>

## Overview
<!-- 1-2段落で何を作るかを説明 -->

## Scope
<!-- In Scope / Out of Scope を明確に -->

### In Scope
- ...

### Out of Scope
- ...

## Terminology
<!-- プロジェクト固有の用語定義 -->

| 用語 | 定義 |
|------|------|
| ...  | ...  |

## Functional Requirements

### FR-1: <機能名>
- **説明**: ...
- **成功時**: ...
- **失敗時**: ...

## Non-Functional Requirements

### NFR-1: <要件名>
- **説明**: ...
- **基準**: ...

## API / Interface
<!-- エンドポイント、メソッド、入出力の定義 -->

## Data Model
<!-- エンティティ、リレーション、スキーマ -->

## State Transitions
<!-- 状態遷移図や状態の説明 -->

## Security
<!-- 認証・認可・データ保護 -->

## Decision Records
<!-- ADR 形式で設計判断を記録 -->

### DR-1: <決定事項>
- **Status**: Accepted
- **Context**: ...
- **Decision**: ...
- **Consequences**: ...

## Open Questions
- [ ] ...

## References
- [Design Doc](<元ドキュメントへのパス>)
- [Decisions](<decisions ファイルへのパス>)
```

**言語ルール:**

- 断定形で記述する（「〜とする」「〜である」）
- 曖昧な表現は禁止（Open Questions 以外）
  - 禁止例: 「〜を検討する」「必要に応じて〜」「〜など」
  - 許容例: 「〜とする」「〜を使用する」「〜は行わない」
- 各 Functional Requirement には成功時と失敗時の両方を定義する

### Step 4: 出力

1. デフォルト出力先: `<doc-basename>-spec.md`（第3引数で上書き可能）
2. **元のドキュメントは絶対に上書きしない**
3. 書き込み前に出力先をユーザーに確認する

### Step 5: レビュー

1. サマリーを簡潔に伝える:
   - 抽出した Functional Requirements の数
   - Non-Functional Requirements の数
   - Decision Records の数
   - Open Questions の数
2. Open Questions が多い場合は dig の利用を提案する
3. 修正要望があれば対応する
