{
  description = "Flake utils demo";

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
        mpc = pkgs.stdenv.mkDerivation {};
        opendds = pkgs.stdenv.mkDerivation {
          name = "OpenDDS";
          srcs = [
            (pkgs.fetchFromGitHub {
              name = "OpenDDS";
              owner = "OpenDDS";
              repo = "OpenDDS";
              rev = "DDS-3.27";
              hash = "sha256-wPcrXiR8Cm8/DpdfioiXu8euDabr0GpvZM+04+ERmns=";
            })
            (pkgs.fetchFromGitHub {
              name = "ACE_TAO";
              owner = "DOCGroup";
              repo = "ACE_TAO";
              rev = "ACE+TAO-7_1_4";
              hash = "sha256-ICTChzwFkQMymT60T5DiyKLSd7PcP8TXcU6RfRJr5Uw=";
            })
            (pkgs.fetchFromGitHub {
              name = "MPC";
              owner = "DOCGroup";
              repo = "MPC";
              rev = "master";
              hash = "sha256-Ia3Rt2k092E1frYWuHGNeRYHF0LHe8zBfhjAOuj7V00=";
            })
          ];

          sourceRoot = ".";

          nativeBuildInputs = with pkgs; [
            cmake
            perl
            ninja

            ripgrep
            fd

            #breakpointHook
          ];

          patchPhase = ''
            cp -r /build/ACE_TAO /build/OpenDDS
          '';

          configurePhase = ''
            cd /build/OpenDDS
            cmake -S. -Bbuild -G Ninja -DOPENDDS_ACE_TAO_SRC="$(pwd)/ACE_TAO" -DOPENDDS_MPC="$(pwd)/../MPC" -DOPENDDS_RAPIDJSON=""
          '';

          buildPhase = ''
            cd /build/OpenDDS
            ls -la ACE_TAO
            cmake --build build
          '';
        };

        defaultPackage = opendds;

        devShell = pkgs.mkShell.override {stdenv = pkgs.clangStdenv;} {
          nativeBuildInputs = with pkgs; [
            clang-tools
            python3
            perl
            ninja
          ];

          buildInputs = with pkgs; [
            gtest
          ];
        };
      }
    );
}
