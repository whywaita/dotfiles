---
name: create-design-docs
description: ソフトウェア実装前の設計議論用ドキュメントを生成する。新機能の設計、アーキテクチャ設計、システム設計の文書化に使用。
argument-hint: [feature-name or topic]
---

# Design Document Generator

ソフトウェア実装前に設計を議論するためのドキュメント（Design Doc）を生成するスキル。
既存コードは存在しない前提で、ユーザーへのヒアリングを通じて設計書を作成する。

## Workflow

### Step 1: 言語選択

AskUserQuestion を使用して出力言語を確認:
- 日本語
- English

### Step 2: 出力先の確認

1. `docs/design.md` が存在するか確認
2. 存在する場合は AskUserQuestion で上書き確認
3. 存在しない場合は `docs/` ディレクトリを作成

### Step 3: 基本情報のヒアリング

AskUserQuestion で以下を確認:
- プロジェクト/機能名
- 概要（1-2文での説明）
- 対象読者（開発者/運用者/ステークホルダー）

### Step 4: 背景・動機のヒアリング（Motivation）

AskUserQuestion で以下を確認:
- 解決したい課題
- なぜ今必要なのか
- 既存の代替手段との比較（あれば）

曖昧な回答には具体例を示して再質問。

### Step 5: Goals / Non-Goals のヒアリング

AskUserQuestion で以下を確認:
- Goals: 達成したい目標（具体的・測定可能）
- Non-Goals: スコープ外とする項目

### Step 6: 設計詳細のヒアリング

AskUserQuestion で含めたい要素を選択式で確認（複数可）:
- アーキテクチャ概要図
- ユーザーの利用フロー
- シーケンス図
- API設計
- データモデル/スキーマ
- セキュリティ考慮事項
- その他

選択された要素ごとに詳細をヒアリング。

### Step 7: ドキュメント生成

以下の構造で `docs/design.md` を生成:
- Overview
- Motivation
- Goals / Non-Goals
- Design Details（mermaid図、表を含む）
- API Design（該当する場合）
- Data Flow / Sequence（該当する場合）
- Security Considerations（該当する場合）
- Open Questions
- References

### Step 8: レビュー・修正

生成したドキュメントをユーザーに提示し、修正要望を確認。

## Notes

- mermaid 図は GitHub/GitLab で直接レンダリング可能な形式を使用
- 既存コードがない前提のため、ヒアリングが設計の主な情報源となる
- 長いドキュメントになる場合は目次（TOC）を自動生成

## 曖昧な回答への対処

| 曖昧な回答 | 追加質問例 |
| :--- | :--- |
| 「パフォーマンス改善」 | 「具体的にどの指標を改善しますか？（レイテンシ、スループット等）」 |
| 「使いやすくする」 | 「どのようなユーザーにとって使いにくいですか？」 |
| 「セキュリティ強化」 | 「どのような脅威に対応しますか？」 |
| 「よくわからない」 | 選択式に切り替えて提示 |
