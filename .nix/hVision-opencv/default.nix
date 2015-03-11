{ mkDerivation, base, hmatrix, hVision-base, opencv, stdenv
}:
mkDerivation {
  pname = "hVision-opencv";
  version = "0.2.0";
  src = /home/timsears/code/easyVision/packages/contrib/opencv;
  buildDepends = [ base hmatrix hVision-base ];
  extraLibraries = [ opencv ];
  configureFlags = "--extra-include-dirs=${opencv}/include/opencv2/ --extra-include-dirs=${opencv}/include/opencv2/nonfree/";
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "interface to selected opencv functions";
  license = "LGPL";
}
