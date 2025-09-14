#!/bin/bash

# tmux セッション動的選択削除スクリプト
# 使用方法: bash ~/.claude/scripts/tmux/tmux-kill-select.sh

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# セッション存在確認
if ! tmux list-sessions &>/dev/null; then
    echo -e "${YELLOW}実行中のtmuxセッションはありません${NC}"
    exit 0
fi

# 動的にセッション一覧を取得
echo -e "${BLUE}現在のセッション一覧を取得中...${NC}"
sessions=($(tmux list-sessions -F "#{session_name}" 2>/dev/null))

if [ ${#sessions[@]} -eq 0 ]; then
    echo -e "${YELLOW}実行中のtmuxセッションはありません${NC}"
    exit 0
fi

# ヘッダー表示
echo -e "\n${MAGENTA}=================================${NC}"
echo -e "${MAGENTA}    tmux セッション管理ツール    ${NC}"
echo -e "${MAGENTA}=================================${NC}"

# セッション一覧を番号付きで表示
echo -e "\n${YELLOW}=== 現在のtmuxセッション ===${NC}"
for i in "${!sessions[@]}"; do
    session_name=${sessions[$i]}
    # セッション詳細情報を取得
    session_info=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null | grep "^${session_name}:")
    echo -e "${CYAN}$((i+1)))${NC} ${session_info}"
done

# 選択オプション
echo -e "\n${GREEN}=== 操作オプション ===${NC}"
echo -e "${CYAN}all)${NC} すべてのセッション削除 (kill-server)"
echo -e "${CYAN}0)${NC} キャンセル"

# 使用方法の説明
echo -e "\n${GREEN}使用方法:${NC}"
echo -e "  • 単一選択: ${YELLOW}3${NC}"
echo -e "  • 複数選択: ${YELLOW}1 3 5${NC} (スペース区切り)"
echo -e "  • 全削除: ${YELLOW}all${NC}"
echo -e "  • キャンセル: ${YELLOW}0${NC}"

# 選択を受け付け
echo -e "\n${GREEN}killするセッションを選択してください:${NC}"
read -p "> " choices

# 入力内容をトリム
choices=$(echo "$choices" | xargs)

# all選択の処理
if [[ "$choices" == "all" ]]; then
    echo -e "\n${RED}⚠️  すべてのセッションを削除します ⚠️${NC}"
    read -p "本当によろしいですか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux kill-server
        echo -e "${RED}✓ すべてのセッションを削除しました${NC}"
    else
        echo -e "${GREEN}キャンセルしました${NC}"
    fi
    exit 0
fi

# 0でキャンセル
if [[ "$choices" == "0" || -z "$choices" ]]; then
    echo -e "${GREEN}キャンセルしました${NC}"
    exit 0
fi

# 選択されたセッションをkill
echo -e "\n${BLUE}セッション削除を実行中...${NC}"
killed_sessions=()
invalid_choices=()

for choice in $choices; do
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#sessions[@]} ]; then
        session_name=${sessions[$((choice-1))]}
        if tmux kill-session -t "$session_name" 2>/dev/null; then
            killed_sessions+=("$session_name")
            echo -e "${RED}✓ Killed:${NC} $session_name"
        else
            echo -e "${YELLOW}⚠️  Failed to kill:${NC} $session_name"
        fi
    else
        invalid_choices+=("$choice")
    fi
done

# 結果サマリー
echo -e "\n${MAGENTA}=== 実行結果 ===${NC}"

if [ ${#killed_sessions[@]} -gt 0 ]; then
    echo -e "${GREEN}削除されたセッション (${#killed_sessions[@]}個):${NC}"
    for session in "${killed_sessions[@]}"; do
        echo -e "  ${RED}•${NC} $session"
    done
fi

if [ ${#invalid_choices[@]} -gt 0 ]; then
    echo -e "${YELLOW}無効な選択 (${#invalid_choices[@]}個):${NC}"
    for choice in "${invalid_choices[@]}"; do
        echo -e "  ${YELLOW}•${NC} $choice"
    done
fi

# 残りのセッション表示
remaining_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
if [ -n "$remaining_sessions" ]; then
    echo -e "\n${GREEN}残存セッション:${NC}"
    while IFS= read -r session; do
        session_info=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null | grep "^${session}:")
        echo -e "  ${CYAN}•${NC} $session_info"
    done <<< "$remaining_sessions"
else
    echo -e "\n${GREEN}✓ すべてのセッションが終了しました${NC}"
fi

echo -e "\n${MAGENTA}処理が完了しました${NC}"