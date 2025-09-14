#!/bin/bash

# tmuxプロジェクトランチャー
# ~/Projectsフォルダのプロジェクトを選択してTmuxセッションを起動

set -e

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Projectsフォルダのパス
PROJECTS_DIR="$HOME/Products"

echo "================================================"
echo "       tmuxプロジェクトランチャー"
echo "================================================"
echo ""

# Projectsフォルダが存在するかチェック
if [ ! -d "$PROJECTS_DIR" ]; then
    echo -e "${RED}Error: Projects フォルダが見つかりません: $PROJECTS_DIR${NC}"
    exit 1
fi

# 5ペイン作成関数
create_5pane() {
    local session=$1
    local directory=$2
    
    echo -e "${GREEN}Creating 5-pane layout for $session...${NC}"
    
    # セッションが既に存在する場合はスキップ
    if tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${YELLOW}Session $session already exists, attaching...${NC}"
        tmux attach -t "$session"
        return
    fi
    
    # 新規セッション作成（バックグラウンド）
    tmux new-session -d -s "$session" -c "$directory"
    
    # 5ペイン構成作成（3段構成: 30%-30%-40%）
    # 1. 上下分割: PRESIDENT(30%) | 残り(70%)
    tmux split-window -v -p 70 -t "$session:0"
    
    # 2. 残りを上下分割: worker1(43%) | 下段workers(57%)
    tmux split-window -v -p 57 -t "$session:0.1"
    
    # 3. 下段を3分割: worker2 | worker3 | worker4
    tmux split-window -h -p 67 -t "$session:0.2"  # 2/3を残す
    tmux split-window -h -p 50 -t "$session:0.3"  # 残りを半分に
    
    # 境界線スタイル設定
    tmux set-option -t "$session" pane-border-style fg=colour245
    tmux set-option -t "$session" pane-active-border-style fg=green,bold
    tmux set-option -t "$session" pane-border-lines heavy
    
    # 各ペインで作業ディレクトリを設定
    for i in {0..4}; do
        tmux send-keys -t "$session:0.$i" "cd $directory" C-m
        tmux send-keys -t "$session:0.$i" "clear" C-m
    done
    
    # 最上段ペイン（PRESIDENT）でClaude Code起動
    echo -e "${YELLOW}Starting Claude Code in PRESIDENT pane...${NC}"
    tmux send-keys -t "$session:0.0" "cc" C-m
    
    # 2段目ペイン（worker1）でもClaude Code起動
    echo -e "${YELLOW}Starting Claude Code in worker1 pane...${NC}"
    tmux send-keys -t "$session:0.1" "cc" C-m
    
    echo -e "${GREEN}✓ Session $session created with 5 panes${NC}"
    
    # セッションにアタッチ
    tmux attach -t "$session"
}

# tmuxサーバーが起動していることを確認
if ! tmux info &> /dev/null; then
    echo -e "${YELLOW}Starting tmux server...${NC}"
    tmux start-server
fi

# プロジェクト一覧を動的に取得
echo -e "${GREEN}プロジェクト一覧を取得中...${NC}"

# ~/Projects フォルダのディレクトリのみを取得（隠しディレクトリ除外）
projects=()
while IFS= read -r -d '' dir; do
    basename_dir=$(basename "$dir")
    # 隠しディレクトリを除外
    if [[ ! "$basename_dir" =~ ^\. ]]; then
        projects+=("$basename_dir")
    fi
done < <(find "$PROJECTS_DIR" -maxdepth 1 -type d ! -path "$PROJECTS_DIR" -print0 2>/dev/null)

# プロジェクトが見つからない場合
if [ ${#projects[@]} -eq 0 ]; then
    echo -e "${RED}Error: Projects フォルダにプロジェクトが見つかりません${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}プロジェクトを選択してください:${NC}"
echo ""

# 番号付きでプロジェクト一覧を表示
for i in "${!projects[@]}"; do
    echo "$((i+1))) ${projects[$i]}"
done

echo ""
echo -n "番号を入力してください (1-${#projects[@]}): "

# 番号入力を受け取る
read -r choice

# 入力値検証
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#projects[@]} ]; then
    echo -e "${RED}Error: 無効な番号です。1-${#projects[@]} の範囲で入力してください${NC}"
    exit 1
fi

# 選択されたプロジェクト
selected_project="${projects[$((choice-1))]}"
project_path="$PROJECTS_DIR/$selected_project"

echo ""
echo -e "${GREEN}選択されたプロジェクト: $selected_project${NC}"
echo -e "${GREEN}パス: $project_path${NC}"
echo ""

# セッション作成と起動
create_5pane "$selected_project" "$project_path"