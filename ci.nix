# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{ pkgs ? import <nixpkgs> { }, leanVersion ? null }:

with builtins;
let
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs =
    with nurAttrs; (if leanVersion != null then [
      lean.${leanVersion}
      lean.${leanVersion}.coreLibrary
      lean.${leanVersion}.emscripten-bin
      lean.${leanVersion}.webEditor
      # TODO: lean.${leanVersion}.debugOleans
      # TODO: lean.${leanVersion}.noOleanVersionCheck
    ] else []);
in
rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
