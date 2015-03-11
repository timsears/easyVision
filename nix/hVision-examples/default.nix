{ mkDerivation, base, hVision, stdenv, easyVisionSrc }:
mkDerivation {
  pname = "hVision-examples";
  version = "0.3";
  src = "${easyVisionSrc}/packages/contrib/examples";
  buildDepends = [ base hVision ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "additional low level image processing functions";
  license = "GPL";
}
