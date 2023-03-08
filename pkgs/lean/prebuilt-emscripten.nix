{ version, runCommand, fetchzip, lib }:
let
  leanReleases = builtins.fromJSON (builtins.readFile ./releases.json);
  leanBundles = fetchzip {
    url = "https://github.com/leanprover-community/lean/releases/download/${version}/lean-${lib.removePrefix "v" version}--browser.zip";
    sha256 = leanReleases.${version}.emscripten_sha256 or (throw "No prebuilt emscripten hash was found!");
  };
in
  runCommand "copy-emscripten-${version}-files" {} ''
    mkdir -p $out
    cp ${leanBundles}/shell/* $out/
  ''
