{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
{-# LANGUAGE FlexibleContexts #-}

module Vision.Epipolar(
    Epi(..), EpiPairs,
    mkEpiObs
) where

import Vision.Types
import Numeric.LinearAlgebra.HMatrix
import Util.Misc(Mat,Vec,vec)
import Vision.Stereo
import Util.Homogeneous
import Util.Estimation
import Vision.Camera

-- compute M^
getPairs :: Projections Calibrated
    -> Int
    -> Int
    -> Maybe (Matrix Double,[Int])
getPairs s i j | null ks = Nothing
               | otherwise = Just (compact 9 $ outf (fromRows p) (fromRows q), ks)
    where ks = commonPoints s [i,j]
          f k = (ako s (k,i), ako s (k, j))
          (p,q) = unzip $ map f ks

          outf a b = fromColumns [ u*v |  u<-us, v<-vs ]
            where us = toColumns a
                  vs = toColumns b

          --compact x = if rows x < 9 then x else takeRows 9 $ snd $ qr x

-- more info about a view pair
data Epi = Epi { m_hat :: Mat,
                 com  :: [Int], -- index of common points
                 esen :: Mat,
                 nEpi :: Int,   -- lenght of com
                 s2 :: Double,
                 s7 :: Double,
                 p_homog :: Mat,    -- planar homography
                 h_err :: Double,   -- its error
                 rot :: Maybe Mat,  -- promising rotation
                 reco :: Maybe ([Mat],[Vec]) -- pairwise initial reconstruction
                 }

type EpiPairs = [((Int,Int),Epi)]

prepEpi :: Projections Calibrated -> ((Int, Int), (Mat,[Int])) -> ((Int, Int), Epi)
prepEpi s ((i,j),(m,ks)) = ((i,j),
    Epi { m_hat = m,
          com = ks,
          esen = e,
          nEpi = length ks,
          s2 = fst (qEssen e),
          s7 = sumElements (subVector 6 3 sm) / sumElements (subVector 0 6 sm),
          p_homog = h, h_err = he,
          rot = mbrot,
          reco = initrec } ) where
    ebad = linearEssen m
    ps  = map (\k-> toList $ inHomog $ ako s (k,i)) ks
    ps' = map (\k-> toList $ inHomog $ ako s (k,j)) ks
    egood = tr $ estimateFundamental ps ps'
    h = estimateHomography ps ps'
    he = sqrt $ norm_Frob (fromLists ps - fromLists (ht h ps')) ** 2 / fromIntegral (length ks)
    e = if length ks > 8 then egood else ebad
    sm = singularValues m
    mbrot = rotOfCam `fmap` m'
    ms = camerasFromEssential e
    m0 = cameraAtOrigin
    m' = selectCamera' (head ps) (head ps') m0 ms
    initrec = (\cam -> ([m0,cam], map (homog.vec) $ triangulate [(m0,ps),(cam,ps')])) `fmap` m'

-- compute the essential matrix of the pair
-- from the reduced measurement matrix M^
linearEssen :: Mat -> Mat
linearEssen = tr . reshape 3 . last . toColumns . snd . rightSV


mkEpiObs :: Projections Calibrated -> EpiPairs
mkEpiObs s = [ prepEpi s (ij, p) | (ij,Just p) <- obs]
    where obs = [((i,j), getPairs s i j) | i <- [0 .. nCam s -2], j <- [i+1 .. nCam s -1]]

----------------------------------------------------------------------

