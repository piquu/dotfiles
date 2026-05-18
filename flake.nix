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
    systems = nixpkgs.lib.systems.flakeExposed;
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nvimno.overlays.default];
      };
    in {
      default = pkgs.buildEnv {
        name = "dotfiles";
        paths = let
          packages = self.packages.${pkgs.stdenv.hostPlatform.system};
        in
          with nixpkgs.lib; map (p: packages.${p}) (lists.remove "default" (attrNames packages));
      };
      neovim = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.neovim;
        runtimeInputs = with pkgs; [tree-sitter];
        flags = {
          "-u" = "${./nvim.lua}";
        };
      };
      tmux = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.tmux;
        flags = {
          "-f" = "${./tmux.conf}";
        };
      };
    });
  };
}
