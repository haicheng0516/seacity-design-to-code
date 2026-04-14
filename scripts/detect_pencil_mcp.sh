#!/usr/bin/env bash
# Detect if Pencil MCP is available in Claude Code.
# This script is invoked by the Skill at startup to verify prerequisites.

set -e

EXIT_OK=0
EXIT_NO_MCP=1
EXIT_ERROR=2

check_pencil_mcp() {
    # Look for Pencil MCP config in standard locations
    SETTINGS_LOCATIONS=(
        "$HOME/.claude/settings.json"
        "$HOME/.config/claude/settings.json"
        "$HOME/Library/Application Support/Claude/settings.json"
    )

    for f in "${SETTINGS_LOCATIONS[@]}"; do
        if [[ -f "$f" ]]; then
            if grep -q "\"pencil\"" "$f" 2>/dev/null; then
                echo "✅ Pencil MCP configured in $f"
                return 0
            fi
        fi
    done

    echo "❌ Pencil MCP not found in any settings.json"
    echo ""
    echo "To install Pencil MCP, see:"
    echo "  reference/setup_pencil.md"
    echo ""
    echo "Quick steps:"
    echo "  1. Install Pencil app"
    echo "  2. Enable MCP in Pencil preferences"
    echo "  3. Run: claude mcp add pencil --command <pencil-mcp-cmd>"
    echo "  4. Restart Claude Code"
    return 1
}

check_pencil_mcp
