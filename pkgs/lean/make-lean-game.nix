{ lib, git, remarshal, lean, writeText, runCommand, lean-game-maker, stdenvNoCC, callPackage, symlinkJoin, runCommandLocal, xlibs }:
let
  writeJSON = config: writeText "config.json" (builtins.toJSON config);
  writeTOML = config: runCommand "config.toml" {} ''
    ${remarshal}/bin/json2toml < ${writeJSON config} > $out
  '';
  mkGameData = callPackage ./make-game-data.nix {
    inherit writeTOML;
  };
in
  { src, gameConfig ? builtins.fromTOML (builtins.readFile "${src}/game_config.toml"), leanpkgTOML ? "${src}/leanpkg.toml", replaceLocalTOML ? false,
    prebuilt ? true,
    emscriptenPackage ? (pkg: if prebuilt then pkg.prebuiltEmscripten else pkg.emscripten), ... }@args:
  let
    leanpkgConfig = builtins.fromTOML (builtins.readFile leanpkgTOML);
    gameName = gameConfig.name or leanpkgConfig.name;
    safeGameName = lib.strings.sanitizeDerivationName gameName;
    leanVersion = (builtins.replaceStrings [ "leanprover-community/lean:" "." ]  [ "" "_" ] leanpkgConfig.package.lean_version);
    prefetchMathlibCache = rev: fetchTarball "https://oleanstorage.azureedge.net/mathlib/${rev}.tar.xz";
    library =
      let
        # Symbolic link the source to _target/deps/${name}
        mkAdhocDependency = name: dep:
        let
          gitSrc = builtins.fetchGit {
            url = dep.git;
            ref = "master";
            inherit (dep) rev;
          };
          src = if name == "mathlib"
          then (runCommandLocal "mathlib-azure-olean-with-src" {} ''
                cp -vr ${gitSrc} $out
                chmod -R u+w $out
                cp -vr ${prefetchMathlibCache dep.rev}/* $out/src/
              '')
          else gitSrc;
        in
        "ln -s ${src} $out/_target/deps/${name}";
        leanpkgDependencies = leanpkgConfig.dependencies;
        leanpkgPath = writeText "leanpkg.path" ''
          builtin_path
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "path _target/deps/${name}/src") leanpkgDependencies)}
          path ./src
        '';
        allDependencies = stdenvNoCC.mkDerivation {
          name = "${safeGameName}-all-dependencies";
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/_target/deps
            cp ${leanpkgPath} $out/leanpkg.path
            # symlink all sources to targets.
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkAdhocDependency leanpkgDependencies)}
          '';
        };
      in
      lean.${leanVersion}.withLibrary {
        bundlePath = symlinkJoin {
          name = "${safeGameName}-library-src-bundle";
          paths = [
            src
            allDependencies
          ];
        };
        useFOD = false; # use fetchGit to get everything at eval-time.
      };
  in
  symlinkJoin {
    name = "${safeGameName}-lean-game";
    paths = [
      (mkGameData ({ inherit src gameName gameConfig leanpkgConfig leanpkgTOML; } // args))
      lean-game-maker.web
      (emscriptenPackage lean.${leanVersion})
      # lean.${leanVersion}.coreLibrary
      library
    ];
  }
