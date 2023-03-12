{
  description = "vifino's Nix repository - nix geht!";
  inputs = {
    # Pin nixpkgs to the commit before the DPDK bump, we need v22.03.
    # TODO: Fix this. Solve it better. Overlay?
    nixpkgs.url = "github:NixOS/nixpkgs?rev=ee01de29d2f58d56b1be4ae24c24bd91c5380cea";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-compat,
  }: let
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "i686-linux"
      "aarch64-freebsd"
      "x86_64-freebsd"
      "i686-freebsd"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);
    packages = forAllSystems (system: (import ./pkgs {
      inherit system;
      lib = nixpkgs.lib;
      pkgs = nixpkgsFor.${system};
    }));
    nixosModules = import ./modules;
  };
}
