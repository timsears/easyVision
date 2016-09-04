{-# LANGUAGE FlexibleContexts #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Util.Ellipses
-- Copyright   :  (c) Alberto Ruiz 2008-12
-- License     :  GPL
--
-- Maintainer  :  Alberto Ruiz <aruiz@um.es>
-- Stability   :  provisional
--
-- Useful functions for ellipses.
--
-----------------------------------------------------------------------------

module Util.Ellipses (
    -- * Ellipses
    InfoEllipse(..), analyzeEllipse,
    intersectionEllipses,
    tangentEllipses,
    estimateConicRaw,
    conicPoints,
    -- * Conics
    computeConic,
    fromUnitCircle,
    pointsConic,
    circle,
    intersectionConicLine
) where

import Numeric.LinearAlgebra.HMatrix
import Numeric.GSL.Polynomials
import Util.Homogeneous
import Util.Misc(mat,Mat)
import Util.Debug(impossible)
import Util.Estimation(homogSolve)
import Util.Rotation(rot3)
import Util.Geometry as G

--------------------------------------------------------------------

estimateConicRaw ::  [Point] -> Mat
estimateConicRaw ps = con where
    con = (3><3) [a,c,d
                 ,c,b,e
                 ,d,e,f]
    (s,_err) = homogSolve (mat eqs)
    [a,b,c,d,e,f] = toList s
    eqs = map eq ps
    eq (Point x y) = [x*x, y*y, 2*x*y, 2*x, 2*y, 1.0]

-- FIXME : work con whitened data
computeConic :: [Point] -> Conic
computeConic = unsafeFromMatrix . estimateConicRaw

(@@>) :: Mat -> (Int,Int) -> Double
(@@>) = atIndex

mt :: Mat -> Mat
mt = inv . tr

--------------------------------------------------------------------

data InfoEllipse = InfoEllipse {
    conicCenter :: (Double,Double),
    conicSizes  :: (Double,Double),
    conicAngle  :: Double,
    conicMatrix :: Mat,
    conicTrans  :: Mat }

analyzeEllipse :: Mat -> InfoEllipse
analyzeEllipse m = InfoEllipse {
    conicCenter = (mx,my),
    conicSizes  = (dx,dy),
    conicAngle  = alpha,
    conicMatrix = m,
    conicTrans  = t }
  where 
    a = m@@>(0,0)
    b = m@@>(1,1)
    c = m@@>(0,1)
    phi = 0.5 * atan2 (2*c) (b-a)
    t1 = rot3 (-phi)
    m1 = t1 <> m <> tr t1
    a' = m1@@>(0,0)
    b' = m1@@>(1,1)
    t2 = diagl [sqrt (abs $ a'/b'), 1,1]
    -- abs is necessary for projective reduceConics
    m2' = mt t2 <> m1 <> inv t2
    m2 = m2' / scalar (m2'@@>(0,0))
    d'' = m2@@>(0,2)
    e'' = m2@@>(1,2)
    f'' = m2@@>(2,2)
    sc  = sqrt (d''**2 + e''**2 - f'')
    t3 = scaling (1/sc) <> desp (d'',e'')
    t = t3 <> t2 <> t1
    --m3 = mt t <> m <> inv t
    [mx,my,_] = toList (inv t #> fromList [0,0,1])
    [sx,sy,_] = toList $ sc `scale` (1 / takeDiag t2)
    (dx,dy,alpha) = if sx > sy
        then (sx,sy,-phi)
        else (sy,sx,-phi-pi/2)

-- | moves two ellipses to reduced form for easy intersection
-- | projective version, required for dual conics (tangents)
reduceConics :: Mat -> Mat -> (Mat, Mat)
reduceConics c1 c2 = (w, c2') where
    (s,v) = eigSH' c1
    sg = signum s
    p = (if sg!1 < 0 then flipud else id) (ident 3)
    w1 = mt $ p <> diag (sg / sqrt (abs s)) <> tr v
    InfoEllipse {conicCenter = (mx,my), conicAngle = a} = analyzeEllipse (mt w1 <> c2 <> inv w1)
    w2 = chooseRot mx my a
    w = w2 <> w1
    c2' = mt w <> c2 <> inv w

{-
-- | affine version
reduceConics' :: Mat -> Mat -> (Mat, Mat)
reduceConics' c1 c2 = (w, c2') where
    w1 = snd $ analyzeEllipse c1
    (mx,my,_,_,a) = fst $ analyzeEllipse (mt w1 <> c2 <> inv w1)
    w2 = chooseRot mx my a
    w = w2 <> w1
    c2' = mt w <> c2 <> inv w
-}

chooseRot :: Double -> Double -> Double -> Mat
chooseRot mx my a = w where
    v = fromList [mx,my,1]
    [mx',my',_] = toList $ rot3 a #> v
    w = if abs mx' > abs my'
        then rot3 a
        else rot3 (a+pi/2)

--------------------------------------------------------------------

-- | coefficients in
-- ax^2 + by^2 + x + ey + f
-- (not the entry in the conic matrix)
getCoeffs :: Mat -> (Double, Double, Double, Double)
getCoeffs m' = (a,b,e,f) where
    m = m' / scalar (2*m'@@>(0,2))
    a = m @@> (0,0)
    b = m @@> (1,1)
    f = m @@> (2,2)
    e = m @@> (1,2) * 2

-- | Intersection of two ellipses (after common diagonalization)
-- (based on the idea of elimination of the x^2coefficient in vgl : Geometry Library)
intersectionReduced :: (Double,Double,Double,Double) -> [[Complex Double]]
intersectionReduced prob = map sol (polySolve (coefs prob)) where
    sol y = [x,y] where x = thex prob y

    coefs (a,b,e,f) =
        [ -1 + a*a + 2*a*f + f*f
        , 2*a*e + 2*e*f
        , 1 - 2*a*a + 2*a*b + e*e - 2*a*f + 2*b*f 
        , -2*a*e + 2*b*e
        , a*a - 2*a*b + b*b]

    thex (a',b',e',f') y = -a-f - e*y + (a-b)*y*y
        where a = a':+0
              b = b':+0
              e = e':+0
              f = f':+0

intersectionCommonCenter :: (Complex Double,Complex Double) -> [[Complex Double]]
intersectionCommonCenter (a,b) = [s1,s2,s3,s4] where
    p = sqrt $ (b+1)/(b-a)
    q = sqrt $ (-1-a)/(b-a)
    s1 = [-p,-q]
    s2 = [-p, q]
    s3 = [ p,-q]
    s4 = [ p, q]

intersectionEllipses :: Mat-> Mat -> [(Complex Double, Complex Double)]
intersectionEllipses c1 c2 = map l2t sol where
    (w, c2') = reduceConics c1 c2
    a = c2'@@>(0,0)
    b = c2'@@>(1,1)
    f = c2'@@>(2,2)
    d = c2'@@>(0,2)
    sol = if abs(d/a) > 1E-6
        then htc (complex $ inv w) $ intersectionReduced (getCoeffs c2')
        else htc (complex $ inv w) $ intersectionCommonCenter ((a/f):+0,(b/f):+0)
    l2t [x,y] = (x,y)
    l2t _ = impossible "l2t"


tangentEllipses :: Mat-> Mat -> [[Complex Double]]
tangentEllipses c1 c2 = map t2l $ intersectionEllipses (inv c1) (inv c2)
  where t2l (a,b) = [a,b,1]


conicPoints :: Int -> InfoEllipse -> [Point]
conicPoints n InfoEllipse {conicCenter = (mx,my), conicSizes = (d1,d2), conicAngle = a} = xs where
    xs = map pt ts
    ts = tail $ toList $ linspace n (0,2*pi)
    pt t = Point (mx + x*cos a - y*sin a) (my + x*sin a + y*cos a)
        where x = d1*cos t
              y = d2*sin t

--------------------------------------------------------------------------------

circle :: Int -> Double -> Point -> [Point]
circle n r (Point x y) = [ Point (x+r*cos t) (y+r*sin t) | t <- tail $ toList $ linspace (n+1) (0,2*pi) ]

pointsConic :: Int -> Conic -> [Point]
pointsConic n c = fromUnitCircle c <| circle n 1 (Point 0 0)

fromUnitCircle :: Conic -> Homography
fromUnitCircle c = h
  where
    (l,v) = eigSH (trustSym . f . toMatrix $ c)
    f m = m * scalar (signum (-det m))
    h = unsafeFromMatrix $ v <> diag (recip $ sqrt $ abs $ l)


intersectionConicLine :: Conic -> HLine -> [HPoint]
intersectionConicLine c l = h ⊙ r <| ss
  where
    h = fromUnitCircle c
    l' = invTrans h <| l
    f = closestToLine (HPoint 0 0 1) l'
    (Point x y) = inhomog f
    ang = atan2 y x
    r = unsafeFromMatrix (rot3 (-ang)) :: Homography
    d = distPoints (Point 0 0) (Point x y)
    ss = if d > 1 then [] else [HPoint d v 1, HPoint d (-v) 1]
    v = sqrt (1 - d*d)
    
    dirNormal (HLine a b _c) = HPoint a b 0

    closestToLine p m = G.gjoin p (dirNormal m) `meet` m

