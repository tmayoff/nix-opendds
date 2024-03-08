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
              rev = "master";
              hash = "sha256-LULh2Dw1MlLTH2pqS8L0hCR9yTAtB9yCmTbwwC6O6Z4=";
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
            
          ];

          cmakeFlags = [
            "-DOPENDDS_ACE_TAO_SRC=../ACE_TAO"
            "-DOPENDDS_RAPIDJSON="
          ];

          configurePhase = ''
            ls -la ./
            mkdir OpenDDS/build
            cd OpenDDS/build
            #cmake .. -DOPENDDS_ACE=../../ACE_TAO/ACE -DOPENDDS_TAO=../../ACE_TAO/TAO -DOPENDDS_MPC=../../MPC
            cmake .. -DOPENDDS_ACE_TAO_SRC=../../ACE_TAO -DOPENDDS_MPC=../../MPC
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
