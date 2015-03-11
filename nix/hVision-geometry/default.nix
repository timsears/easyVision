{ mkDerivation, array, artools, base, containers, directory
, hmatrix, hmatrix-gsl, hTensor, hVision-base, process, random
, stdenv, easyVisionSrc
}:
mkDerivation {
  pname = "hVision-geometry";
  version = "0.3.0";
  src = "${easyVisionSrc}/packages/geometry";
  buildDepends = [
    array artools base containers directory hmatrix hmatrix-gsl hTensor
    hVision-base process random
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "geometric vision algorithms";
  license = "GPL";
}
