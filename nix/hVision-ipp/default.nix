{ mkDerivation, artools, base, bytestring, hVision-base, stdenv, ippLocal, opencv, easyVisionSrc }:
mkDerivation {
  pname = "hVision-ipp";
  version = "0.3";
  src = "${easyVisionSrc}/packages/ip/ipp";
  buildDepends = [ artools base bytestring hVision-base ippLocal];
  # fixme. ghc version is hardcoded below, so is hVision-base version...
  configureFlags = [
  "--extra-include-dirs=${hVision-base}/include"
  "--extra-include-dirs=${hVision-base}/share/x86_64-linux-ghc-7.10.3/hVision-base-0.5/src/Image/Devel"
  "--extra-lib-dir=${ippLocal}/lib/lib/intel64"
  "--extra-lib-dir=${ippLocal}/lib/ipp/lib/intel64"
  "--ghc-options=-optl-pthread"
  ];
  #buildTools = [ hVision-base ];
  #pkgconfigDepends = [ hVision-base ];
  #libraryPkgconfigDepends = [ hVision-base ];
  #extraLibraries=[ "$IPP_LIBS" ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "Image processing based on IPP";
  license = "LGPL";
}
