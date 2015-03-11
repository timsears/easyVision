{ mkDerivation, array, base, binary, deepseq, directory, hmatrix
, hscolour, old-locale, old-time, parsec, process, random, split
, stdenv, transformers, vector
}:
mkDerivation {
  pname = "artools";
  version = "0.1.0";
  src = ../../packages/tools;
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    array base binary deepseq directory hmatrix hscolour old-locale
    old-time parsec process random split transformers vector
  ];
  homepage = "https://github.com/albertoruiz/hmatrix";
  description = "General purpose utilities";
  license = stdenv.lib.licenses.bsd3;
}
