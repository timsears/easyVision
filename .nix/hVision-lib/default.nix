{ fetchurl, stdenv }:
stdenv.mkDerivation rec {
  version = "0.0.1";
  name = "hVision-lib";

  src = /home/timsears/code/easyVision/lib;

  phases = [ "installPhase" "fixupPhase"];

  #TODO Worry abour lib32 later
  installPhase =''
  mkdir -vp $out/lib
  cp -vR $src/lib64/ $out/
  '';

  meta = with stdenv.lib; {
    homepage = "";
    description = "Binary libs distrubuted with easyVision. Linux only.";
    platforms = platforms.linux;
    license = licenses.unfree;
  };
}
