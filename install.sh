#!/bin/bash

# tmux-scripts 自動インストーラー
# 生成日: 2025年 9月14日 日曜日 17時59分52秒 JST

set -e

PROJECT_NAME="tmux-scripts"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/share/$PROJECT_NAME}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# 色付き出力関数
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
blue() { echo -e "\033[34m$1\033[0m"; }

echo "🚀 $PROJECT_NAME インストーラーを開始します"
echo "===================================="

# インストールディレクトリの作成
echo "📁 インストールディレクトリを作成中: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# プロジェクトファイルの取得
if [ -d ".git" ]; then
    echo "📦 Gitリポジトリからインストール中..."
    git clone . "$INSTALL_DIR" 2>/dev/null || {
        echo "📂 ローカルファイルをコピー中..."
        cp -r . "$INSTALL_DIR/"
    }
else
    echo "📂 ファイルをコピー中..."
    cp -r . "$INSTALL_DIR/"
fi

cd "$INSTALL_DIR"

# Shell スクリプトのリンク作成

# PATH 確認とガイダンス
echo ""
green "🎉 tmux-scripts のインストールが完了しました！"
echo ""
echo "📍 インストール場所: $INSTALL_DIR"

# PATH 設定の確認
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    yellow "⚠️  $BIN_DIR がPATHに含まれていません"
    echo ""
    echo "以下をシェルの設定ファイル (~/.bashrc, ~/.zshrc) に追加してください:"
    echo "  export PATH=\"\$PATH:$BIN_DIR\""
    echo ""
    echo "または、今すぐ有効にする場合:"
    echo "  export PATH=\"\$PATH:$BIN_DIR\""
else
    green "✅ PATHの設定は正常です"
fi

echo "📚 使用方法:"

echo "📖 詳細なドキュメント: $INSTALL_DIR/README.md"
echo ""
