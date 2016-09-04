-----------------------------------------------------------------------------
{- |
Module      :  Contours.Orientation
Copyright   :  (c) Alberto Ruiz 2007-11
License     :  GPL

Maintainer  :  Alberto Ruiz (aruiz at um dot es)
Stability   :  provisional

K orientation experiments.

-}
-----------------------------------------------------------------------------

module Contours.Orientation (
    icaAngles, anglesKurt,
    kurtCoefs, kurtAlpha, kurtosisX,
    skewX
)
where

import Contours.Base(Segment(..),asSegments)
import Data.List(sortBy, foldl')
import Data.Complex(realPart,imagPart)
import Util.Geometry(Point(..),Polyline(..))
import Util.Misc(degree)
import Numeric.GSL.Polynomials(polySolve)
import Data.Function(on)
import Control.Arrow((&&&))


auxKurt :: Double -> Segment -> Double
auxKurt k (Segment (Point x1 y1) (Point x2 y2)) =
     k + (x1**4*x2*(y1 - y2) + 
          x1**3*x2**2*
           (y1 - y2) + 
          x1**2*x2**3*
           (y1 - y2) + 
          x1*x2**4*
           (y1 - y2) - 
          x1**5*(2*y1 + y2) + 
          x2**5*(y1 + 2*y2))
       / 30

kurtosisX :: Polyline -> Double
kurtosisX p = foldl' auxKurt 0 (asSegments p) 

----------------------------------------------------------------------

kC :: Int -> Segment -> Double
kC 0 (Segment (Point x1 y1) (Point x2 y2)) =
    ((2*x1 + x2)*y1**5 + 
    (-x1 + x2)*y1**4*y2 + 
    (-x1 + x2)*y1**3*y2**2 + 
    (-x1 + x2)*y1**2*y2**3 + 
    (-x1 + x2)*y1*y2**4 - 
    (x1 + 2*x2)*y2**5)/30

kC 1 (Segment (Point x1 y1) (Point x2 y2)) =
   (-2*y1**6 + 2*y2**6 + 
    x1**2*(y1 - y2)*
     (10*y1**3 + 
       6*y1**2*y2 + 
       3*y1*y2**2 + 
       y2**3) + 
    x2**2*(y1 - y2)*
     (y1**3 + 
       3*y1**2*y2 + 
       6*y1*y2**2 + 
       10*y2**3) + 
    2*x1*x2*
     (2*y1**4 + 
       y1**3*y2 - 
       y1*y2**3 - 
       2*y2**4))/30

kC 2 (Segment (Point x1 y1) (Point x2 y2)) =
    (y1**3*
     (20*x1**3 + 
       6*x1**2*x2 + 
       3*x1*x2**2 + 
       x2**3 - 
       10*x1*y1**2 + 
       x2*y1**2) - 
    (x1 - x2)*y1**2*
     (6*x1**2 + 
       6*x1*x2 + 
       3*x2**2 + y1**2)*
     y2 - 
    (x1 - x2)*y1*
     (3*x1**2 + 
       6*x1*x2 + 
       6*x2**2 + y1**2)*
     y2**2 - 
    (x1**3 + 
       3*x1**2*x2 + 
       6*x1*x2**2 + 
       20*x2**3 + 
       (x1 - x2)*y1**2)*
     y2**3 + 
    (-x1 + x2)*y1*
     y2**4 - 
    (x1 - 10*x2)*y2**5)/30

kC 3 (Segment (Point x1 y1) (Point x2 y2)) = 
    (2*x1**3*x2*(y1 - y2)*
     (2*y1 + y2) + 
    x1**4*
     (20*y1**2 - 
       4*y1*y2 - y2**2)
     + x1**2*
     (3*x2**2*y1**2 - 
       20*y1**4 - 
       4*y1**3*y2 - 
       3*
        (x2**2 + y1**2)*
        y2**2 - 
       2*y1*y2**3 - 
       y2**4) + 
    x2**2*
     (y1**4 + 
       2*y1**3*y2 + 
       3*y1**2*y2**2 + 
       4*y1*y2**3 + 
       20*y2**4 + 
       x2**2*
        (y1**2 + 
          4*y1*y2 - 
          20*y2**2)) + 
    2*x1*x2*(y1 - y2)*
     (x2**2*
        (y1 + 2*y2) + 
       (y1 + y2)*
        (2*y1**2 + 
          y1*y2 + 
          2*y2**2)))/30 
   
kC 4 (Segment (Point x1 y1) (Point x2 y2)) =    
   (x1**4*x2*(y1 - y2) + 
    x1**5*
     (10*y1 - y2) + 
    x1**2*x2*(y1 - y2)*
     (x2**2 + 6*y1**2 + 
       6*y1*y2 + 3*y2**2
       ) + 
    x1*x2**2*(y1 - y2)*
     (x2**2 + 3*y1**2 + 
       6*y1*y2 + 6*y2**2
       ) + 
    x1**3*
     (x2**2*y1 - 
       20*y1**3 - 
       x2**2*y2 - 
       6*y1**2*y2 - 
       3*y1*y2**2 - 
       y2**3) + 
    x2**3*
     (y1**3 + 
       x2**2*
        (y1 - 10*y2) + 
       3*y1**2*y2 + 
       6*y1*y2**2 + 
       20*y2**3))/30

kC 5 (Segment (Point x1 y1) (Point x2 y2)) =
    (2*x1**6 + 
    2*x1**3*x2*
     (y1 - y2)*
     (2*y1 + y2) + 
    2*x1*x2**3*
     (y1 - y2)*
     (y1 + 2*y2) + 
    3*x1**2*x2**2*
     (y1**2 - y2**2) - 
    x1**4*
     (10*y1**2 + 
       4*y1*y2 + y2**2)
     + x2**4*
     (-2*x2**2 + 
       y1**2 + 
       4*y1*y2 + 
       10*y2**2))/30

kC 6 (Segment (Point x1 y1) (Point x2 y2)) =
    (x1**4*x2*(y1 - y2) + 
    x1**3*x2**2*
     (y1 - y2) + 
    x1**2*x2**3*
     (y1 - y2) + 
    x1*x2**4*
     (y1 - y2) - 
    x1**5*(2*y1 + y2) + 
    x2**5*(y1 + 2*y2))/30

kC _ _ = undefined

kurtCoefs :: Polyline -> [Double]
kurtCoefs p = foldl' f (repeat 0) (asSegments p)
  where
    f zs seg = zipWith (+) zs (map g [0..6::Int])
      where
        g k = kC k seg

cs :: Double -> [Double]
cs alpha = [cos alpha ^ k * sin alpha ^ (6-k) | k <- [0..6 :: Int]]

kurtAlpha :: [Double] -> Double -> Double
kurtAlpha coefs alpha = sum $ zipWith (*) coefs (cs alpha)

derivCoefs :: [Double] -> [Double]
derivCoefs [c0,c1,c2,c3,c4,c5,c6] =
    [       -c1
    , 6*c0-2*c2
    , 5*c1-3*c3
    , 4*c2-4*c4
    , 3*c3-5*c5
    , 2*c4-6*c6
    ,   c5      ]
derivCoefs _ = undefined

icaAngles :: Polyline -> [Double]
icaAngles = map fst . anglesKurt

anglesKurt :: Polyline -> [(Double, Double)]
anglesKurt w = sortBy (compare `on` (negate.snd)) angs
  where
    angs = map (id &&& kur)
         . (++ z)
         . map realPart
         . filter ((<(0.1*degree)).abs.imagPart)
         . map (atan.recip)
         . polySolve
         $ okdco
    
    kur = kurtAlpha coefs
    coefs = kurtCoefs w
    derco = derivCoefs coefs
    t = 1E-5 * sum (map abs derco)
    l = abs (last derco)
    (okdco,z) | l > t     = (     derco, [] )
              | otherwise = (init derco, [0])

--------------------------------------------------------------------------------

auxSkew :: Double -> Segment -> Double
auxSkew k (Segment (Point x1 y1) (Point x2 y2)) =
     k + (2*x1**3*x2*
           (y1 - y2) + 
          2*x1**2*x2**2*
           (y1 - y2) + 
          2*x1*x2**3*
           (y1 - y2) - 
          x1**4*
           (3*y1 + 2*y2) + 
          x2**4*(2*y1 + 3*y2))
         /40

skewX :: Polyline -> Double
skewX p = foldl' auxSkew 0 (asSegments p) 

