{
  # darwin-rebuild switch --flake ~/.config/nix
  description = "Darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    alejandra,
    ...
  }: let
    configuration = {pkgs, ...}: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.vim
        pkgs.home-manager
        pkgs.alejandra
        pkgs.neovim
        pkgs.net-news-wire
        pkgs.fzf
        pkgs.eza
        pkgs.yt-dlp
        pkgs.zoxide
        pkgs.bottom
        pkgs.bat
        pkgs.htop
      ];

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

        taps = [];
        brews = [
          "ccache"
          "cmake"
          "dust"
          "emscripten"
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
          "libmypaint"
          "libusb"
          "libuv"
          "libpng"
          "libogg"
          "libvorbis"
          "hashlink"
          "mbedtls@2"
          "nano"
          "neofetch"
          "neovim"
          "ninja"
          "openal-soft"
          "opencv"
          "openssl"
          "oxipng"
          "pcre"
          "qt@5"
          "railway"
          "rust"
          "sdl2"
          "sapling"
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
        ];
        casks = [
          "ableton-live-intro@11"
          "dolphin@dev"
          "love"
          "obsidian"
          "warp"
          "bitwarden"
          "obs"
          "reaper"
          "rustdesk"
          "wezterm"
          "anki"
          "netnewswire"
        ];
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina

      nixpkgs.config.allowUnfree = true;

      programs.fish = with pkgs.fishPlugins; {
        enable = true;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
      system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
      system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
      system.defaults.NSGlobalDomain.KeyRepeat = 1;
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

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Camerons-MacBook-Pro
    darwinConfigurations."Camerons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [configuration];
    };

    darwinConfigurations = {
      hostname = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mofin = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Camerons-MacBook-Pro".pkgs;
  };
}
