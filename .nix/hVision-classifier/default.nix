{ mkDerivation, array, artools, base, containers, hmatrix
, hVision-base, process, random, stdenv
}:
mkDerivation {
  pname = "hVision-classifier";
  version = "0.4.0";
  src = /home/timsears/code/easyVision/packages/classifier;
  buildDepends = [
    array artools base containers hmatrix hVision-base process random
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "Simple pattern recognition algorithms";
  license = "GPL";
}
