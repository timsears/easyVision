#! /usr/bin/env runhaskell

> import Distribution.Simple
> import Distribution.Simple.PreProcess
> import Distribution.Simple.LocalBuildInfo
> import Distribution.PackageDescription
> import Distribution.Simple.Utils

> main = defaultMainWithHooks autoconfUserHooks
