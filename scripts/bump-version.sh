#!/bin/bash
# Uso: ./scripts/bump-version.sh 1.1.0
# Atualiza VERSION e plugin.json, faz commit + tag + push

set -e

if [ -z "$1" ]; then
  echo "Uso: ./scripts/bump-version.sh <nova-versao>"
  echo "Exemplo: ./scripts/bump-version.sh 1.1.0"
  exit 1
fi

NEW_VERSION="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Atualiza VERSION
echo "$NEW_VERSION" > "$ROOT_DIR/VERSION"

# Atualiza plugin.json (campo "version")
if command -v jq >/dev/null 2>&1; then
  jq --arg v "$NEW_VERSION" '.version = $v' "$ROOT_DIR/.claude-plugin/plugin.json" > /tmp/plugin.json.tmp
  mv /tmp/plugin.json.tmp "$ROOT_DIR/.claude-plugin/plugin.json"
else
  # Fallback sem jq: sed simples (funciona para o formato gerado por este projeto)
  sed -i.bak -E "s/\"version\": *\"[^\"]+\"/\"version\": \"$NEW_VERSION\"/" "$ROOT_DIR/.claude-plugin/plugin.json"
  rm -f "$ROOT_DIR/.claude-plugin/plugin.json.bak"
fi

echo "Versao atualizada para $NEW_VERSION em VERSION e plugin.json"

# Commit, tag e push
cd "$ROOT_DIR"
git add VERSION .claude-plugin/plugin.json
git commit -m "chore: bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"
git push
git push origin "v$NEW_VERSION"

echo "Publicado: v$NEW_VERSION"
