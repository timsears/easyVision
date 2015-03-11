{ mkDerivation, artools, base, hmatrix, hVision-base
, hVision-contours
}:
mkDerivation {
  pname = "hVision-clipping";
  version = "0.1.0";
  src = /home/timsears/code/easyVision/packages/contrib/clipping;
  buildDepends = [
    artools base hmatrix hVision-base hVision-contours
  ];
  homepage = "http://perception.inf.um.es/easyVision/";
  description = "polygon clipping";
  license = "GPL";
}
