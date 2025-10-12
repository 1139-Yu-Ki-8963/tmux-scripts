# tmux-scripts

ワンクリックで2ウィンドウのTmux環境とClaude Code起動を同時実行し、複数プロジェクト管理を効率化するスクリプトファイルです。

## このツールでできること

- プロジェクトを選択するだけで2ウィンドウのTmux開発環境を自動構築
- 上位2ペインでClaude Codeが自動起動
- 不要なTmuxセッションを選択して削除

ウィンドウ構成:

### window0（5ペイン構成）
```
┌─────────────────────────────┐
│  Claude Code (ccs起動)       │ 30%
├─────────────────────────────┤
│  Claude Code (ccs起動)       │ 30%
├─────────┬─────────┬─────────┤
│ worker2 │ worker3 │ worker4 │ 40%
└─────────┴─────────┴─────────┘
```

### window1（5ペイン構成）
```
┌─────────────────────────────┐
│  Claude Code (ccs起動)       │ 30%
├─────────────────────────────┤
│  Claude Code (ccs起動)       │ 30%
├─────────┬─────────┬─────────┤
│ Docker  │ Server  │   DB    │ 40%
│ 起動用  │ 起動用  │ 起動用  │
└─────────┴─────────┴─────────┘
```

window1の下部3ペインには、左からDocker、サーバー、DBを起動するコマンドが自動送信されます。

## 前提条件と準備

### Step 1: Tmuxのインストール

**macOS:**
```bash
brew install tmux
```

**Linux:**
```bash
apt install tmux
```

**インストール確認:**
```bash
tmux -V
```

### Step 2: Tmux設定ファイルの作成

`~/.tmux.conf`に以下の内容を記述してください：

```bash
# マウス操作を有効にする
set-option -g mouse on


# コピーした内容をMacのクリップボードに送る
set -s copy-command 'pbcopy'
```

**設定の説明:**
- `mouse on`: tmux内でマウス操作が可能になります
- `pbcopy`: コピーした内容をmacOSのクリップボードに送信します

### Step 3: 必要なフォルダ構成

#### 1. スクリプト配置場所
```
~/script/tmux/
├── tmux-project-launcher.sh  # tmux起動スクリプト
└── tmux-kill-select.sh        # 一括終了スクリプト
```

#### 2. プロジェクトコード格納場所
```
~/Projects/                    # プロジェクトのコード（必須）
├── project-a/                 # プロジェクトAのコード
├── project-b/                 # プロジェクトBのコード
└── ...
```

#### 3. プロジェクト設定ファイル格納場所
```
~/AIDD-Knowledge/projects/     # プロジェクト設定（必須）
├── project-a/
│   └── tools/
│       └── tmux/              # プロジェクトA用のtmux設定
├── project-b/
│   └── tools/
│       └── tmux/              # プロジェクトB用のtmux設定
└── ...
```

**フォルダ構成の特徴:**
- **コードと設定の分離**: 実際のコードは`~/Projects/`、設定ファイルは`~/AIDD-Knowledge/`に分離
- **プロジェクト独自設定**: 各プロジェクト専用のtmux設定を`tools/tmux/`に配置可能

**重要**: 以下のフォルダがない場合は作成してください：
```bash
mkdir -p ~/Projects
mkdir -p ~/AIDD-Knowledge/projects
mkdir -p ~/script/tmux
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

#### tmux起動スクリプトの動作フロー

**機能1: プロジェクト一覧表示と選択**
- `~/AIDD-Knowledge/projects/`配下のプロジェクトを一覧表示
- 番号で選択可能
```
利用可能なプロジェクト:
1) project-a
2) project-b
3) project-c
番号を選択してください:
```

**機能2: プロジェクト独自のtmux設定を読み込み**
- 選択したプロジェクトの設定パス: `~/AIDD-Knowledge/projects/[プロジェクト名]/tools/tmux/`
- このディレクトリ内のtmux設定ファイル（.sh、.confなど）を自動的に読み込み
- プロジェクトごとに異なるペイン構成や起動コマンドを設定可能

**機能3: 作業ディレクトリの自動切り替え**
- tmuxセッションの作業ディレクトリは`~/Projects/[プロジェクト名]/`を使用
- 設定は`~/AIDD-Knowledge/`から読み込むが、実際の作業は`~/Projects/`で実行
- **重要**: コードと設定を分離して管理できる仕組み

#### 実行方法
```bash
# プロジェクトランチャーを起動
./tmux-project-launcher.sh

# セッション削除（必要時）
./tmux-kill-select.sh

# 以下の流れで動作：
# 1. ~/AIDD-Knowledge/projects/内のプロジェクト一覧が表示される
# 2. 番号を選択してEnter
# 3. 選択したプロジェクトのtmux設定を読み込み
# 4. 作業ディレクトリを~/Projects/[プロジェクト名]/に設定して2ウィンドウのTmuxセッションが起動
# 5. 上位2ペインでClaude Code（ccs版）が自動起動
```

## 便利な操作

- Ctrl+b → z でペインを全画面表示/元に戻すことができます

## 注意事項

- スクリプトは`~/AIDD-Knowledge/projects/`内のプロジェクトを検索対象とします
- 実際の作業ディレクトリは`~/Projects/[プロジェクト名]/`になります
- プロジェクト設定は`~/AIDD-Knowledge/projects/[プロジェクト名]/tools/tmux/`から読み込まれます
- Claude Code（ccs版）は各ウィンドウの上位2ペインで自動起動
- 既存のTmuxセッションがある場合は自動的にアタッチされます
- セッション名は選択したプロジェクトのフォルダ名になります
