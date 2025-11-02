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
          let
            packages = self.packages.${pkgs.system};
          in
            with nixpkgs.lib; map (p: packages.${p}) (lists.remove "default" (attrNames packages));
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
        flags = {
          "-f" = ./tmux.conf;
        };
      };
    });
  };
}
