let

  nixpkgsRev = "c4364cdddc421dfdb4a60fda38ed955abce1603a";
  compilerVersion = "ghc883";
  compilerSet = pkgs.haskell.packages."${compilerVersion}";

  githubTarball = owner: repo: rev:
    builtins.fetchTarball { url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; };

  pkgs = import (githubTarball "NixOS" "nixpkgs" nixpkgsRev) { inherit config; };
  
  gitIgnore = pkgs.nix-gitignore.gitignoreSourcePure;

  config = {
    packageOverrides = super: let self = super.pkgs; in rec {
      haskell = super.haskell // {
        packageOverrides = self: super: {
          hakyll-website = super.callCabal2nix "hakyll-website" (gitIgnore [./.gitignore] ./.) {};
        };
      };
    };
  };


in {
  inherit pkgs;
  shell = pkgs.haskellPackages.shellFor {
    packages = p: [p.hakyll-website];
    buildInputs = with pkgs; [
      pkgs.haskellPackages.ghc
      pkgs.haskellPackages.cabal-install
      pkgs.haskellPackages.haskell-language-server
      pkgs.haskellPackages.hlint
      pkgs.haskellPackages.ormolu
    ];
  };
  withHoogle = true;
}