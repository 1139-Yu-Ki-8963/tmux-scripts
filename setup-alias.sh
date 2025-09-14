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
if grep -q "alias cc=" "$SHELL_RC" 2>/dev/null; then
    echo "✅ 'cc' エイリアスは既に設定されています"
    echo ""
    echo "現在の設定:"
    grep "alias cc=" "$SHELL_RC"
else
    echo "📝 'cc' エイリアスを $SHELL_RC に追加します..."

    # バックアップ作成
    cp "$SHELL_RC" "$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
    echo "💾 バックアップ作成: $SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"

    # エイリアスを追加
    echo "" >> "$SHELL_RC"
    echo "# Claude Code alias" >> "$SHELL_RC"
    echo "alias cc='claude --dangerously-skip-permissions'" >> "$SHELL_RC"

    echo "✅ エイリアスを追加しました"
fi

echo ""
echo "🔄 設定を反映するには以下のいずれかを実行してください："
echo "   1. 新しいターミナルを開く"
echo "   2. source $SHELL_RC"
echo ""
echo "🧪 動作確認："
echo "   which cc      # エイリアス確認"
echo "   cc --version  # Claude Code起動テスト"
echo ""
echo "🎉 セットアップ完了！"