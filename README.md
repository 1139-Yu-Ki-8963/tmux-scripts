# tmux-scripts

ワンクリックで5ペインのTmux環境とClaude Code起動を同時実行し、複数プロジェクト管理を効率化するスクリプトファイルです。

## このツールでできること

- プロジェクトを選択するだけで5ペインのTmux開発環境を自動構築
- 上位2ペインでClaude Codeが自動起動
- 不要なTmuxセッションを選択して削除

ペイン構成:
```
┌─────────────────────────────┐
│     PRESIDENT (ccs起動)      │ 30%
├─────────────────────────────┤
│     worker1 (ccs起動)        │ 30%
├─────────┬─────────┬─────────┤
│ worker2 │ worker3 │ worker4 │ 40%
└─────────┴─────────┴─────────┘
```

## 前提条件と準備

### 必須ソフトウェア
- macOS または Linux
- Tmux (インストール: `brew install tmux` または `apt install tmux`)
- Claude Code CLI (`claude`コマンド)
- Bash または Zsh

### 必要なフォルダ構成
```
~/
├── Projects/               # プロジェクトフォルダ（必須）
│   ├── my-project-1/       # 各プロジェクト
│   ├── my-project-2/
│   └── ...
└── .zshrc または .bashrc   # シェル設定ファイル
```

**重要**: `~/Projects`フォルダがない場合は作成してください：
```bash
mkdir -p ~/Projects
```

## クイックスタート

### Step 1: インストール
```bash
# 1. リポジトリをクローン
git clone https://github.com/1139-Yu-Ki-8963/tmux-scripts.git
cd tmux-scripts

# 2. 実行権限を付与
chmod +x *.sh
```

### Step 2: 前提条件確認
以下はすべてターミナルで実行してください：

```bash
# 必須ソフトウェアが正しくインストールされているか確認
claude --version  # Claude Code確認
tmux -V          # Tmux確認
```

### Step 3: Claude Code設定（セキュリティ）
```bash
# Claude Code設定のpermissions部分を追加
# 既存の~/.claude/settings.jsonのpermissionsセクションに
# このリポジトリのsettings.jsonのpermissions内容をコピーして追加
```

### Step 4: エイリアス設定
```bash
# 1. Claude Codeのエイリアスを自動設定
./setup-alias.sh

# 2. 設定を反映
source ~/.zshrc   # Zshの場合
source ~/.bashrc  # Bashの場合

# 3. 動作確認
which cc   # 出力例: cc: aliased to claude
which ccs  # 出力例: ccs: aliased to claude --dangerously-skip-permissions
```

**エイリアス説明:**
- `cc`: 通常版（許可確認あり） - 手動実行用
- `ccs`: スキップ版（許可スキップ） - 自動化・tmux用

### Step 5: 使ってみる
```bash
# プロジェクトランチャーを起動
./tmux-project-launcher.sh

# セッション削除（必要時）
./tmux-kill-select.sh

# 以下の流れで動作：
# 1. ~/Projects内のプロジェクト一覧が表示される
# 2. 番号を選択してEnter
# 3. 5ペインのTmuxセッションが起動
# 4. 上位2ペインでClaude Code（ccs版）が自動起動
```

## 便利な操作

- Ctrl+b → z でペインを全画面表示/元に戻すことができます

## 注意事項

- tmux-project-launcher.shは`~/Projects`フォルダ内のプロジェクトのみ対象
- Claude Code（ccs版）は上位2ペイン（PRESIDENT、worker1）で自動起動
- 既存のTmuxセッションがある場合は自動的にアタッチされます
- セッション名は選択したプロジェクトのフォルダ名になります

## 詳細な使い方・トラブルシューティング

詳細な使い方、カスタマイズ方法、トラブルシューティングについては `docs.md` を参照してください。

## ライセンス

MIT License