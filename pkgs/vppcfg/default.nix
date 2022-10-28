{ stdenv, pkgs,
vpp-pkgs }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "vppcfg";
  version = "0.0.2-vifino";
  src = pkgs.fetchFromGitHub {
    owner = "vifino";
    repo = "vppcfg";
    rev = "9517b8dddd62a30fe8809a43c914387a8b34dc4f";
    hash = "sha256-quP0O2X43cgb1yqtpLe89Rq02bBqUzSP/XyIH3zoRko=";
  };

  propagatedBuildInputs = [ requests yamale netaddr vpp-pkgs.vpp_papi ];
}
