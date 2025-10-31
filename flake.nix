{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    wrappers.url = "github:lassulus/wrappers";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    nvimno.url = "github:nix-community/neovim-nightly-overlay";
    nvimno.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    nvimno,
    ...
  }: let
    each = f:
      with nixpkgs.lib;
        genAttrs systems.flakeExposed (
          system:
            f (import nixpkgs {
              inherit system;
              overlays = [nvimno.overlays.default];
            })
        );
  in {
    formatter = each (pkgs: pkgs.alejandra);
    packages = each (pkgs: {
      default = pkgs.buildEnv {
        name = "dotfiles";
        paths =
          (let
            packages = self.packages.${pkgs.system};
          in
            with nixpkgs.lib; map (p: packages.${p}) (lists.remove "default" (attrNames packages)))
          ++ (with pkgs; [
            xh
            jq
            fd
            jj
            git
            ripgrep
          ]);
      };
      neovim = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.neovim;
        flags = {
          "-u" = ./nvim.lua;
        };
      };
      tmux = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.tmux;
        env = {
          "SHELL" = "${self.packages.${pkgs.system}.bash}/bin/bash";
        };
        flags = {
          "-f" = ./tmux.conf;
        };
        preHook = ''
          unset __ETC_PROFILE_NIX_SOURCED
        '';
      };
      bash = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.bash;
        flags = {
          "--rcfile" = pkgs.writeText "bashrc" ''
            PS1="\[\e[01;32m\]\u@\h\[\e[01;34m\] \w \$\[\e[00m\] "
            eval "$(${self.packages.${pkgs.system}.direnv}/bin/direnv hook bash)"
          '';
        };
      };
      direnv = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.direnv;
        env = {
          "DIRENV_CONFIG" = pkgs.writeText "direnv" ''
            source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
          '';
        };
      };
    });
  };
}
