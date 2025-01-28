{
  config,
  pkgs,
  inputs,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.net-news-wire
    pkgs.home-manager
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    taps = [];
    brews = [
      "aria2"
      "brotli"
      "ccache"
      "cmake"
      "dust"
      "docker"
      "neofetch"
      "earthly"
      "ffmpeg"
      "git"
      "git-delta"
      "git-filter-repo"
      "git-lfs"
      "git-town"
      "gitoxide"
      "jpeg"
      "jpeg-turbo"
      "libjpeg-turbo"
      "jq"
      "less"
      "libmypaint"
      "libusb"
      "libuv"
      "libpng"
      "libogg"
      "libvorbis"
      "hashlink"
      "mbedtls@2"
      "nano"
      "ninja"
      "openal-soft"
      "opencv"
      "openssl"
      "oxipng"
      "python"
      "pcre"
      "qt@5"
      "railway"
      "sdl2"
      "sevenzip"
      "spicetify-cli"
      "starship"
      "sugarjar"
      "sqlite"
      "wiggle"
      "yarn"
      "zbar"
      "zlib"
      "zola"
      "zsh-autosuggestions"
      "fd"
      "git-cliff"
    ];
    casks = [
      "dolphin@dev"
      "love"
      "obsidian"
      "warp"
      "bitwarden"
      "obs"
      "reaper"
      "rustdesk"
      "wezterm@nightly"
      "anki"
      "netnewswire"
      "zed"
      "betterdisplay"
      "localsend"
      "ghostty"
      "httpie"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nix/darwin";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  security.pam.enableSudoTouchIdAuth = true;
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  users.users.mofin = {
    name = "mofin";
    home = "/Users/mofin";
  };
}
