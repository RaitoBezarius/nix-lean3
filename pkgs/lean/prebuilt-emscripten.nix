{ version, runCommand, fetchzip }:
let
  leanReleases = builtins.fromJSON (builtins.readFile ./releases.json);
  leanBundles = fetchzip {
    url = "https://github.com/leanprover-community/lean/releases/download/v${version}/lean-${version}--browser.zip";
    sha256 = leanReleases.${version}.emscripten_sha256 or (throw "No prebuilt emscripten hash was found!");
  };
in
  runCommand "copy-emscripten-${version}-files" {} ''
    mkdir -p $out
    cp ${leanBundles}/shell/* $out/
  ''
