# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // (builtins.removeAttrs self [ "lib" "modules" "overlays" ]));
  leanAttribute = leanset: attr: pkgs.lib.mapAttrs (_: p: p.${leanAttribute}) (pkgs.lib.filterAttrs (_: p: p ? attr) leanset) // { recurseForDerivations = true; };
  self = rec {
    # Propagate this custom callPackage to children.
    inherit callPackage;

    # The `lib`, `modules`, and `overlay` names are special
    lib = import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    lean = (callPackage ./pkgs/lean { }) // { recurseForDerivations = true; }; # Build all versions.
    makeLeanGame = callPackage ./pkgs/lean/make-lean-game.nix { };
    leanGames = callPackage ./pkgs/lean/lean-games { };
    lean-game-maker = callPackage ./pkgs/lean/lean-game-maker {
      python = pkgs.python3;
    };

    emscriptenPackages = {
      lean-bin = leanAttribute lean "emscripten-bin";
      recurseForDerivations = true;
    };

    webPackages = {
      lean-editor = leanAttribute lean "webEditor";
      recurseForDerivations = true;
    };

    leanPackages = {
      core-library = leanAttribute lean "coreLibrary";
      recurseForDerivations = true;
    };
  };
in
  self
