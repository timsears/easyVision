#! /usr/bin/env runhaskell 
-- FIXME: overridng this config file to help out nix-build. better solution would be to add a custom config phase in nix that adds these flags and executes a simple cabal configuration. should work since the nix file is close to doing that. just requres patching the cabal file via sed, or invoking a different config phase.

import System.Environment(getEnv)
--import Image.Devel(getInclude)

main = do
    ipp_inc <- getEnv "IPP_INC"
    ipp_sha <- getEnv "IPP_SHARED"
    ipp_lib <- getEnv "IPP_LIBS"
    ipp_lnk <- getEnv "IPP_LINK"
    putStrLn ipp_sha
    --incdir <- getInclude
    writeFile "hVision-ipp.buildinfo" $ unlines
        [ -- incdir
          -- ,
          "include-dirs: "   ++ipp_inc
        , "extra-lib-dirs: " ++ f ipp_sha
        , "extra-libraries: "++ipp_lib
        , "ld-options: "     ++ipp_lnk
        ]

f = map g

g ':' = ' '
g x = x
