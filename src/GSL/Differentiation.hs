{-# OPTIONS  #-}
-----------------------------------------------------------------------------
{- |
Module      :  GSL.Differentiation
Copyright   :  (c) Alberto Ruiz 2006
License     :  GPL-style

Maintainer  :  Alberto Ruiz (aruiz at um dot es)
Stability   :  provisional
Portability :  uses ffi

Numerical differentiation.

<http://www.gnu.org/software/gsl/manual/html_node/Numerical-Differentiation.html#Numerical-Differentiation>

From the GSL manual: \"The functions described in this chapter compute numerical derivatives by finite differencing. An adaptive algorithm is used to find the best choice of finite difference and to estimate the error in the derivative.\"
-}
-----------------------------------------------------------------------------
module GSL.Differentiation (
    derivCentral,
    derivForward,
    derivBackward
) where

import Foreign
import GSL.Wrappers(mkfun)

derivGen ::
    Int                   -- ^ type: 0 central, 1 forward, 2 backward
    -> Double             -- ^ initial step size
    -> (Double -> Double) -- ^ function
    -> Double             -- ^ point where the derivative is taken
    -> (Double, Double)   -- ^ result and error
derivGen c h f x = unsafePerformIO $ do
    r <- malloc
    e <- malloc
    fp <- mkfun (\x _ -> f x) 
    c_deriv c fp x h r e
    vr <- peek r
    ve <- peek e
    let result = (vr,ve)
    free r
    free e
    freeHaskellFunPtr fp
    return result

foreign import ccall "gslaux.h deriv" 
 c_deriv :: Int -> FunPtr (Double -> Ptr () -> Double) -> Double -> Double 
                    -> Ptr Double -> Ptr Double -> IO Int


{- | Adaptive central difference algorithm, /gsl_deriv_central/. For example:

> > let deriv = derivCentral 0.01 
> > deriv sin (pi/4)
>(0.7071067812000676,1.0600063101654055e-10)
> > cos (pi/4)
>0.7071067811865476 

-}
derivCentral :: Double                  -- ^ initial step size
                -> (Double -> Double)   -- ^ function 
                -> Double               -- ^ point where the derivative is taken
                -> (Double, Double)     -- ^ result and absolute error
derivCentral = derivGen 0

-- | Adaptive forward difference algorithm, /gsl_deriv_forward/. The function is evaluated only at points greater than x, and never at x itself. The derivative is returned in result and an estimate of its absolute error is returned in abserr. This function should be used if f(x) has a discontinuity at x, or is undefined for values less than x. A backward derivative can be obtained using a negative step.
derivForward :: Double                  -- ^ initial step size
                -> (Double -> Double)   -- ^ function 
                -> Double               -- ^ point where the derivative is taken
                -> (Double, Double)     -- ^ result and absolute error
derivForward = derivGen 1

-- | Adaptive backward difference algorithm, /gsl_deriv_backward/. 
derivBackward ::Double                  -- ^ initial step size
                -> (Double -> Double)   -- ^ function 
                -> Double               -- ^ point where the derivative is taken
                -> (Double, Double)     -- ^ result and absolute error
derivBackward = derivGen 2
