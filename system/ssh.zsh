# Load the GitHub signing key from macOS Keychain into ssh-agent, if available.
if [[ "$(uname -s 2>/dev/null)" = "Darwin" && -S "${SSH_AUTH_SOCK:-}" ]]; then
  _vk_github_key="$HOME/.ssh/github"
  _vk_github_pub="$HOME/.ssh/github.pub"

  if [[ -r "$_vk_github_key" && -r "$_vk_github_pub" ]]; then
    _vk_github_fingerprint="$(/usr/bin/ssh-keygen -lf "$_vk_github_pub" 2>/dev/null | awk '{print $2}')"
    if [[ -n "$_vk_github_fingerprint" ]] && ! /usr/bin/ssh-add -l 2>/dev/null | awk '{print $2}' | grep -qx "$_vk_github_fingerprint"; then
      /usr/bin/ssh-add --apple-load-keychain "$_vk_github_key" >/dev/null 2>&1
    fi
    unset _vk_github_fingerprint
  fi

  unset _vk_github_key _vk_github_pub
fi
