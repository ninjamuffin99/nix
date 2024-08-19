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
      ];

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";

        taps = [];
        brews = [
          "bat"
          "bottom"
          "ccache"
          "cmake"
          "cowsay"
          "dust"
          "earthly"
          "emscripten"
          "eza"
          "ffmpeg"
          "flyctl"
          "fossil"
          "fzf"
          "git"
          "git-delta"
          "git-filter-repo"
          "git-game"
          "git-lfs"
          "git-town"
          "gitoxide"
          "htop"
          "jpeg"
          "jq"
          "libmypaint"
          "libusb"
          "mbedtls@2"
          "nano"
          "neofetch"
          "neovim"
          "ninja"
          "nyancat"
          "openal-soft"
          "opencv"
          "oxipng"
          "pcre"
          "pillow"
          "pipx"
          "python-tk@3.12"
          "qt@5"
          "railway"
          "rust"
          "sapling"
          "sevenzip"
          "spicetify-cli"
          "starship"
          "sugarjar"
          "wiggle"
          "yarn"
          "yt-dlp"
          "zbar"
          "zlib"
          "zola"
          "zoxide"
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
          "wezterm"
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
