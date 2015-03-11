{ mkDerivation, base, hVision-contours, hmatrix, hVision-base, hVision-gui, hVision-lib, stdenv
}:
let contours = hVision-lib; in
mkDerivation {
  pname = "hVision-subpixel";
  version = "0.2.0";
  src = ../../packages/contrib/subpixel;
  buildDepends = [ base hmatrix hVision-base hVision-gui ];
  extraLibraries = [ contours ];
  description = "subpixel contour extraction";
  license = stdenv.lib.licenses.unfree;
}
