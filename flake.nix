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
        mpc = pkgs.stdenv.mkDerivation {
          name = "MPC";
          src = pkgs.fetchFromGitHub {
            owner = "DOCGroup";
            repo = "MPC";
            rev = "master";
            hash = "sha256-i5dvSQjrFYnspIjT2KNXe6EL2eOv6OnDsQoabOrRV5o=";
          };

          phases = ["patchPhase" "installPhase"];

          postPatch = ''
            patchShebangs prj_install.pl
          '';

          installPhase = ''
            mkdir -p $out
            cp -r $src/* $out/
          '';
        };

        ace_tao = pkgs.stdenv.mkDerivation {
          name = "ACE_TAO";
          src = pkgs.fetchFromGitHub {
            owner = "DOCGroup";
            repo = "ACE_TAO";
            rev = "master";
            hash = "sha256-+i4p7ohYPmksBuNyHF0hCqzH+yi3TYWJjvJdR1UjMI4=";
          };

          nativeBuildInputs = [
            mpc
          ];

          buildInputs = with pkgs; [
            perl
          ];

          postPatch = ''
            patchShebangs ACE/bin/mwc.pl
          '';

          configurePhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)/ACE
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=${mpc}
            export LD_LIBRARY_PATH="$ACE_ROOT/ace:$ACE_ROOT/lib"

            echo '#include "ace/config-linux.h"' > ACE/ace/config.h
            echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU'\
              > $ACE_ROOT/include/makeinclude/platform_macros.GNU

            cd TAO
            $ACE_ROOT/bin/mwc.pl TAO_ACE.mwc -type gnuace
            cd ..
          '';

          buildPhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)/ACE
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=${mpc}
            export LD_LIBRARY_PATH="$ACE_ROOT/ace:$ACE_ROOT/lib"
            cd $TAO_ROOT
            make -j8
            cd ..
          '';

          installPhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)/ACE
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=${mpc}
            cd $TAO_ROOT
            make install
          '';
        };

        opendds = pkgs.stdenv.mkDerivation {
          name = "OpenDDS";
          src = pkgs.fetchFromGitHub {
            owner = "OpenDDS";
            repo = "OpenDDS";
            rev = "master";
            hash = "sha256-LULh2Dw1MlLTH2pqS8L0hCR9yTAtB9yCmTbwwC6O6Z4=";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
          ];

          buildInputs = [
            ace_tao
          ];

          cmakeFlags = [
            "-DOPENDDS_ACE=${ace_tao}/ACE"
            "-DOPENDDS_TAO=${ace_tao}/TAO"
            "-DOPENDDS_RAPIDJSON="
          ];
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
