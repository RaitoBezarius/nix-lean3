# Nix for Lean 3

![Build and populate cache](https://github.com/RaitoBezarius/nix-lean3/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-nix-lean3-blue.svg)](https://nix-lean3.cachix.org)

This repository offers many Lean 3 versions, useful for:

- running automation on the top of Lean 3 independent of versions ;
- having emscripten bundles for many Lean 3 versions while keeping cache properties for mathlib
   - currently, prebuilt emscripten bundles using emscripten 1.x are the ones who works the best using current nixpkgs
   - there is a very experimental setup for emscripten 3.x bundles, but it is extremely cursed: maximum call stack size, strange clear tactic exceptions errors, etc. If you want to help with this, please do so! I spent a lot of time on hacking on emscripten and I have no clear idea on how to fix this. (latest emscripten tested: 3.1.24, using https://github.com/NixOS/nixpkgs/pull/206005).
- automation to build Lean games

## Known Limitations

This flake cannot be used in pure evaluation mode if you are using mathlib cache because it relies on a non-sha256 pinned `fetchTarball` call.

I will add a GitHub Action which will fetch over multiple revisions of mathlib and compile a JSON of SHA256 so it can be used for pure evaluation mode.

## What Is Not Cached And Should

- `oleans` debugger version (patch is broken across all versions)
- no olean version check version (patch is broken across all versions)

## TODO

- Add automation to upgrade nixpkgs
- Fix emscripten 3.x branch
