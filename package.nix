{
  stdenv,
  fetchFromGitHub,
  cmake,
  perl,
}:
stdenv.mkDerivation rec {
  name = "OpenDDS";
  version = "3.28.1";
  ace_version = "7_1_4";

  srcs = [
    (fetchFromGitHub {
      name = "OpenDDS";
      owner = "OpenDDS";
      repo = "OpenDDS";
      rev = "DDS-${version}";
      hash = "sha256-aa+4RLtu6gY6QrV2t9MzLiw9bo0VimGBt0aVeDS9GeU=";
    })
    (fetchFromGitHub {
      name = "ACE_TAO";
      owner = "DOCGroup";
      repo = "ACE_TAO";
      rev = "ACE+TAO-${ace_version}";
      hash = "sha256-ICTChzwFkQMymT60T5DiyKLSd7PcP8TXcU6RfRJr5Uw=";
    })
    (fetchFromGitHub {
      name = "MPC";
      owner = "DOCGroup";
      repo = "MPC";
      rev = "master";
      hash = "sha256-AEm4CI3GVa3eHOVFBTTMooVXYeW0qywZomQfTvJ/Lvs=";
    })
  ];

  sourceRoot = "OpenDDS";

  nativeBuildInputs = [
    cmake
    perl
  ];

  phases = ["unpackPhase" "configurePhase" "buildPhase" "installPhase"];

  postUnpack = ''
    cp -r /build/ACE_TAO /build/OpenDDS
    cp -r /build/MPC /build/OpenDDS
    patchShebangs /build/OpenDDS/MPC/prj_install.pl /build/OpenDDS/configure
    chmod -R +w /build/OpenDDS
  '';

  configurePhase = ''
    export ACE_ROOT=/build/OpenDDS/ACE_TAO/ACE
    export TAO_ROOT=/build/OpenDDS/ACE_TAO/TAO
    export MPC_ROOT=/build/OpenDDS/MPC
    ls -la
    ./configure --optimize --no-debug --no-rapidjson --prefix=$out
  '';

  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    export ACE_ROOT=/build/OpenDDS/ACE_TAO/ACE
    export TAO_ROOT=/build/OpenDDS/ACE_TAO/TAO
    export MPC_ROOT=/build/MPC
    export INSTALL_PREFIX=$prefix
    make install
    # make -C /build/OpenDDS/ACE_TAO install
  '';
}
