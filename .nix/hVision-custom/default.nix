{ mkDerivation, base, hmatrix, hVision-base, stdenv }:
mkDerivation {
  pname = "hVision-custom";
  version = "0.1";
  src = /home/timsears/code/easyVision/packages/custom;
  buildDepends = [ base hmatrix hVision-base ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "additional low level image processing functions";
  license = "GPL";
}
