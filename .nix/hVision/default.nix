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
}:
mkDerivation {
  pname = "hVision";
  version = "0.3.0";
  src = /home/timsears/code/easyVision/packages/hvision;
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
  ];
  buildTools = [ mplayer2 imagemagickBig]; # runtime deps
  jailbreak = true;
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "hVision tools";
  license = "GPL";
}
