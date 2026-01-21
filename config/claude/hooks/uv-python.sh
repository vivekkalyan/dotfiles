#!/bin/bash
# Hook to wrap python commands with uv run python

# Read the hook input from stdin
input=$(cat)

# Parse the command from JSON
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Check if command starts with python or python3
if [[ $command =~ ^(python3?)([[:space:]]|$) ]]; then
  python_cmd="${BASH_REMATCH[1]}"
  cmd_args="${command#$python_cmd}"
  new_command="uv run ${python_cmd}${cmd_args}"

  # Escape the command for JSON
  escaped_command=$(echo "$new_command" | jq -Rs '.[:-1]')

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Wrapped ${python_cmd} with uv run",
    "updatedInput": {
      "command": ${escaped_command}
    },
    "additionalContext": "This project uses uv for Python environment management. Always use 'uv run python' instead of bare 'python' commands."
  }
}
EOF
  exit 0
fi

exit 0
