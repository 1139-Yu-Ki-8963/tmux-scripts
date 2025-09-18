#!/bin/bash

# setup-alias.sh - Claude Code用エイリアス設定スクリプト
# 使用方法: ./setup-alias.sh

set -e

echo "🚀 Claude Code用エイリアス設定を開始します"
echo "=================================="

# シェルの設定ファイルを特定
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "❌ Error: サポートされていないシェルです ($SHELL)"
    echo "   対応シェル: zsh, bash"
    exit 1
fi

echo "🔍 検出されたシェル: $SHELL_NAME"
echo "📁 設定ファイル: $SHELL_RC"

# 設定ファイルが存在しない場合は作成
if [ ! -f "$SHELL_RC" ]; then
    echo "📝 設定ファイルを作成中: $SHELL_RC"
    touch "$SHELL_RC"
fi

# エイリアスが既に存在するかチェック
cc_exists=$(grep -q "alias cc=" "$SHELL_RC" 2>/dev/null && echo "true" || echo "false")
ccs_exists=$(grep -q "alias ccs=" "$SHELL_RC" 2>/dev/null && echo "true" || echo "false")

if [ "$cc_exists" = "true" ] && [ "$ccs_exists" = "true" ]; then
    echo "✅ Claude Code エイリアスは既に設定されています"
    echo ""
    echo "現在の設定:"
    grep "alias cc\|alias ccs" "$SHELL_RC"
else
    echo "📝 Claude Code エイリアスを $SHELL_RC に追加します..."
    echo "   - cc:  通常版（許可確認あり）"
    echo "   - ccs: スキップ版（自動化用）"

    # バックアップ作成
    cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
    echo "💾 バックアップ作成: $SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"

    # エイリアスを追加
    echo "" >> "$SHELL_RC"
    echo "# Claude Code aliases" >> "$SHELL_RC"

    if [ "$cc_exists" = "false" ]; then
        echo "alias cc='claude'" >> "$SHELL_RC"
        echo "✅ cc エイリアス（通常版）を追加しました"
    fi

    if [ "$ccs_exists" = "false" ]; then
        echo "alias ccs='claude --dangerously-skip-permissions'" >> "$SHELL_RC"
        echo "✅ ccs エイリアス（スキップ版）を追加しました"
    fi
fi

echo ""
echo "🔄 設定を反映するには以下のいずれかを実行してください："
echo "   1. 新しいターミナルを開く"
echo "   2. source $SHELL_RC"
echo ""
echo "🧪 動作確認："
echo "   which cc       # 通常版エイリアス確認"
echo "   which ccs      # スキップ版エイリアス確認"
echo "   cc --version   # Claude Code起動テスト（許可確認あり）"
echo "   ccs --version  # Claude Code起動テスト（スキップ版）"
echo ""
echo "📖 エイリアス使い分け："
echo "   cc:  手動実行用（安全・許可確認あり）"
echo "   ccs: 自動化・tmux用（効率・許可スキップ）"
echo ""
echo "🎉 セットアップ完了！"