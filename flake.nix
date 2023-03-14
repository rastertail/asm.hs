{
  description = "The functional meta-assembly framework";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.asm-hs = pkgs.haskellPackages.developPackage {
          root = ./.;
        };

        packages.default = packages.asm-hs;
      }
    );
}
