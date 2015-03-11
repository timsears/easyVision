{ mkDerivation, base, hVision, hVision-base, hVision-ipp, stdenv
, zbar
}:
mkDerivation {
  pname = "hVision-zbar";
  version = "0.1.0";
  src = ../../packages/contrib/zbar;
  buildDepends = [ base hVision hVision-base hVision-ipp ];
  extraLibraries = [ zbar ];
  homepage = "http://perception.inf.um.es/easyVision/";
  description = "simple wrapper to zbar barcode reader";
  license = "GPL";
}
