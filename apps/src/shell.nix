# shell.nix
#
# This file defines a development environment with all the necessary
# dependencies to compile your ratatat-listener Rust application.

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # The build inputs are the packages needed to build the project.
  # Using the full 'pkgs.' prefix for each package is more robust.
  buildInputs = [
    # Rust toolchain
    pkgs.cargo
    pkgs.rustc

    # System dependencies for the 'inputbot' crate
    pkgs.pkg-config
    pkgs.libxdo
    pkgs.xorg.libXtst
    pkgs.xorg.libX11
    pkgs.xorg.xorgproto
  ];
}

