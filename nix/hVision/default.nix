{ mkDerivation
, artools
, hmatrix
, hmatrix-gsl
, hVision-base
, hVision-contours
, hVision-custom
, hVision-geometry
, hVision-gui
, hVision-ipp
, imagemagickBig
, mplayer2
, perlPackages
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
    hVision-contours
    hVision-custom
    hVision-geometry
    hVision-gui
    hVision-ipp
    # These are really run-time deps, but they need to go here and not in buildTools
    # in order to propagate downstream
    mplayer2
    imagemagickBig
  ];
  jailbreak = true;
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "hVision tools";
  license = "GPL";
}
