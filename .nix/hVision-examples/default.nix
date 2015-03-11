{ mkDerivation, base, hVision-base, stdenv }:
mkDerivation {
  pname = "hVision-examples";
  version = "0.3";
  src = /home/timsears/code/easyVision/packages/contrib/examples;
  buildDepends = [ base hVision-base ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "additional low level image processing functions";
  license = "GPL";
}
