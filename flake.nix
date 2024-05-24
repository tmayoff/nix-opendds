{
  description = "Packaging OpenDDS with nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in rec {
        packages.opendds = pkgs.callPackage ./package.nix {};
        packages.default = self.packages.${system}.opendds;

        devShell = pkgs.mkShell {
          buildInputs = [
            packages.opendds
          ];
        };
      }
    );
}
