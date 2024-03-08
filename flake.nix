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
        ace_tao = pkgs.stdenv.mkDerivation {
          name = "ACE_TAO";
          version = "7.1.3";
          src = pkgs.fetchurl {
            url = "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-7_1_3/ACE+TAO-7.1.3.tar.gz";
            hash = "sha256-C1iSb8eAUGeAxp6erujlvHoCi88tP5RxHQdExJkmrKE=";
          };

          buildInputs = with pkgs; [
            perl
          ];

          postPatch = ''
            patchShebangs ./bin/mwc.pl
            patchShebangs ./MPC/prj_install.pl
          '';

          configurePhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=$(pwd)/MPC
            export LD_LIBRARY_PATH="$ACE_ROOT/ace:$ACE_ROOT/lib"

            echo '#include "ace/config-linux.h"' > ace/config.h
            echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU'\
              > $ACE_ROOT/include/makeinclude/platform_macros.GNU

            cd TAO
            $ACE_ROOT/bin/mwc.pl TAO_ACE.mwc -type gnuace
            cd ..
          '';

          buildPhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=$(pwd)/MPC
            export LD_LIBRARY_PATH="$ACE_ROOT/ace:$ACE_ROOT/lib"
            cd $TAO_ROOT
            make -j8
            cd ..
          '';

          installPhase = ''
            export INSTALL_PREFIX=$out
            export ACE_ROOT=$(pwd)
            export TAO_ROOT=$(pwd)/TAO
            export MPC_ROOT=$(pwd)/MPC
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
