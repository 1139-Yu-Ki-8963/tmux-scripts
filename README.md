# tmux-scripts

Tmuxプロジェクト管理とセッション制御用スクリプト集

## 概要

プロジェクトディレクトリの選択・起動とTmuxセッション管理を効率化する2つのBashスクリプトです。

## スクリプト一覧

### 1. tmux-project-launcher.sh
プロジェクトディレクトリを選択してTmuxセッションを起動するランチャーです。

**機能:**
- `~/Products`ディレクトリ内のプロジェクトを一覧表示
- 選択したプロジェクトでTmuxセッションを作成
- 5ペイン構成での開発環境を自動セットアップ

**使用方法:**
```bash
./tmux-project-launcher.sh
```

### 2. tmux-kill-select.sh
実行中のTmuxセッションを選択して削除するツールです。

**機能:**
- 実行中のTmuxセッション一覧を表示
- セッションを選択して安全に削除
- 複数セッション管理の効率化

**使用方法:**
```bash
./tmux-kill-select.sh
```

## インストール

```bash
# リポジトリをクローン
git clone https://github.com/1139-Yu-Ki-8963/tmux-scripts.git
cd tmux-scripts

# 実行権限を付与
chmod +x *.sh

# パスの通った場所にシンボリックリンクを作成（オプション）
ln -s $(pwd)/tmux-project-launcher.sh ~/.local/bin/tmux-launch
ln -s $(pwd)/tmux-kill-select.sh ~/.local/bin/tmux-kill
```

## 必要な環境

- Bash
- Tmux
- Claude Code (`claude`コマンド)
- `~/Products`ディレクトリ（tmux-project-launcher.sh用）

### Claude Code設定（必須）

tmux-project-launcher.shは上位2ペインでClaude Codeを自動起動します。
デフォルトでは`cc`コマンドを使用します。

#### 初回セットアップ

```bash
# エイリアス設定スクリプトを実行
./setup-alias.sh

# 設定を反映
source ~/.zshrc  # または source ~/.bashrc
```

#### 手動設定の場合

```bash
# ~/.zshrc または ~/.bashrcに追加
alias cc='claude --dangerously-skip-permissions'
```

#### カスタムコマンドを使用する場合

```bash
# 環境変数でコマンドを指定
export CLAUDE_CMD="claude"
./tmux-project-launcher.sh
```

#### 動作確認

```bash
# エイリアス確認
which cc

# Claude Code起動テスト
cc --version
```

## ライセンス

MIT License