{ callPackage }:
{
  nng = callPackage ./nng.nix {};
  game-skeleton = callPackage ./game-skeleton.nix {};
  ll-prototype-game = callPackage ./ll-prototype-game.nix {};
}
