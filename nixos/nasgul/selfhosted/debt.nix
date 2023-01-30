{ config, pkgs, ... }:

# Technical debt to refactor later xD
let
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{ }
