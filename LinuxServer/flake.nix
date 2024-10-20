{
  description = "CentOS 9 Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-homebrew }: 
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List of packages to be installed in system profile.
      environment.systemPackages = [
        pkgs.vim
        pkgs.elixir
        pkgs.erlang
      ];

      homebrew = {
        enable = true;
        brews = [
          "git"
          "zsh"
          "nvm"
        ];
        onActivation.cleanup = "zap";
      };

      # System-wide configurations
      system.activationScripts.packages = let
        env = pkgs.buildEnv {
          name = "system-packages";
          paths = config.environment.systemPackages;
        };
      in
        pkgs.lib.mkForce ''
          # Set up packages
          echo "setting up packages..." >&2
        '';

      # Set Zsh as default shell
      programs.zsh.enable = true;

      # Auto upgrade Nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Enable experimental Nix features like flakes.
      nix.settings.experimental-features = "nix-command flakes";

      # Shell hook for GoBrew, NVM, and Zsh setup
      shellHook = ''
        # Set Zsh as the default shell
        if [ -z "$ZSH_VERSION" ]; then
          export SHELL=$(which zsh)
          exec $SHELL -l
        fi

        # Install oh-my-zsh if not already installed
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        fi

        # Install gobrew if not already installed
        if [ ! -d "$HOME/.gobrew" ]; then
          curl -sL https://raw.githubusercontent.com/kevincobain2000/gobrew/master/git.io.sh | bash
          export PATH="$HOME/.gobrew/bin:$PATH"
          gobrew install latest
          gobrew use latest
        fi

        # Load nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        # Use the latest LTS version of node
        nvm install --lts
        nvm use --lts
      '';
    };
  in
  {
    nixosConfigurations."CentOS" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        configuration
        nix-homebrew.nixosModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "Rusydy";
          };
        }
      ];
    };

    nixPackages = self.nixosConfigurations."CentOS".pkgs;
  };
}