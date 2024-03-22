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
              rev = "master";
              hash = "sha256-+i4p7ohYPmksBuNyHF0hCqzH+yi3TYWJjvJdR1UjMI4=";
            })
            (pkgs.fetchFromGitHub {
              name = "MPC";
              owner = "DOCGroup";
              repo = "MPC";
              rev = "master";
              hash = "sha256-i5dvSQjrFYnspIjT2KNXe6EL2eOv6OnDsQoabOrRV5o=";
            })
          ];

          sourceRoot = ".";

          nativeBuildInputs = with pkgs; [
            cmake
            perl
            ninja
          ];

          buildInputs = [
            #pkgs.breakpointHook
          ];

          configurePhase = ''
            echo $(pwd)
            export ACE_TAO_ROOT=$(pwd)/ACE_TAO
            export MPC_ROOT=$(pwd)/MPC
            #ls -la $ACE_ROOT
            mkdir OpenDDS/build
            cd OpenDDS/build
            cmake -G Ninja .. -DOPENDDS_ACE_TAO_SRC=$ACE_TAO_ROOT -DOPENDDS_MPC=$MPC_ROOT -DOPENDDS_RAPIDJSON=""
          '';

          buildPhase = ''
            export ACE_TAO_ROOT=$NIX_BUILD_TOP/ACE_TAO
            export MPC_ROOT=$NIX_BUILD_TOP/MPC
            ls -la /build
            ninja
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
