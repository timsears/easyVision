{ mkDerivation, array, artools, base, containers, directory
, hmatrix, hmatrix-gsl, hTensor, hVision-base, process, random
, stdenv
}:
mkDerivation {
  pname = "hVision-geometry";
  version = "0.3.0";
  src = /home/timsears/code/easyVision/packages/geometry;
  buildDepends = [
    array artools base containers directory hmatrix hmatrix-gsl hTensor
    hVision-base process random
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "geometric vision algorithms";
  license = "GPL";
}
