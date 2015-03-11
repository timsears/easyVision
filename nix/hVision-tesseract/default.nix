{ mkDerivation, base, directory, filepath, hVision, process, stdenv
, temporary
}:
mkDerivation {
  pname = "hVision-tesseract";
  version = "0.1.0";
  src = ../../packages/contrib/tesseract;
  buildDepends = [
    base directory filepath hVision process temporary
  ];
  homepage = "https://github.com/albertoruiz/easyVision";
  description = "simple wrapper to tesseract ocr";
  license = "GPL";
}
