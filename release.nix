# You can build this repository using Nix by running:
#
#     $ nix-build -A dhall-bash release.nix
#
# You can also open up this repository inside of a Nix shell by running:
#
#     $ nix-shell -A dhall-bash.env release.nix
#
# ... and then Nix will supply the correct Haskell development environment for
# you
let
  config = {
    packageOverrides = pkgs: {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: {
          dhall = haskellPackagesNew.callPackage ./dhall.nix { };

          dhall-bash =
           pkgs.haskell.lib.justStaticExecutables
             (haskellPackagesNew.callPackage ./default.nix { });
        };
      };
    };
  };

  pkgs =
    import <nixpkgs> { inherit config; };

in
  { dhall-bash = pkgs.haskellPackages.dhall-bash;
  }
