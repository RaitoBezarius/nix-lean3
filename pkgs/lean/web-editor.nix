{ buildNpmPackage, lib, symlinkJoin, fetchFromGitHub, lean, library ? lean.coreLibrary }:
symlinkJoin {
  name = "${lean.name}-web-editor-using-${library.name}";
  paths = [
    (buildNpmPackage {
      pname = "lean-web-editor";
      version = "unstable";

      src = fetchFromGitHub {
        owner = "RaitoBezarius";
        repo = "lean-web-editor";
        rev = "b210fea45fb722beff14991e6137be18262ae865";
        sha256 = "sha256-z8jlRWmiacexL5XrbAArfmPktGGqvDq3th21S4TNTRw=";
      };

      npmDepsHash = lib.fakeHash;

      installPhase = ''
        runHook preInstall

        cp -r dist $out

        runHook postInstall
      '';
    })
    lean.emscripten
    library
  ];
}

