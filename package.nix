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

  sourceRoot = ".";

  nativeBuildInputs = [
    cmake
    perl
  ];

  postPatch = ''
    patchShebangs /build/MPC/prj_install.pl
  '';

  postUnpack = ''
    cp -r /build/ACE_TAO /build/OpenDDS
  '';

  configurePhase = ''
    cmake -SOpenDDS -BOpenDDS/build -DOPENDDS_ACE_TAO_SRC="/build/OpenDDS/ACE_TAO" -DOPENDDS_MPC="/build/MPC" -DOPENDDS_RAPIDJSON="" -DCMAKE_INSTALL_PREFIX=$prefix
  '';

  buildPhase = ''
    cmake --build OpenDDS/build -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    cmake --install OpenDDS/build
    export ACE_ROOT=/build/OpenDDS/ACE_TAO/ACE
    export TAO_ROOT=/build/OpenDDS/ACE_TAO/TAO
    export MPC_ROOT=/build/MPC
    export INSTALL_PREFIX=$prefix
    make -C /build/OpenDDS/ACE_TAO install
  '';
}
