{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "vpp-${version}";
  version = "git-2022-07-21";
  src = pkgs.fetchFromGitHub {
    owner = "FDio";
    repo = "vpp";
    rev = "c8cd079a0004b75892a08c7cac9a48b39e24e580";
    hash = "sha256-fx6J/g8BQYf93VGJLR+Hx/wu16Hg+ijkrRP89NnP9e0=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config curl git cmake ninja nasm ];
  buildInputs = with pkgs; [
    libconfuse numactl libuuid
    libffi libnl openssl
    dpdk
  ];
  buildPhase = "make build-release";
  installPhase = "install -Dm755 example $out";
}
