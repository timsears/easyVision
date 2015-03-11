{ mkDerivation, 3ds, base, GLEW, hVision-gui, stdenv }:
mkDerivation {
  pname = "hVision-models3ds";
  version = "0.1";
  src = /home/timsears/code/easyVision/packages/contrib/models3ds;
  buildDepends = [ base hVision-gui ];
  extraLibraries = [ 3ds GLEW ];
  homepage = "http://perception.inf.um.es/easyVision";
  description = "load and render 3ds models";
  license = "GPL";
}
