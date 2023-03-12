{
  system,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs) callPackage;

  vpp-pkgs = callPackage ./vpp {};
  shinyblink = callPackage ./shinyblink {};
in
  rec {
    # TODO: More packages!
    inherit (shinyblink) ffshot ff-overlay ff-sort ff-glitch ff-notext;

    opensoundmeter = pkgs.libsForQt5.callPackage ./opensoundmeter.nix {};
  }
  // optionalAttrs (hasSuffix "-linux" system) rec {
    # Packages that only run on Linux.
    inherit (vpp-pkgs) vpp vpp_papi;
    vppcfg = callPackage ./vppcfg {inherit vpp_papi;};
  }
