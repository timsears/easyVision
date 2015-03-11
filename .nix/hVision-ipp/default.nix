{ mkDerivation, artools, base, bytestring, hVision-base, stdenv, ippLocal, opencv }:
mkDerivation {
  pname = "hVision-ipp";
  version = "0.3";
  src = /home/timsears/code/easyVision/packages/ipp;
  buildDepends = [ artools base bytestring hVision-base ippLocal ];
  configureFlags = [
  "--extra-include-dirs=${hVision-base}/include"
  "--extra-include-dirs=${hVision-base}/share/x86_64-linux-ghc-7.8.4/hVision-base-0.5/src/Image/Devel"
  "--extra-lib-dir=${ippLocal}/lib/lib/intel64"
  "--extra-lib-dir=${ippLocal}/lib/ipp/lib/intel64"
  "--ghc-options=-optl-pthread"
  ];
  #buildTools = [ hVision-base ];
  pkgconfigDepends = [ hVision-base ];
  extraLibraries=[ "$IPP_LIBS" ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "Image processing based on IPP";
  license = "LGPL";
}
