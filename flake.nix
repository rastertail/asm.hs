{
  description = "The functional meta-assembly framework";
  
  inputs = {
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, haskell-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ haskell-nix.overlay ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };
        flake = (pkgs.haskell-nix.project' {
          src = ./.;
          compiler-nix-name = "ghc944";
          index-state = "2023-03-13T23:23:33Z";
          shell.tools = {
            cabal = "latest";
            hlint = "latest";
            haskell-language-server = "1.9.0.0";
          };
        }).flake {};
      in flake // {
        packages.default = flake.packages."asm:lib:asm";
      }
    );
}
