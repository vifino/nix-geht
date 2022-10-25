{ stdenv, pkgs, runtimeShell, python3 }:

stdenv.mkDerivation rec {
  name = "vpp-${version}";
  version = "22.10-rc2";
  src = pkgs.fetchFromGitHub {
    owner = "FDio";
    repo = "vpp";
    rev = "v${version}"; #"61bae8a54d14899337b0d0a7ca9b9367f6321951";
    hash = "sha256-3b+cnEjbReCg+svVD4DZwgcLwoA/IDWTGoP9ALYZFR4=";
  };
  sourceRoot = "source/src";

  nativeBuildInputs = with pkgs; [ pkg-config curl git cmake ninja nasm coreutils ];
  buildInputs = with pkgs; [
    libconfuse numactl libuuid
    libffi openssl

    python3.pkgs.wrapPython(python3.withPackages (pp: with pp; [
      ply
    ]))

    # linux-cp deps
    libnl libmnl

    # af_xdp deps
    libbpf

    # dpdk - needs static libraries, dunno how to do that.
    #dpdk
  ];

  # Needs patches..
  patchPhase = ''
    # This attempts to use git to fetch the version, but we already know it.
    printf "#!${runtimeShell}\necho '${version}~0-fakerev'\n" > scripts/version
    chmod +x scripts/version
    ./scripts/version
    substituteInPlace pkg/CMakeLists.txt --replace 'file(READ "/etc/os-release" os_release)' 'set(os_release "NAME=NIX; ID=nix")'

    patchShebangs .
  '';

  cmakeFlags = [ 
    # For debugging CMake:
    #"--trace-source=CMakeLists.txt"
    #"--trace-expand"
  ];

  # TODO: Add service
  # TODO: Add users/group for default config.
  # TODO: Fix plugin path.
  # TODO: Make dpdk work.. grr. Maybe link dynamically? Or use built-in dpdk?
}
