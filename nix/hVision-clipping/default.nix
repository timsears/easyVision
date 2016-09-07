{ mkDerivation, artools, base, hmatrix, hVision-base
, hVision-contours, easyVisionSrc
}:
mkDerivation {
  pname = "hVision-clipping";
  version = "0.1.0";
  src = "${easyVisionSrc}/packages/contours/clipping";
  buildDepends = [
    artools base hmatrix hVision-base hVision-contours
  ];
  homepage = "http://perception.inf.um.es/easyVision/";
  description = "polygon clipping";
  license = "GPL";
}
