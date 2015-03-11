{ mkDerivation, arrows, artools, base, colour, containers
, directory, ghc-prim, GLUT, hmatrix, hVision-base, OpenGL, process
, stdenv, template-haskell, time
}:
mkDerivation {
  pname = "hVision-gui";
  version = "0.3.0";
  src = /home/timsears/code/easyVision/packages/gui;
  buildDepends = [
    arrows artools base colour containers directory ghc-prim GLUT
    hmatrix hVision-base OpenGL process template-haskell time
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "simple gui for image processing and computer vision";
  license = "GPL";
}
