{-# OPTIONS  #-}
-----------------------------------------------------------------------------
{- |
Module      :  GSL.LinearAlgebra.Algorithms
Copyright   :  (c) Alberto Ruiz 2006
License     :  GPL-style

Maintainer  :  Alberto Ruiz (aruiz at um dot es)
Stability   :  provisional
Portability :  uses ffi

Some linear algebra algorithms, implemented by means of BLAS, LAPACK or GSL.

(In construction...)

-}
-----------------------------------------------------------------------------
module GSL.LinearAlgebra.Algorithms (
    -- * Basic linear algebra
    -- | The operators of the numeric instances of 'Vector' and 'Matrix' are defined element by element.
    (<>), mXm, mXv, vXm, dot, outer, scale, --add,
    -- * Linear Systems
    luSolveR, luSolveC, inv, pinv, pinvTol, det, 
    -- * Matrix factorizations
    -- ** Eigensystems
    eigR,
    eigS,
    eigSg,
    eigC,
    eigH,
    eigHg,
    -- ** Singular value decomposition
    svdg,
    svdR, svdR',
    full_svd_Rd,
    svdC, svdC',
    -- ** QR
    qr,
    -- ** Cholesky
    chol,
    -- ** LU
    luR,
    luC,
    -- * Utilities
     pnorm, norm
) where

import Complex
import GSL.LinearAlgebra.Vector
import GSL.LinearAlgebra.Matrix
import GSL.Common
import GSL.Wrappers
import GSL.Instances
import GSL.Lapack

------------------------------------------------------------------------------

{- | Pseudoinverse of a real matrix with the default tolerance used by GNU-Octave: the singular values less than max (rows, colums) * greatest singular value * 'eps' are ignored. See 'pinvTol'.

@\> let m = 'fromLists' [[ 1, 2]
                     ,[ 5, 8]
                     ,[10,-5]]
\> pinv m
9.353e-3 4.539e-2  7.637e-2
2.231e-2 8.993e-2 -4.719e-2
\ 
\> m \<\> pinv m \<\> m
 1.  2.
 5.  8.
10. -5.@

-}
pinv :: Matrix Double -> Matrix Double
pinv m = pinvTol 1 m

{- | Pseudoinverse of a real matrix with the desired tolerance, expressed as a
multiplicative factor of the default tolerance used by GNU-Octave (see 'pinv').

@\> let m = 'fromLists' [[1,0,    0]
                     ,[0,1,    0]
                     ,[0,0,1e-10]]
\ 
\> 'pinv' m 
1. 0.           0.
0. 1.           0.
0. 0. 10000000000.
\ 
\> pinvTol 1E8 m
1. 0. 0.
0. 1. 0.
0. 0. 1.@

-}
pinvTol :: Double -> Matrix Double -> Matrix Double
pinvTol t m = v `mXm` diag s' `mXm` trans u where
    (u,s,v) = svdg m
    sl@(g:_) = toList s
    s' = fromList . map rec $ sl
    rec x = if x < g*tol then 1 else 1/x
    tol = (fromIntegral (max (rows m) (cols m)) * g * t * eps)



{- | Outer product of two vectors.

@\> 'fromList' [1,2,3] \`outer\` 'fromList' [7,0,2*'i',1+'i']
matrix (3x4) [7.0 :+ 0.0,0.0 :+ 0.0,0.0 :+ 2.0,1.0 :+ 1.0,14.0 :+ 0.0,0.0 :+ 0.0,0.0 :+
4.0,2.0 :+ 2.0,21.0 :+ 0.0,0.0 :+ 0.0,0.0 :+ 6.0,3.0 :+ 3.0]
\> dispC 2 it
matrix (3x4)
 7. | 0. | 2.i | 1.+1.i
14. | 0. | 4.i | 2.+2.i
21. | 0. | 6.i | 3.+3.i@

-}
outer :: Field a => Vector a -> Vector a -> Matrix a
outer u v = reshape 1 u `mXm` reshape (size v) v


{- | Inverse of a square matrix (shortcut for m \<\\> 'ident' ('rows' m)).

@\>inv ('fromLists' [[1,4]
                 ,[0,2]])
1.   -2.
0. 0.500@
-}
inv :: Matrix Double -> Matrix Double
inv m = if rows m == cols m
    then m `luSolveR` ident (rows m)
    else error "inv of nonsquare matrix"


{- | Shortcut for the 2-norm ('pnorm' 2)

@ > norm $ 'hilb' 5
1.5670506910982311
@

@\> norm $ 'fromList' [1,-1,'i',-'i']
2.0@

-}

norm x = pnorm 2 x

----------------------------------------------------------------

{- | The LU decomposition of a square matrix. Is based on /gsl_linalg_LU_decomp/ and  /gsl_linalg_complex_LU_decomp/ as described in <http://www.gnu.org/software/gsl/manual/gsl-ref_13.html#SEC223>.

@\> let m = 'fromLists' [[1,2,-3],[2+3*'i',-7,0],[1,-'i',2*'i']]
\> let (l,u,p,s) = luR m@

L is the lower triangular:

@\> l
          1.            0.  0.
0.154-0.231i            1.  0.
0.154-0.231i  0.624-0.522i  1.@

U is the upper triangular:

@\> u
2.+3.i           -7.            0.
    0.  3.077-1.615i           -3.
    0.            0.  1.873+0.433i@

p is a permutation:

@\> p
[1,0,2]@

L \* U obtains a permuted version of the original matrix:

@\> 'extractRows' p m
  2.+3.i   -7.   0.
      1.    2.  -3.
      1.  -1.i  2.i
\ 
\> l \<\> u
 2.+3.i   -7.   0.
     1.    2.  -3.
     1.  -1.i  2.i@

s is the sign of the permutation, required to obtain sign of the determinant:

@\> s * product ('toList' $ 'takeDiag' u)
(-18.0) :+ (-16.000000000000004)
\> 'det' m
(-18.0) :+ (-16.000000000000004)@

 -}
luR :: Matrix Double -> (Matrix Double, Matrix Double, [Int], Double)
luR m = (l,u,p, fromIntegral s') where
    r = rows m
    v = luRaux m
    lu = reshape r $ subVector 0 (r*r) v
    s':p = map round . toList . subVector (r*r) (r+1) $ v 
    u = triang r r 0 1 * lu
    l = triang r r 0 0 * lu + ident r

-- | Complex version of 'luR'.
luC :: Matrix (Complex Double) -> (Matrix (Complex Double), Matrix (Complex Double), [Int], Complex Double)
luC m = (l,u,p, fromIntegral s') where
    r = rows m
    v = luCaux m
    lu = reshape r $ subVector 0 (r*r) v
    s':p = map (round.realPart) . toList . subVector (r*r) (r+1) $ v 
    u = complex (triang r r 0 1) * lu
    l = complex (triang r r 0 0) * lu + complex (ident r)

{- | Determinant of a square matrix, computed from the 'lu' decomposition.

@\> det ('fromLists' [[7,2],[3,8]])
50.0@

-}
det :: Matrix Double -> Double
det m = s * (product $ toList $ takeDiag $ u)
    where (_,u,_,s) = luR m