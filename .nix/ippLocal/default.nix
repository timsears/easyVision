{ fetchurl, stdenv, ippPrivate }:
stdenv.mkDerivation {
  name = "ippLocal";

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
  #echo installPhase: Starting...
  #echo "Directory tree for ipp is "${ippPrivate.outPath}
  #echo "Soft linking to (hopefully cached) ipp directory tree"
  mkdir -p $out
  ln -sf ${ippPrivate.outPath}/intel $out/lib
  ln -sf $out/lib $out/lib64
  ln -sf "${ippPrivate}/intel/composerxe/ipp/include" $out/include;
  #echo "New location is $out"
  #echo "end installPhase"
  '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = "";
    description = "Nix package for locally installed verions of Intell IPP.
       You must supply your own IPP library. TODO: add instructions.";
    platforms = platforms.linux;
    license = licenses.unfree;
  };
}
