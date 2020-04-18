{ pkgs ? import <nixpkgs> {}
, compiler ? "ghc883"
}:

let
  myHaskellPackages = pkgs.haskell.packages.${compiler};
  telegramApiJson = pkgs.lib.importJSON ./haskell-telegram-api.json;
  telegramApiSrc = pkgs.fetchFromGitHub {
    owner = "klappvisor";
    repo = "telegram-api";
    inherit (telegramApiJson) rev sha256;
  };
  drv = pkgs.haskell.lib.dontCheck (myHaskellPackages.callCabal2nix "telegram-api" telegramApiSrc {});
  patchedTelegramApiDrv = drv.overrideAttrs (old: {
    patchPhase = ''
      sed -i 's/, servant-client == 0.16/, servant-client == 0.16.*/' telegram-api.cabal
    '';
  });
  myGhc = pkgs.haskell.packages.${compiler}.ghcWithPackages (p: with p; [
    patchedTelegramApiDrv
    http-client-tls
  ]);
in
  pkgs.mkShell {
    buildInputs = [
      myHaskellPackages.ghcid
      myGhc
    ];
  }
