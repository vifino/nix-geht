{ pkgs ? import <nixpkgs> { } }:
let
  mypkgs = pkgs.callPackage ./pkgs {};
in 
rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  pkgs = mypkgs; # custom packages.
} // mypkgs
