#!/bin/bash
# Hook to wrap sky commands with uv run sky

# Read the hook input from stdin
input=$(cat)

# Parse the command from JSON
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Check if command starts with sky
if [[ $command =~ ^sky([[:space:]]|$) ]]; then
  cmd_args="${command#sky}"
  new_command="uv run sky${cmd_args}"

  # Escape the command for JSON
  escaped_command=$(echo "$new_command" | jq -Rs '.[:-1]')

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Wrapped sky with uv run",
    "updatedInput": {
      "command": ${escaped_command}
    },
    "additionalContext": "This project uses uv for Python environment management. Always use 'uv run sky' instead of bare 'sky' commands."
  }
}
EOF
  exit 0
fi

exit 0
