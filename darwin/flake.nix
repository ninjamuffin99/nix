{
  # darwin-rebuild switch --flake ~/.config/nix
  description = "Darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
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
        pkgs.fzf
        pkgs.eza
        pkgs.yt-dlp
        pkgs.zoxide
        pkgs.bottom
        pkgs.bat
        pkgs.htop
        pkgs.difftastic
        pkgs.rustup
        pkgs.xcodes
        pkgs.jj
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;
      nix.settings.trusted-users = ["root" "mofin" "Cameron Taylor"];

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
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Camerons-MacBook-Pro

    darwinConfigurations = {
      "Camerons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          ./darwin.nix
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mofin = import ../home-manager/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          {
            nixpkgs.overlays = [
              (import ../overlays/fish.nix)
              (import ../overlays/jj.nix)
            ];
          }
        ];
        specialArgs = {inherit inputs;};
      };
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Camerons-MacBook-Pro".pkgs;
  };
}
