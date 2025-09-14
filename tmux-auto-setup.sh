#!/bin/bash

# tmux自動セットアップスクリプト
# PC起動時にiTerm2の2つのタブでclaude-globalとindexセッションを自動作成

set -e

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# iTerm2タブカラー設定関数
set_tab_color() {
    local r=$1
    local g=$2
    local b=$3
    printf '\033]6;1;bg;red;brightness;%d\a' "$r"
    printf '\033]6;1;bg;green;brightness;%d\a' "$g"
    printf '\033]6;1;bg;blue;brightness;%d\a' "$b"
}

# プリセットカラー
set_claude_global_color() {
    set_tab_color 100 149 237  # CornflowerBlue - 青系
}

set_index_color() {
    set_tab_color 60 179 113   # MediumSeaGreen - 緑系
}

reset_tab_color() {
    printf '\033]6;1;bg;*;default\a'
}

echo "================================================"
echo "     tmux自動セットアップ - 2セッション起動"
echo "================================================"
echo ""

# 5ペイン作成関数
create_5pane() {
    local session=$1
    local directory=$2
    
    echo -e "${GREEN}Creating 5-pane layout for $session...${NC}"
    
    # セッションが既に存在する場合はスキップ
    if tmux has-session -t "$session" 2>/dev/null; then
        echo -e "${YELLOW}Session $session already exists, skipping...${NC}"
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
    
    # claude-globalセッションの場合のみ2つ目のウィンドウを作成
    if [ "$session" = "claude-global" ]; then
        echo -e "${YELLOW}Creating second window for claude-global session...${NC}"
        
        # 2つ目のウィンドウ作成
        tmux new-window -t "$session:1" -c "$directory" -n "Window-2"
        
        # 2つ目のウィンドウでも同じ5ペイン構成作成
        # 1. 上下分割: PRESIDENT(30%) | 残り(70%)
        tmux split-window -v -p 70 -t "$session:1"
        
        # 2. 残りを上下分割: worker1(43%) | 下段workers(57%)
        tmux split-window -v -p 57 -t "$session:1.1"
        
        # 3. 下段を3分割: worker2 | worker3 | worker4
        tmux split-window -h -p 67 -t "$session:1.2"  # 2/3を残す
        tmux split-window -h -p 50 -t "$session:1.3"  # 残りを半分に
        
        # 各ペインで作業ディレクトリを設定
        for i in {0..4}; do
            tmux send-keys -t "$session:1.$i" "cd $directory" C-m
            tmux send-keys -t "$session:1.$i" "clear" C-m
        done
        
        # 2つ目のウィンドウのPRESIDENTペインでClaude Code起動
        echo -e "${YELLOW}Starting Claude Code in Window-2 PRESIDENT pane...${NC}"
        tmux send-keys -t "$session:1.0" "cc" C-m
        
        # 2つ目のウィンドウのworker1ペインでもClaude Code起動
        echo -e "${YELLOW}Starting Claude Code in Window-2 worker1 pane...${NC}"
        tmux send-keys -t "$session:1.1" "cc" C-m
        
        # 1つ目のウィンドウに名前を設定
        tmux rename-window -t "$session:0" "Window-1"
        
        # 1つ目のウィンドウを選択（アタッチ時にWindow-1が表示されるようにする）
        tmux select-window -t "$session:0"
        
        echo -e "${GREEN}✓ Session $session created with 2 windows (10 panes total)${NC}"
    else
        echo -e "${GREEN}✓ Session $session created with 5 panes${NC}"
    fi
}

# tmuxサーバーが起動していることを確認
if ! tmux info &> /dev/null; then
    echo -e "${YELLOW}Starting tmux server...${NC}"
    tmux start-server
fi

# セッション作成（バックグラウンド）
echo -e "${GREEN}Preparing sessions...${NC}"
create_5pane "claude-global" "$HOME/.claude"
create_5pane "index" "$HOME/Obsidian/index"

echo ""
echo -e "${GREEN}Opening iTerm2 tabs...${NC}"

# AppleScriptでiTerm2の2つのタブを開く
osascript <<EOF
tell application "iTerm2"
    tell current window
        -- Tab 1: claude-global（青色）
        tell current session
            write text "tmux attach -t claude-global"
        end tell
        -- タブタイトル設定のみ（iTerm2レベル）
        tell current tab
            set current session's name to "Claude Global"
        end tell
        
        -- Tab 2: index (新規タブ作成)（緑色）
        create tab with default profile
        tell current session
            write text "tmux attach -t index"
        end tell
        -- タブタイトル設定のみ（iTerm2レベル）
        tell current tab
            set current session's name to "Index Project"
        end tell
        
        -- Tab 1に戻る
        tell first tab to select
    end tell
end tell
EOF

echo ""
echo "================================================"
echo -e "${GREEN}✓ セットアップ完了！${NC}"
echo "================================================"
echo ""
echo "起動されたセッション:"
echo -e "  Tab 1: ${GREEN}claude-global${NC} (~/.claude) - ${YELLOW}青色タブ${NC} - ${GREEN}2ウィンドウ × 5ペイン = 10ペイン${NC}"
echo -e "  Tab 2: ${GREEN}index${NC} (~/Obsidian/index) - ${YELLOW}緑色タブ${NC} - ${GREEN}1ウィンドウ × 5ペイン = 5ペイン${NC}"
echo ""
echo "claude-globalセッション構成:"
echo -e "  - ${YELLOW}Window-1${NC}: PRESIDENT + worker1でClaude Code起動済み"
echo -e "  - ${YELLOW}Window-2${NC}: PRESIDENT + worker1でClaude Code起動済み"
echo -e "  - 計10ペインが利用可能"
echo ""
echo "操作方法:"
echo "  Ctrl+a → 矢印: ペイン間移動"
echo "  Ctrl+a → 1, 2: ウィンドウ切り替え（claude-globalセッション）"
echo "  Ctrl+a → d: デタッチ"
echo "  Ctrl+a → q: ペイン番号表示"
echo ""
echo "タブカラー情報:"
echo "  - iTerm2のタブが色分けされて表示されます"
echo "  - 色がうまく表示されない場合は、iTerm2を再起動してください"