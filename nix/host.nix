{ ... }:
{
  system.stateVersion = 6;
  system.primaryUser = "vkalyan";

  # Run HM for this user
  users.users.vkalyan.home = "/Users/vkalyan";

  # disable nix
  nix.enable = false;

  # Completion initialization lives in config/zsh/.zshrc, where it uses its cache.
  programs.zsh.enableGlobalCompInit = false;

  # Bellevue, Washington: Pacific Time with US locale/region defaults.
  time.timeZone = "America/Los_Angeles";

  # Install macOS apps (e.g., Raycast) via Homebrew casks
  homebrew.enable = true;
  homebrew.onActivation = {
    # A switch only installs and removes casks; it never upgrades them. Most
    # apps update themselves, and `brew upgrade` covers the rest when run.
    autoUpdate = false;
    upgrade = false;
    # Uninstall every formula, cask and tap not listed here on each switch.
    cleanup = "uninstall";
  };
  homebrew.brews = [
    "ca-certificates"
  ];
  homebrew.casks = [
    "claude"
    "chatgpt"
    "cursor"
    "flux-app"
    "font-meslo-lg-nerd-font"
    "ghostty"
    "handy"
    "helium-browser"
    "inkscape"
    "karabiner-elements"
    "loom"
    "notion"
    "obsidian"
    "paseo"
    "raycast"
    "slack"
    "telegram"
    "todoist-app"
  ];

  # Dock size (pixels).
  system.defaults.dock.tilesize = 16;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.persistent-apps = [
    { app = "/Applications/Helium.app"; }
    { app = "/Applications/Ghostty.app"; }
    { app = "/Applications/Paseo.app"; }
    { app = "/Applications/Obsidian.app"; }
    { app = "/Applications/ChatGPT.app"; }
    { app = "/Applications/Claude.app"; }
    { app = "/Applications/Slack.app"; }
    { app = "/Applications/Notion.app"; }
    { app = "/Applications/Todoist.app"; }
    { app = "/System/Applications/Calendar.app"; }
    { app = "/Applications/zoom.us.app"; }
  ];
  system.defaults.dock.persistent-others = [
    { folder = "/Users/vkalyan/Downloads"; }
  ];

  # Disable macOS shortcuts that conflict with terminal/editor keybindings
  # ID 32 = Mission Control (ctrl+up)
  # ID 33 = Application Windows (ctrl+down)
  # ID 60 = Select previous input source (ctrl+space)
  # ID 64 = Show Spotlight search (cmd+space)
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
    AppleSymbolicHotKeys = {
      "32" = { enabled = false; };
      "33" = { enabled = false; };
      "60" = { enabled = false; };
      "64" = { enabled = false; };
    };
  };

  # Keyboard repeat settings (lower = faster)
  # KeyRepeat: delay between repeated characters (default: 6, range: 1-15)
  # InitialKeyRepeat: delay before repeat starts (default: 25, range: 15-120)
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

  # Keep notifications visible, but mute alert sounds.
  system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;

  # Mouse sensitivity (higher = more sensitive, range: -1.0 to 1.0)
  # Using CustomUserPreferences for settings not directly exposed by nix-darwin
  system.defaults.CustomUserPreferences."com.apple.mouse".scaling = 1.0;

  # Disable autocorrect
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

  # Keep macOS language/region defaults aligned with the current location.
  system.defaults.CustomUserPreferences.".GlobalPreferences" = {
    Country = "US";
    AppleLocale = "en_US";
    AppleLanguages = [ "en-US" ];
  };
  system.defaults.CustomSystemPreferences."/Library/Preferences/.GlobalPreferences" = {
    Country = "US";
    AppleLocale = "en_US";
    AppleLanguages = [ "en-US" ];
  };
  system.defaults.finder.ShowPathbar = true;

  # Save screenshots to clipboard
  system.defaults.screencapture.target = "clipboard";

}
