{ mkDerivation, base, Cg, CgGL, cudart, freeglut, GLEW, GLUT
, hmatrix, hVision-base, hVision-gui, libdevil, mesa, siftgpu
}:
mkDerivation {
  pname = "hVision-gpu";
  version = "0.2.0";
  src = /home/timsears/code/easyVision/packages/contrib/gpu;
  buildDepends = [ base GLUT hmatrix hVision-base hVision-gui ];
  extraLibraries = [
    Cg CgGL cudart freeglut GLEW libdevil mesa siftgpu
  ];
  homepage = "https://github.com/albertoruiz/hmatrix";
  description = "image processing functions using the GPU";
  license = "LGPL";
}
