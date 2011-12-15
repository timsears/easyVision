-----------------------------------------------------------------------------
{- |
Module      :  Contours.Base
Copyright   :  (c) Alberto Ruiz 2007-11
License     :  GPL

Maintainer  :  Alberto Ruiz (aruiz at um dot es)
Stability   :  provisional

Basic operations with polylines.

-}
-----------------------------------------------------------------------------

module Contours.Base (
-- * Reduction
    douglasPeucker, douglasPeuckerClosed,
    selectPolygons, cleanPol,
-- * Convex Hull
    convexHull,
-- * Tools
    perimeter,
    area, orientedArea, rev,
    asSegments, longestSegments, transPol,
    pentominos,
    bounding,
    roi2poly, poly2roi
)
where

import ImagProc.Base
import Data.List(sortBy, maximumBy, sort,foldl',tails)
import Numeric.LinearAlgebra
import Util.Homogeneous
import Util.Misc(diagl)



-- | (for an open polyline is the length)
perimeter :: Polyline -> Double
perimeter (Open l) = perimeter' l
perimeter (Closed l) = perimeter' (last l:l)

perimeter' [_] = 0
perimeter' (a:b:rest) = distPoints a b + perimeter' (b:rest)

area :: Polyline -> Double
area = abs . orientedArea

-- | Oriented area of a closed polyline. The clockwise sense is positive in the x-y world frame (\"floor\",z=0) and negative in the camera frame.
orientedArea :: Polyline -> Double
orientedArea (Open _) = error "undefined orientation of open polyline"
orientedArea (Closed l) = -0.5 * orientation' (last l:l)

orientation' [_] = 0
orientation' (Point x1 y1:r@(Point x2 y2:_)) = x1*y2-x2*y1 + orientation' r

rev (Closed ps) = Closed (reverse ps)
rev (Open ps) = Open (reverse ps)

----------------------------------------------------------------------

-- | Removes nodes in closed polyline such that the orthogonal distance 
--   from the remaining line is less than a given epsilon
douglasPeuckerClosed :: Double -> [Pixel] -> [Pixel]
douglasPeuckerClosed eps (a:b:ls) = b : case criticalPoint (eps^2) b a ls of
    Nothing -> [b]
    Just c  -> left ++ right where
        (l,_:r) = break (==c) ls
        left = douglasPeucker' (eps^2) b c l
        right = douglasPeucker' (eps^2) c a r

-- | Removes nodes in an open polyline such that the orthogonal distance 
--   from the remaining line is less than a given epsilon
douglasPeucker :: Double -> [Pixel] -> [Pixel]
douglasPeucker eps list = a: douglasPeucker' (eps^2) a b list
    where a = head list
          b = last list

douglasPeucker' eps2 a b ls = case criticalPoint eps2 a b ls of
    Nothing -> [b]
    Just c  -> left ++ right where
        (l,_:r) = break (==c) ls
        left = douglasPeucker' eps2 a c l
        right = douglasPeucker' eps2 c b r

perpDistAux :: Int -> Int -> Double -> Int -> Int -> Int -> Int -> Double
perpDistAux lx ly l2 x1 y1 x3 y3 = d2 where
    d2 = p2 - a'*a'/l2
    p2   = fromIntegral $ px*px + py*py
    px   = x3-x1
    py   = y3-y1
    a'   = fromIntegral $ lx*px+ly*py

perpDist (Pixel x1 y1) (Pixel x2 y2) = (f,l2) where
    lx = x2-x1
    ly = y2-y1
    l2 = fromIntegral $ lx*lx+ly*ly
    f (Pixel x3 y3) = perpDistAux lx ly l2 x1 y1 x3 y3

on f g = \x y -> f (g x) (g y)

criticalPoint eps p1 p2 [] = Nothing

criticalPoint eps2 p1 p2 p3s = r where
    (f,l2) = perpDist p1 p2
    p3 = maximumBy (compare `on` f) p3s
    r = if f p3 > eps2
        then Just p3
        else Nothing

----------------------------------------------------------------------

asSegments :: Polyline -> [Segment]
asSegments (Open ps') = zipWith Segment ps' (tail ps')
asSegments (Closed ps) = asSegments $ Open $ ps++[head ps]

----------------------------------------------------------------------

transPol t (Closed ps) = Closed $ map l2p $ ht t (map p2l ps)
transPol t (Open ps)   = Open   $ map l2p $ ht t (map p2l ps)

p2l (Point x y) = [x,y]
l2p [x,y] = Point x y

----------------------------------------------------------

cang p1@(Point x1 y1) p2@(Point x2 y2) p3@(Point x3 y3) = c
  where
    dx1 = (x2-x1)
    dy1 = (y2-y1)
    
    dx2 = (x3-x2)
    dy2 = (y3-y2)
    
    l1 = sqrt (dx1**2 + dy1**2)
    l2 = sqrt (dx2**2 + dy2**2)

    c = (dx1*dx2 + dy1*dy2) / l1 / l2

areaTriang p1 p2 p3 = sqrt $ p * (p-d1) * (p-d2) * (p-d3)
  where
    d1 = distPoints p1 p2
    d2 = distPoints p1 p3
    d3 = distPoints p2 p3
    p = (d1+d2+d3)/2

----------------------------------------------------------------------

cleanPol tol (Closed ps) = Closed r
  where
    n = length ps
    r = map snd . filter ((<tol).abs.fst) . map go . take n . tails $ ps++ps
    go (p1:p2:p3:_) = (cang p1 p2 p3, p2)

longestSegments k poly = filter ok ss
    where ss = asSegments poly
          th = last $ take k $ sort $ map (negate.segmentLength) ss
          ok s = segmentLength s >= -th

reducePolygonTo n poly = Closed $ segsToPoints $ longestSegments n poly


segsToPoints p = stp $ map segToHomogLine $ p ++ [head p]
  where
    segToHomogLine s = cross (fromList [px $ extreme1 $ s, py $ extreme1 $ s, 1])
                             (fromList [px $ extreme2 $ s, py $ extreme2 $ s, 1])

    stp [] = []
    stp [_] = []
    stp (a:b:rest) = inter a b : stp (b:rest)

    inter l1 l2 = Point x y where [x,y] = toList $ inHomog (cross l1 l2)

tryPolygon eps n poly = if length (polyPts r) == n && abs((a1-a2)/a1) < eps && ok then [r] else []
    where r = reducePolygonTo n poly
          a1 = orientedArea poly
          a2 = orientedArea r
          p = perimeter r
          l = minimum $ map segmentLength (asSegments r)
          ok = l > p / fromIntegral n / 10

selectPolygons eps n = concatMap (tryPolygon eps n)

----------------------------------------------------------------------

flipx = transPol (diagl[-1,1,1])

pentominos :: [(Polyline,String)]
pentominos =
    [ (Closed $ reverse [Point 0 0, Point 0 1, Point 5 1, Point 5 0], "I")
    , (flipx $ Closed $ [Point 0 0, Point 0 1, Point 3 1, Point 3 2, Point 4 2, Point 4 0], "L")
    , (Closed $ reverse [Point 0 0, Point 0 1, Point 3 1, Point 3 2, Point 4 2, Point 4 0], "J")
    , (Closed $ reverse [Point 1 0, Point 1 1, Point 0 1, Point 0 2, Point 1 2, Point 1 3,
                         Point 2 3, Point 2 2, Point 3 2, Point 3 1, Point 2 1, Point 2 0], "X")
    , (Closed $ reverse [Point 0 0, Point 0 3, Point 1 3, Point 1 1, Point 3 1, Point 3 0], "V")
    , (Closed $ reverse [Point 0 0, Point 0 1, Point 1 1, Point 1 3, Point 2 3, Point 2 1, Point 3 1, Point 3 0], "T")
    , (flipx $ Closed $ [Point 0 0, Point 0 3, Point 2 3, Point 2 1, Point 1 1, Point 1 0], "P")
    , (Closed $ reverse [Point 0 0, Point 0 3, Point 2 3, Point 2 1, Point 1 1, Point 1 0], "B")
    , (flipx $ Closed $ [Point 0 2, Point 0 3, Point 2 3, Point 2 1, Point 3 1, Point 3 0, Point 1 0, Point 1 2], "Z")
    , (Closed $ reverse [Point 0 2, Point 0 3, Point 2 3, Point 2 1, Point 3 1, Point 3 0, Point 1 0, Point 1 2], "S")
    , (Closed $ reverse [Point 0 0, Point 0 2, Point 1 2, Point 1 1, Point 2 1, Point 2 2, Point 3 2, Point 3 0], "U")
    , (flipx $ Closed $ [Point 0 0, Point 0 1, Point 2 1, Point 2 2, Point 3 2, Point 3 1, Point 4 1, Point 4 0], "Y")
    , (Closed $ reverse [Point 0 0, Point 0 1, Point 2 1, Point 2 2, Point 3 2, Point 3 1, Point 4 1, Point 4 0], "Y'")
    , (flipx $ Closed $ [Point 0 1, Point 0 3, Point 1 3, Point 1 2, Point 3 2, Point 3 1,
                         Point 2 1, Point 2 0, Point 1 0, Point 1 1], "F")
    , (Closed $ reverse [Point 0 1, Point 0 3, Point 1 3, Point 1 2, Point 3 2, Point 3 1,
                         Point 2 1, Point 2 0, Point 1 0, Point 1 1], "Q")
    , (flipx $ Closed $ [Point 0 1, Point 0 2, Point 2 2, Point 2 1, Point 4 1, Point 4 0, Point 1 0, Point 1 1], "N")
    , (Closed $ reverse [Point 0 1, Point 0 2, Point 2 2, Point 2 1, Point 4 1, Point 4 0, Point 1 0, Point 1 1], "N'")
    , (Closed $ reverse [Point 0 1, Point 0 3, Point 1 3, Point 1 2, Point 2 2, Point 2 1,
                         Point 3 1, Point 3 0, Point 1 0, Point 1 1], "W")    
    ]

----------------------------------------------------------------------

convexHull :: [Point] -> [Point]
convexHull ps = go [q0] rs
  where
    q0:qs = sortBy (compare `on` (\(Point x y) -> (y,x))) ps
    rs = sortBy (compare `on` (ncosangle q0)) qs

    go [p] [x,q]                     = [p,x,q]
    go [p] (x:q:r)   | isLeft p x q  = go [x,p] (q:r)
                     | otherwise     = go [p]   (q:r)
    go (p:c) [x]     | isLeft p x q0 = x:p:c
                     | otherwise     =   p:c
    go (p:c) (x:q:r) | isLeft p x q  = go (x:p:c)   (q:r)
                     | otherwise     = go c       (p:q:r)
    
    ncosangle p1@(Point x1 y1) p2@(Point x2 y2) = (x1-x2) / distPoints p1 p2

    isLeft p1@(Point x1 y1) p2@(Point x2 y2) p3@(Point x3 y3) = 
        (x2 - x1)*(y3 - y1) - (y2 - y1)*(x3 - x1) > 0

----------------------------------------------------------------------

bounding :: Polyline -> Polyline
bounding p = Closed [Point x2 y2, Point x1 y2, Point x1 y1, Point x2 y1] 
  where
    x1 = minimum xs
    x2 = maximum xs
    y1 = minimum ys
    y2 = maximum ys
    xs = map px (polyPts p)
    ys = map py (polyPts p)

roi2poly :: Size -> ROI -> Polyline
roi2poly sz (ROI r1 r2 c1 c2) = Closed $ pixelsToPoints sz p
  where
    p = [Pixel r1 c1, Pixel r1 c2, Pixel r2 c2, Pixel r2 c1]

poly2roi :: Size -> Polyline -> ROI
poly2roi sz p = ROI r1 r2 c1 c2
  where
    (Closed [p1,_,p3,_]) = bounding p
    [Pixel r1 c1, Pixel r2 c2] = pointsToPixels sz [p1,p3]

