#!/usr/bin/env bash
# Unified wrapper script for GPT-5 MCP servers (architect, reviewer, troubleshooter)
# Usage: gpt5-agent.sh <agent-name>
# Example: gpt5-agent.sh architect

set -euo pipefail

AGENT_NAME="${1:-}"

if [ -z "$AGENT_NAME" ]; then
  echo "Error: Agent name required" >&2
  echo "Usage: $0 <agent-name>" >&2
  echo "Valid agents: architect, reviewer, troubleshooter" >&2
  exit 1
fi

# Validate agent name
case "$AGENT_NAME" in
  architect|reviewer|troubleshooter)
    ;;
  *)
    echo "Error: Unknown agent '$AGENT_NAME'" >&2
    echo "Valid agents: architect, reviewer, troubleshooter" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_FILE="$PROJECT_DIR/prompts/${AGENT_NAME}.txt"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Error: Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

SYSTEM_PROMPT=$(cat "$PROMPT_FILE")

exec codex mcp-server \
  -c 'model="gpt-5.2"' \
  -c 'model_reasoning_effort="high"' \
  -c "system_prompt=\"$SYSTEM_PROMPT\"" \
  -c 'sandbox="read-only"' \
  -c 'sandbox_permissions=["disk-full-read-access"]'
