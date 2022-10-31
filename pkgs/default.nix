{ pkgs }:

let
  inherit (pkgs) callPackage;
  vpp-pkgs = callPackage ./vpp {};
in
rec {
  vpp = vpp-pkgs.vpp;
  vppcfg = callPackage ./vppcfg { inherit (python3Packages) vpp_papi; };

  python3Packages = rec {
    # CI script should also look for packages here.
    recurseForDerivations = true;

    vpp_papi = vpp-pkgs.vpp_papi;
  };
}
  
