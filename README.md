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
- `~/Products`ディレクトリ（tmux-project-launcher.sh用）

## ライセンス

MIT License