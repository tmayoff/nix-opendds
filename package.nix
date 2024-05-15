{
  stdenv,
  fetchFromGitHub,
  cmake,
  perl,
}:
stdenv.mkDerivation {
  name = "OpenDDS";
  srcs = [
    (fetchFromGitHub {
      name = "OpenDDS";
      owner = "OpenDDS";
      repo = "OpenDDS";
      rev = "DDS-3.28.1";
      hash = "sha256-aa+4RLtu6gY6QrV2t9MzLiw9bo0VimGBt0aVeDS9GeU=";
    })
    (fetchFromGitHub {
      name = "ACE_TAO";
      owner = "DOCGroup";
      repo = "ACE_TAO";
      rev = "ACE+TAO-7_1_4";
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

  configurePhase = ''
    cmake -SOpenDDS -BOpenDDS/build -DOPENDDS_ACE_TAO_SRC="$(pwd)/ACE_TAO" -DOPENDDS_MPC="$(pwd)/MPC" -DOPENDDS_RAPIDJSON="" -DCMAKE_INSTALL_PREFIX=$prefix
  '';

  buildPhase = ''
    cmake --build OpenDDS/build -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    cmake --install OpenDDS/build
  '';
}
