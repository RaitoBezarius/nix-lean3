{ lib, fetchFromGitHub, callPackage, emscripten }:
let
  mergeMap = f: set: builtins.foldl' (x: acc: x // acc) {} (map (k: f k set.${k}) (builtins.attrNames set));
  leanReleases = lib.importJSON ./releases.json;
  processVersionName = ver: lib.removePrefix "v" (lib.replaceStrings ["."] ["_"] ver);
  mkLeanRelease = version: releaseInfo: {
    ${processVersionName version} = (callPackage ./generic.nix {
      inherit version emscripten;
      leanUtils = callPackage ./utils.nix {};
      src = fetchFromGitHub {
        inherit (releaseInfo) owner repo rev sha256;
      };
      disableTests = isImportantRelease version;
      inherit (releaseInfo) githash;
    });
  };
  brokenReleases = [ ];
  # Disable tests for important releases as they will not work out of the box.
  importantReleases = [];
  minimalVersion = "v3.31.0";
  releaseIncludedIn = list: v: builtins.any (v2: v == v2) list;
  isBrokenRelease = releaseIncludedIn brokenReleases;
  isImportantRelease = releaseIncludedIn importantReleases;
  isAcceptableVersion = v: lib.versionAtLeast v minimalVersion;
in
  mergeMap mkLeanRelease (lib.filterAttrs (name: _: !isBrokenRelease name && (isAcceptableVersion name || isImportantRelease name)) leanReleases)
