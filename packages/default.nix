with import (fetchGit (import ./version.nix)) { };

let 
  hpkgs = haskell.packages.ghc822.extend (haskell.lib.packageSourceOverrides {
    artools = ./tools;
    hVision-base = ./base;
    hVision-classifier = ./classifier;
    hVision-clipping = ./contours/clipping;
    hVision-contours = ./contours/contours;
    hVision-custom = ./ip/custom;
    hVision-geometry = ./geometry;
    hVision-gui = ./gui;
    hVision-ipp = ./ip/ipp;
    }
  );

in 
  hpkgs
