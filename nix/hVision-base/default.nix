{ mkDerivation, array, artools, base, binary, bytestring
, containers, deepseq, directory, ghc-prim, hmatrix, hmatrix-gsl
, hscolour, hTensor, old-locale, old-time, process, random
, SafeSemaphore, split, stdenv, temporary, vector
, easyVisionSrc
}:
mkDerivation {
  pname = "hVision-base";
  version = "0.5";
  src = "${easyVisionSrc}/packages/base";
  buildDepends = [
    array artools base binary bytestring containers deepseq directory
    ghc-prim hmatrix hmatrix-gsl hscolour hTensor old-locale old-time
    process random SafeSemaphore split temporary vector
  ];
  postInstall = ''
  mkdir -p $out/include
  cp -v $src/src/Image/Devel/wrappers.h $out/include
  '';
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "Utilities for pattern recognition and computer vision";
  license = "GPL";
}
