{ pkgs }:

with pkgs;
let
  vpp-pkgs = callPackage ./vpp {};
in
rec {
  vpp = vpp-pkgs.vpp;
  vppcfg = callPackage ./vppcfg { inherit vpp; };

  python3Packages = rec {
    # CI script should also look for packages here.
    recurseForDerivations = true;

    vpp_papi = vpp-pkgs.vpp_papi;
  };
}
  
