# tmux-scripts

Claude CodeとTmuxを統合した開発環境自動構築ツール

## 🎯 このツールでできること

- プロジェクトを選択するだけで5ペインのTmux開発環境を自動構築
- 上位2ペインでClaude Codeが自動起動
- 不要なTmuxセッションを選択して削除

## 📋 前提条件と準備

### 必須ソフトウェア
- macOS または Linux
- Tmux (インストール: `brew install tmux` または `apt install tmux`)
- Claude Code CLI (`claude`コマンド)
- Bash または Zsh

### 必要なフォルダ構成
```
~/
├── Products/               # プロジェクトフォルダ（必須）
│   ├── my-project-1/       # 各プロジェクト
│   ├── my-project-2/
│   └── ...
└── .zshrc または .bashrc   # シェル設定ファイル
```

**重要**: `~/Products`フォルダがない場合は作成してください：
```bash
mkdir -p ~/Products
```

## 🚀 クイックスタート（5分で完了）

### Step 1: インストール
```bash
# 1. リポジトリをクローン
git clone https://github.com/1139-Yu-Ki-8963/tmux-scripts.git
cd tmux-scripts

# 2. 実行権限を付与
chmod +x *.sh
```

### Step 2: Claude Code設定（必須）
```bash
# Claude Codeのエイリアスを自動設定
./setup-alias.sh

# 設定を反映
source ~/.zshrc   # Zshの場合
source ~/.bashrc  # Bashの場合

# 動作確認
which cc  # 出力例: cc: aliased to claude --dangerously-skip-permissions
```

### Step 3: 使ってみる
```bash
# プロジェクトランチャーを起動
./tmux-project-launcher.sh

# 以下の流れで動作：
# 1. ~/Products内のプロジェクト一覧が表示される
# 2. 番号を選択してEnter
# 3. 5ペインのTmuxセッションが起動
# 4. 上位2ペインでClaude Codeが自動起動
```

## 📁 各スクリプトの詳細

### 1. setup-alias.sh（最初に実行）
Claude Codeエイリアス（`cc`コマンド）を自動設定するセットアップスクリプトです。

**機能:**
- zsh/bash環境の自動検出
- シェル設定ファイル（`~/.zshrc`/`~/.bashrc`）への自動追加
- 既存設定の重複チェック
- 設定ファイルの自動バックアップ作成
- 設定反映と動作確認手順の表示

**使用方法:**
```bash
# エイリアス設定を実行
./setup-alias.sh

# 設定を反映（どちらか適切な方を選択）
source ~/.zshrc   # zshの場合
source ~/.bashrc  # bashの場合
```

**設定されるエイリアス:**
```bash
alias cc='claude --dangerously-skip-permissions'
```

### 2. tmux-project-launcher.sh
プロジェクトディレクトリを選択してTmuxセッションを起動するランチャーです。

**機能:**
- `~/Products`ディレクトリ内のプロジェクトを一覧表示
- 選択したプロジェクトでTmuxセッションを作成
- 5ペイン構成での開発環境を自動セットアップ
- 上位2ペインでClaude Code自動起動

**ペイン構成:**
```
┌─────────────────────────────┐
│     PRESIDENT (cc起動)       │ 30%
├─────────────────────────────┤
│     worker1 (cc起動)         │ 30%
├─────────┬─────────┬─────────┤
│ worker2 │ worker3 │ worker4 │ 40%
└─────────┴─────────┴─────────┘
```

**使用方法:**
```bash
./tmux-project-launcher.sh
```

### 3. tmux-kill-select.sh
実行中のTmuxセッションを選択して削除するツールです。

**機能:**
- 実行中のTmuxセッション一覧を表示
- セッションを選択して安全に削除
- 複数セッション管理の効率化

**使用方法:**
```bash
./tmux-kill-select.sh
```

## 🔧 トラブルシューティング

### Q: "Projects フォルダが見つかりません"と表示される
```bash
# ~/Productsフォルダを作成
mkdir -p ~/Products
# プロジェクトを追加
cd ~/Products
git clone your-project-repo
```

### Q: "cc: command not found"と表示される
```bash
# setup-alias.shを再実行
./setup-alias.sh
source ~/.zshrc  # または ~/.bashrc
```

### Q: Claude Codeがインストールされていない
1. https://claude.ai/code からダウンロード
2. インストール後、ターミナルで`claude`コマンドが使えることを確認

### Q: Tmuxがインストールされていない
```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux

# 確認
tmux -V
```

### Q: セッションが既に存在すると言われる
```bash
# 既存セッションに接続されます（正常な動作）
# 削除したい場合は tmux-kill-select.sh を実行
./tmux-kill-select.sh
```

## 🎨 カスタマイズ

### プロジェクトフォルダを変更したい場合
`tmux-project-launcher.sh`の15行目を編集：
```bash
PROJECTS_DIR="$HOME/Products"  # ここを変更
```

### Claude Codeの起動コマンドを変更したい場合
```bash
export CLAUDE_CMD="claude"  # ccではなくclaudeを使用
./tmux-project-launcher.sh
```

### パスを通して便利に使う
```bash
# シンボリックリンクを作成
ln -s $(pwd)/tmux-project-launcher.sh ~/.local/bin/tmux-launch
ln -s $(pwd)/tmux-kill-select.sh ~/.local/bin/tmux-kill

# ~/.local/binがPATHに含まれていることを確認
echo $PATH | grep "$HOME/.local/bin"

# どこからでも実行可能に
tmux-launch
tmux-kill
```

## 📝 推奨される日常の使い方

### 1. 朝の作業開始時
```bash
cd ~/tmux-scripts
./tmux-project-launcher.sh
# プロジェクトを選択
```

### 2. 作業終了時
```bash
# 不要なセッション削除
./tmux-kill-select.sh
# 削除したいセッションを選択
```

### 3. 複数プロジェクトの並行作業
```bash
# プロジェクトA用のセッション
./tmux-project-launcher.sh
# プロジェクトB用のセッション
./tmux-project-launcher.sh

# セッション間の移動
tmux list-sessions    # セッション一覧
tmux attach -t session-name  # 特定セッションにアタッチ
```

## ⚠️ 注意事項

- tmux-project-launcher.shは`~/Products`フォルダ内のプロジェクトのみ対象
- Claude Codeは上位2ペイン（PRESIDENT、worker1）で自動起動
- 既存のTmuxセッションがある場合は自動的にアタッチされます
- セッション名は選択したプロジェクトのフォルダ名になります

## 🚀 さらなる活用

### Tmuxキーバインド（参考）
- `Ctrl-b + d`: セッションをデタッチ（バックグラウンド実行）
- `Ctrl-b + c`: 新しいウィンドウを作成
- `Ctrl-b + n`: 次のウィンドウ
- `Ctrl-b + p`: 前のウィンドウ
- `Ctrl-b + 矢印キー`: ペイン間の移動

### 自動起動の設定
```bash
# .zshrcまたは.bashrcに追加
alias start-dev='cd ~/tmux-scripts && ./tmux-project-launcher.sh'
```

## 📄 ライセンス

MIT License