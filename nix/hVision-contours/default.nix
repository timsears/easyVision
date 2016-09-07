{ mkDerivation, artools, base, hmatrix, hmatrix-gsl, hVision-base
, stdenv, easyVisionSrc
}:
mkDerivation {
  pname = "hVision-contours";
  version = "0.2.0";
  src = "${easyVisionSrc}/packages/contours/contours";
  buildDepends = [ artools base hmatrix hmatrix-gsl hVision-base ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "contour functions and shape matching";
  license = "GPL";
}
