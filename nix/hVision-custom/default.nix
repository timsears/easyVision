{ mkDerivation, base, hmatrix, hVision-base, stdenv, easyVisionSrc }:
mkDerivation {
  pname = "hVision-custom";
  version = "0.1";
  src = "${easyVisionSrc}/packages/ip/custom";
  buildDepends = [ base hmatrix hVision-base ];
  configureFlags = [
  #"--extra-include-dirs=${hVision-base}/include"
  #"--extra-include-dirs=${hVision-base}/share/x86_64-linux-ghc-7.10.3/hVision-base-0.5/src/Image/Devel"
  #"--extra-lib-dir=${ippLocal}/lib/lib/intel64"
  #"--extra-lib-dir=${ippLocal}/lib/ipp/lib/intel64"
  #"--ghc-options=-optl-pthread"
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "additional low level image processing functions";
  license = "GPL";
}
