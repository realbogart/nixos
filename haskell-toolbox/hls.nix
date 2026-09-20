{
  version = "2.15.0.0";
  # Match the release's cabal.project for GHC 9.14.
  # https://github.com/haskell/haskell-language-server/blob/2.15.0.0/cabal.project
  cabalProjectLocal = ''
    constraints:
      ghc-check -ghc-check-use-package-abis,
      ghc-lib-parser-ex -auto,
      stylish-haskell +ghc-lib,
      monad-control >=1.0.3
    allow-newer:
      cabal-install-parsers:Cabal-syntax,
      cabal-install-parsers:base,
      cabal-install-parsers:time,
      aeson:containers,
      aeson:template-haskell,
      aeson:time,
      binary-instances:base,
      binary-instances:tagged,
      binary-orphans:base,
      boring:base,
      cabal-install-parsers:containers,
      constraints-extras:template-haskell,
      dependent-map:containers,
      ghc-trace-events:base,
      hie-compat:base,
      indexed-traversable:base,
      indexed-traversable:containers,
      indexed-traversable-instances:base,
      lukko:base,
      quickcheck-instances:base,
      quickcheck-instances:containers,
      semialign:base,
      semialign:containers,
      string-interpolate:template-haskell,
      tasty-hspec:base,
      text-iso8601:time,
      these:base,
      time-compat:base,
      time-compat:time,
      uuid-types:template-haskell,
      websockets:containers
  '';
}
