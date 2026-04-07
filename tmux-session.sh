#!/usr/bin/env bash
set -euo pipefail

# ───────────────────────────────
# 設定
# ───────────────────────────────
GHQ_ROOT=$(ghq root)
TMP_FILE=$(mktemp)

# ───────────────────────────────
# 候補リストを作成
# ───────────────────────────────
# ghq管理下の全リポジトリを取得
for repo in $(ghq list --full-path); do
  # メインリポジトリ
  echo "$repo" >> "$TMP_FILE"
  # worktreeがあれば追加
  if [ -d "$repo/.git" ] || [ -f "$repo/.git" ]; then
    git -C "$repo" worktree list --porcelain 2>/dev/null \
      | awk '/^worktree /{print $2}' \
      | grep -v "^$repo$" \
      >> "$TMP_FILE"
  fi
done

# tmuxセッション一覧も追加
tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r session; do
  echo "[session] $session" >> "$TMP_FILE"
done

# ───────────────────────────────
# pecoで選択
# ───────────────────────────────
# TARGET=$(cat "$TMP_FILE" | peco --prompt "Select repo/worktree/session > ")
# ↑これを以下のように変更

TARGET=$(cat "$TMP_FILE" | peco --prompt "Select repo/worktree/session > ")

# pecoがキャンセルされた場合、終了ステータスは通常1または0以外になることがある
# 選択結果が空の場合（キャンセル時など）に処理を中断する
if [ -z "$TARGET" ]; then
  rm -f "$TMP_FILE"
  # 正常終了 (exit 0) 
  exit 0
fi

# **重要**: 一時ファイルをこの時点で削除する
rm -f "$TMP_FILE"

# [ -z "$TARGET" ] && exit 0 はこの時点で不要になる
# rm -f "$TMP_FILE" の前に置いていたため、削除が実行されない可能性があった

# ───────────────────────────────
# 選択内容に応じて処理分岐
# ───────────────────────────────
# ... (以降の処理は変更なし)

# ───────────────────────────────
# 選択内容に応じて処理分岐
# ───────────────────────────────
if [[ "$TARGET" =~ ^\[session\]\ (.+)$ ]]; then
  # 既存セッションにアタッチ
  SESSION="${BASH_REMATCH[1]}"
  tmux switch-client -t "$SESSION"
  exit 0
fi

# ディレクトリが存在するか確認
if [ ! -d "$TARGET" ]; then
  echo "Directory not found: $TARGET" >&2
  exit 1
fi

# ディレクトリ名をセッション名に
SESSION_NAME=$(basename "$TARGET")

# ───────────────────────────────
# セッションを新規作成または切り替え
# ───────────────────────────────
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  tmux switch-client -t "$SESSION_NAME"
else
  tmux new-session -d -s "$SESSION_NAME" -c "$TARGET"
  tmux switch-client -t "$SESSION_NAME"
fi

