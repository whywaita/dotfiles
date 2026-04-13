# Journal Output Structure

ポーカー日誌の出力先ディレクトリ構成。GitHub Pages での公開とAIエージェントによる過去エントリ参照を前提に設計。

## ディレクトリ構成

```
{journal-root}/
├── index.html                          # エントリ一覧
├── assets/
│   └── style.css                       # 共通CSS（テンプレートからの抽出）
└── entries/
    └── {YYYY-MM-DD}_{slug}/
        ├── index.html                  # レンダリング済みページ（review + study 統合）
        ├── meta.json                   # 構造化メタデータ
        └── screenshots/               # スクリーンショット（JPG）
```

`{journal-root}` はユーザに確認する。未指定なら `AskUserQuestion` で聞く。

## パス命名規則

### エントリディレクトリ: `{YYYY-MM-DD}_{slug}`

slug の構成要素（該当するもののみ `_` で連結）:

1. [review] ヒーローハンド: `AKo`, `9d9c`
2. ポジション関係: `CO-vs-BTN`, `SB-vs-BB`
3. ポットタイプ: `SRP`, `3bp`, `4bp`
4. スタック深度: `100bb`, `30bb`
5. [study] ボードテクスチャ補足: `Ahi`, `low`, `monotone`

例:
```
entries/2026-04-13_AKo_CO-vs-BTN_3bp_100bb/       # review
entries/2026-04-13_SB-vs-BTN_3bp_Ahi/              # study
entries/2026-04-13_AKo_CO-vs-BTN_3bp_100bb/        # review → study 追記（同一エントリ）
```

### スクリーンショットファイル名

`{street}-{content}.jpg` 形式:

```
screenshots/
├── preflop-grid.jpg
├── preflop-aggregate.jpg
├── flop-AJ5r-oop.jpg
├── flop-AJ5r-ip-defense.jpg
├── turn-aggregate-nodeA.jpg
└── aggregate-overview.jpg
```

## meta.json

各エントリに配置する構造化メタデータ。AIエージェントが過去エントリを検索・参照する際のインデックスとして機能する。

### スキーマ

```json
{
  "version": 1,
  "date": "2026-04-13",
  "mode": ["review"],
  "title": "AKo CO vs BTN 3bet pot 100bb",
  "spot": {
    "gametype": "MTT",
    "table_size": "8max",
    "hero_hand": "AKo",
    "hero_position": "CO",
    "villain_position": "BTN",
    "pot_type": "3bp",
    "effective_stack_bb": 100,
    "board": {
      "flop": "As Ks 2d",
      "turn": "7h",
      "river": null
    }
  },
  "tags": ["3bet-pot", "Ahi-board", "CO-vs-BTN", "AKo", "MTT"],
  "review": {
    "hero_actions": ["open CO 2.5bb", "call 3bet", "check flop"],
    "assessments": {
      "preflop": "good",
      "flop": "warn",
      "turn": null
    },
    "key_finding": "Flop check frequency with AKo is 65% in solver"
  },
  "study": null,
  "references": {
    "gtowizard_urls": [
      "https://app.gtowizard.com/solutions?gametype=MTTGeneral_8m&..."
    ],
    "blog_articles": [
      { "title": "3-Bet Pot Strategy", "url": "https://blog.gtowizard.com/..." }
    ]
  }
}
```

### study フィールド（study モード実行時）

```json
{
  "study": {
    "board_categories": [
      { "name": "AThi以上", "feature": "bet頻度高、small CB中心", "representative_board": "AJ5r" }
    ],
    "key_insights": [
      "AJ5r では OOP がレンジ全体の70%をスモールCBする"
    ],
    "id_spots": [
      "A9o はフロップCB対してcall/foldのID帯"
    ],
    "future_topics": [
      "同じ3bpでBB vs CO でも同じ傾向が見られるか確認"
    ]
  }
}
```

### フィールド一覧

| Field | Type | Description |
|-------|------|-------------|
| `version` | number | スキーマバージョン（現在: 1） |
| `date` | string | 作成日 `YYYY-MM-DD` |
| `mode` | string[] | 実行モード: `["review"]`, `["study"]`, `["review", "study"]` |
| `title` | string | エントリタイトル（人間可読） |
| `spot` | object | スポット情報（`hero_hand` は review のみ必須） |
| `tags` | string[] | 検索用タグ（ポットタイプ、ボード特徴、ポジション等） |
| `review` | object\|null | review モードの要約 |
| `study` | object\|null | study モードの要約 |
| `references` | object | 使用した外部ソースURL |

### assessments 値

| 値 | 意味 |
|----|------|
| `"good"` | GTO に沿ったプレイ |
| `"warn"` | わずかな逸脱、または状況依存 |
| `"bad"` | 明確なミス |

## 既存エントリへの追記

同一スポットで review → study を連続実行した場合、**同じエントリディレクトリに追記**する:

1. 既存の `index.html` を Read で読み込む
2. 対応する `<section>` を追加する（`#hand-review` or `#study`）
3. `meta.json` の `mode` 配列に追加し、対応フィールドを埋める

## AIエージェント向け: 過去エントリの検索

```bash
# 全エントリのメタデータをスキャン
for f in {journal-root}/entries/*/meta.json; do
  python3 -c "import sys,json; d=json.load(open('$f')); print(f'{d[\"date\"]} {d[\"mode\"]} {d[\"title\"]}')"
done

# タグで検索
grep -rl '"3bet-pot"' {journal-root}/entries/*/meta.json

# ポジション関係で検索
grep -rl '"hero_position": "CO"' {journal-root}/entries/*/meta.json
```

### 活用パターン

- **レビュー時**: 同じポジション関係・ポットタイプの過去エントリを検索し、以前の `key_finding` と比較
- **座学時**: 過去の `future_topics` に今回のスポットが含まれていれば、前回の分析を出発点にする
- **傾向分析**: `assessments` を集計し、ユーザの弱点スポットを特定する
