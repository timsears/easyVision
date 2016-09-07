{ mkDerivation
, artools
, hmatrix
, hmatrix-gsl
, hVision-base
, hVision-contours
, hVision-classifier
, hVision-clipping
, hVision-custom
, hVision-geometry
, hVision-gui
, hVision-ipp
, imagemagickBig
, mplayer
, perlPackages
, tesseract
, easyVisionSrc
}:
mkDerivation {
  pname = "hVision";
  version = "0.3.0";
  src = "${easyVisionSrc}/packages/hvision";
  buildDepends = [
    artools
    hmatrix
    hmatrix-gsl
    hVision-base
    hVision-classifier
    hVision-clipping
    hVision-contours
    hVision-custom
    hVision-geometry
    hVision-gui
    hVision-ipp
    # These are really run-time deps, but they need to go here and not in buildTools
    #
    # in order to propagate downstream
    mplayer
    imagemagickBig
    perlPackages.ImageExifTool
    mplayer
    tesseract
  ];
  jailbreak = true;
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "hVision tools";
  license = "GPL";
}
