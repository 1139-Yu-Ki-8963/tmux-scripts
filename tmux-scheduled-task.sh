#!/bin/bash

# tmux時刻指定タスク実行システム
# 設定された時刻パターンに基づいて、tmuxペインにメッセージを送信

set -e

# 設定ファイルパス
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/schedule.conf"
PID_FILE="$SCRIPT_DIR/.tmux-scheduler.pid"
LOG_FILE="$HOME/.claude/logs/tmux-scheduler.log"
LAST_EXEC_FILE="$SCRIPT_DIR/.last_execution"

# ログディレクトリ作成
mkdir -p "$(dirname "$LOG_FILE")"

# 色付き出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ログ出力関数
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOG_FILE"
    echo -e "${GREEN}[$timestamp]${NC} $message"
}

# エラーログ出力関数
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
    echo -e "${RED}[$timestamp] ERROR:${NC} $message" >&2
}

# 設定読み込み関数
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "設定ファイルが見つかりません: $CONFIG_FILE"
        return 1
    fi
    
    # 設定ファイルの読み込み
    source "$CONFIG_FILE"
    
    # 必須パラメータのチェック
    if [[ -z "$SCHEDULE_PATTERN" ]]; then
        log_error "SCHEDULE_PATTERNが設定されていません"
        return 1
    fi
    
    # デフォルト値の設定
    TARGET_SESSION="${TARGET_SESSION:-claude-global}"
    TARGET_WINDOW="${TARGET_WINDOW:-1}"
    TARGET_PANE="${TARGET_PANE:-4}"
    MESSAGE="${MESSAGE:-定期タスク実行}"
}

# tmuxペイン存在確認
check_tmux_pane() {
    local session="$TARGET_SESSION"
    local window="$TARGET_WINDOW"
    local pane="$TARGET_PANE"
    
    if ! tmux has-session -t "$session" 2>/dev/null; then
        log_error "tmuxセッション '$session' が見つかりません"
        return 1
    fi
    
    if ! tmux list-panes -t "$session:$window" -F "#{pane_index}" 2>/dev/null | grep -q "^$pane$"; then
        log_error "ペイン $session:$window.$pane が見つかりません"
        return 1
    fi
    
    return 0
}

# 時刻パターンマッチング
match_schedule() {
    local current_time="$1"
    local pattern="$SCHEDULE_PATTERN"
    
    # 複数パターン対応（カンマ区切り）
    IFS=',' read -ra PATTERNS <<< "$pattern"
    for pat in "${PATTERNS[@]}"; do
        pat=$(echo "$pat" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # 空白除去
        
        # *:MM パターン（毎時MM分）
        if [[ "$pat" =~ ^\*:([0-9]{2})$ ]]; then
            local target_minute="${BASH_REMATCH[1]}"
            local current_minute=$(echo "$current_time" | cut -d':' -f2)
            if [[ "$current_minute" == "$target_minute" ]]; then
                return 0
            fi
        
        # HH:MM パターン（特定時刻）
        elif [[ "$pat" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
            local target_hour="${BASH_REMATCH[1]}"
            local target_minute="${BASH_REMATCH[2]}"
            # 時刻を2桁に正規化
            target_hour=$(printf "%02d" "$target_hour")
            if [[ "$current_time" == "$target_hour:$target_minute" ]]; then
                return 0
            fi
        fi
    done
    
    return 1
}

# メッセージ送信
send_message() {
    local session="$TARGET_SESSION"
    local window="$TARGET_WINDOW"
    local pane="$TARGET_PANE"
    local message="$MESSAGE"
    local timestamp=$(date '+%H:%M:%S')
    
    # 既存の入力をクリア（Claude Codeの処理を確実にするため）
    tmux send-keys -t "$session:$window.$pane" C-c
    sleep 1
    
    # コマンドを送信
    tmux send-keys -t "$session:$window.$pane" "$message"
    sleep 2  # Claude Codeの処理時間を十分に考慮
    
    # Enterキーで実行
    tmux send-keys -t "$session:$window.$pane" C-m
    
    log_message "コマンド送信: $message -> $session:$window.$pane"
}

# 実行済みチェック（同じ分内での重複実行防止）
is_already_executed() {
    local current_time="$1"
    
    if [[ -f "$LAST_EXEC_FILE" ]]; then
        local last_exec=$(cat "$LAST_EXEC_FILE" 2>/dev/null || echo "")
        if [[ "$last_exec" == "$current_time" ]]; then
            return 0  # 既に実行済み
        fi
    fi
    
    return 1  # 未実行
}

# 実行時刻を記録
mark_executed() {
    local current_time="$1"
    echo "$current_time" > "$LAST_EXEC_FILE"
}

# タスク実行
execute_task() {
    if ! load_config; then
        return 1
    fi
    
    if ! check_tmux_pane; then
        return 1
    fi
    
    local current_time=$(date '+%H:%M')
    
    if is_already_executed "$current_time"; then
        return 0  # 既に実行済み、正常終了
    fi
    
    if match_schedule "$current_time"; then
        send_message
        mark_executed "$current_time"
        return 0
    fi
    
    return 0  # マッチしなかったが正常
}

# デーモンモード
daemon_mode() {
    log_message "スケジューラーデーモン開始 (PID: $$)"
    
    # 終了シグナルの処理
    trap 'log_message "スケジューラーデーモン終了"; exit 0' TERM INT
    
    while true; do
        execute_task
        sleep 60  # 1分待機
    done
}

# プロセス状態確認
is_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0  # 実行中
        else
            rm -f "$PID_FILE"  # 無効なPIDファイルを削除
        fi
    fi
    return 1  # 停止中
}

# 使用方法表示
show_usage() {
    echo "使用方法: $0 {start|stop|status|test|config|logs}"
    echo
    echo "コマンド:"
    echo "  start   - デーモンを開始"
    echo "  stop    - デーモンを停止"
    echo "  status  - 実行状態を確認"
    echo "  test    - 単発テスト実行"
    echo "  config  - 設定を表示"
    echo "  logs    - ログを表示"
    echo
}

# メイン処理
case "${1:-}" in
    start)
        if is_running; then
            echo -e "${YELLOW}スケジューラーは既に実行中です${NC}"
            exit 1
        fi
        
        if ! load_config; then
            exit 1
        fi
        
        if ! check_tmux_pane; then
            exit 1
        fi
        
        nohup "$0" daemon > /dev/null 2>&1 &
        echo $! > "$PID_FILE"
        echo -e "${GREEN}スケジューラーデーモンを開始しました (PID: $!)${NC}"
        echo -e "${BLUE}スケジュール:${NC} $SCHEDULE_PATTERN"
        echo -e "${BLUE}ターゲット:${NC} $TARGET_SESSION:$TARGET_WINDOW.$TARGET_PANE"
        ;;
        
    stop)
        if ! is_running; then
            echo -e "${YELLOW}スケジューラーは実行されていません${NC}"
            exit 1
        fi
        
        pid=$(cat "$PID_FILE")
        kill "$pid"
        rm -f "$PID_FILE"
        echo -e "${GREEN}スケジューラーデーモンを停止しました${NC}"
        ;;
        
    status)
        if is_running; then
            pid=$(cat "$PID_FILE")
            echo -e "${GREEN}スケジューラーは実行中です (PID: $pid)${NC}"
            if load_config 2>/dev/null; then
                echo -e "${BLUE}スケジュール:${NC} $SCHEDULE_PATTERN"
                echo -e "${BLUE}ターゲット:${NC} $TARGET_SESSION:$TARGET_WINDOW.$TARGET_PANE"
            fi
        else
            echo -e "${YELLOW}スケジューラーは停止中です${NC}"
        fi
        ;;
        
    test)
        echo -e "${BLUE}単発テスト実行中...${NC}"
        if ! load_config; then
            exit 1
        fi
        
        if ! check_tmux_pane; then
            exit 1
        fi
        
        send_message
        echo -e "${GREEN}テスト完了${NC}"
        ;;
        
    config)
        if [[ -f "$CONFIG_FILE" ]]; then
            echo -e "${BLUE}設定ファイル内容:${NC}"
            cat "$CONFIG_FILE"
        else
            echo -e "${RED}設定ファイルが見つかりません: $CONFIG_FILE${NC}"
            exit 1
        fi
        ;;
        
    logs)
        if [[ -f "$LOG_FILE" ]]; then
            echo -e "${BLUE}最新のログ (最後の20行):${NC}"
            tail -20 "$LOG_FILE"
        else
            echo -e "${YELLOW}ログファイルが見つかりません${NC}"
        fi
        ;;
        
    daemon)
        # 内部使用のみ（直接呼び出し禁止）
        daemon_mode
        ;;
        
    *)
        show_usage
        exit 1
        ;;
esac