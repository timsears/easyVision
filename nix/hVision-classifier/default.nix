{ mkDerivation, array, artools, base, containers, hmatrix
, hVision-base, process, random, stdenv, easyVisionSrc
}:
mkDerivation {
  pname = "hVision-classifier";
  version = "0.4.0";
  src = "${easyVisionSrc}/packages/classifier";
  buildDepends = [
    array artools base containers hmatrix hVision-base process random
  ];
  jailbreak = true;
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "Simple pattern recognition algorithms";
  license = "GPL";
}
