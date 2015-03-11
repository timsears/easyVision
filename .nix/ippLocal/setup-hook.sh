addIPPEnvironment() {
  echo "addIPPEnvironment for package ($1)"
  export IPP_INC="@out@/include";
  export IPP_SHARED="@out@/lib/lib/intel64/:@out@/lib/ipp/lib/intel64/";
  addToSearchPath LD_LIBRARY_PATH @out@/lib/lib/intel64/;
  addToSearchPath LD_LIBRARY_PATH @out@/lib/ipp/lib/intel64/;
  export IPP_LIBS="ippcore ippi ipps ippcc ippvc ippcv iomp5";
  export IPP_LINK="-pthread";
  echo addIPPEnvironment: Checking environment...
  echo IPP_INC=$IPP_INC;
  echo IPP_SHARED=$IPP_SHARED;
  echo IPP_LIBS=$IPP_LIBS;
  echo IPP_LINK=$IPP_LINK;
  echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH;
  echo addIPPEnvironment: Done.
}

#preConfigure+=(addIPPEnvironment) #only add when building software
addIPPEnvironment
