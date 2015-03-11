# Instructions
# 1) Locate your IPP installation on a machine where it has been installed. E.g /opt/intel
# 2) Go to the directory above and create a tarball named ipp-VERSION.tar.gz
#    where VERSION. Here the version is 7.1.1.117
# 3) Place the tarball in the directory containing this file
# 4) Rename  the version variable below as needed. The package is now complete.
# TODO: Add utility script to tarball the ipp innstallation.

{ fetchurl, stdenv }:
stdenv.mkDerivation rec {
  version = "7.1.1.117";
  name = "ippPrivate-${version}";

  src = fetchurl {
    url = "file:///home/timsears/code/hVisionPackages/ippLocal/ipp-${version}.tar.gz";
    sha256 = "0lx3sxinvh6mpivxbfm64grf94j0vrah106hmdzvamawralyw8k4";
     };

  phases = [ "unpackPhase" ];

  unpackPhase =''
  mkdir -p $out/intel
  #ln -s $out/intel $out/lib64
  tar xvfz $src -C $out
  '';

  meta = with stdenv.lib; {
    homepage = "";
    description = "Private directory tree for ipp. Raw tree, no environment varibles set by this package. See package ippLocal";
    platforms = platforms.linux;
    license = licenses.unfree;
  };
}
