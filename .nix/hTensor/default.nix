# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, hmatrix, random }:

cabal.mkDerivation (self: {
  pname = "hTensor";
  version = "0.8.2";
  sha256 = "1nwzh68v2b11lph64432bjdrpxrr62cv4hdh935wml13mac3l2ly";
  buildDepends = [ hmatrix random ];
  jailbreak = true;
  meta = {
    homepage = "http://perception.inf.um.es/tensor";
    description = "Multidimensional arrays and simple tensor computations";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
