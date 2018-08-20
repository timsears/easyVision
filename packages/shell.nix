let pkgs = import (fetchGit (import ./version.nix)) { };
in
(import ./.).shellFor {
        packages = p: [ p.artools
                        p.hVision
                        p.hVision-base
                        p.hVision-classifier
                        p.hVision-clipping
                        p.hVision-contours
                        p.hVision-custom
                        p.hVision-geometry
                        p.hVision-gui
                        p.hVision-ipp
                        #p.hVision-tesseract
                      ];
        withHoogle = true;
        buildInputs = with pkgs; [ ippLocal
                                   imagemagickBig
                                   perlPackages.ImageExifTool
                                   mplayer
                                   #tesseract
                                   cabal-install
                                   #leptonica
                                   zbar
                                   ];
        }            
          

