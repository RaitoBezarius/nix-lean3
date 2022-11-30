{ fetchFromGitHub, makeLeanGame }:
makeLeanGame {
  src = ../../../../../../lindy-labs/prototype-lean-game;
  # leanModifier = lean: lean.debugOleans;
  gameConfig = {
    name = "Fixed point arithmetics game";
    version = "0.1.0";
  };
  leanpkgTOML = ../../../../../../lindy-labs/prototype-lean-game/leanpkg.toml;
  # replaceLocalTOML = true; # override Lean version.
}
