{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}

module Image.Processing.Generic(
    Pix(..),
    warp,
    resizeFull,
    constantImage,
    blockImage,
    crossCorrLoc,
    (.<.), (.>.), otsuBinarize,
    Channels(..),channelsFromRGB, channelsFromYUYV, grayscale, grayf,
    NPix(..)
) where

import Image
import Image.Devel hiding (constantImage)
import Image.Processing.IPP
import Numeric.LinearAlgebra.HMatrix(Matrix, toLists, (<>), inv, rows, cols)
import Control.Arrow((&&&))
import Foreign(Word8,Word16)
import Image.Processing.Custom(getPoints32f,getPoints8u)

class Storable p => Pix p
  where
    copy   :: Image p -> [(Image p, Pixel)]         -> Image p
    set    :: Image p -> [(ROI, p)]                 -> Image p
    resize :: Size    -> Image p                    -> Image p
    warpon :: Image p -> [(Matrix Double, Image p)] -> Image p
    crossCorr :: Image p -> Image p -> Image Float
    sqrDist   :: Image p -> Image p -> Image Float
    absDiff   :: Image p -> Image p -> Image p
    sumPixels :: Image p -> Double
    uradial :: Float -- ^ f parameter in normalized coordinates (e.g. 2.0)
            -> Float -- ^ k radial distortion (quadratic) parameter
            -> Image p -> Image p
    zeroP   :: p
    copyMask :: Image p -> Image p -> Image I8u -> Image p

{-
-- | transform an image according to a lookup table (see 'undistortMap')
    remap :: LookupMap -> InterpolationMode -> image -> image
-}

instance Pix Word8
  where
    copy    = layerImages copy8u
    set     = setROIs set8u
    resize  = selresize resize8u resize8uNN
    warpon  = warpong warpon8u
    uradial = uradialG undistortRadial8u
    crossCorr = crossCorr8u
    sqrDist = sqrDist8u
    absDiff = absDiff8u
    sumPixels = sum8u
    zeroP   = 0
    copyMask = copyMask8u
--    remap (LookupMap m) = remap8u m


instance Pix Float
  where
    copy   = layerImages copy32f
    set    = setROIs set32f
    resize = selresize resize32f resize32fNN
    warpon = warpong warpon32f
    uradial = uradialG undistortRadial32f
    crossCorr = crossCorr32f
    sqrDist = sqrDist32f
    absDiff = absDiff32f
    sumPixels = sum32f
    zeroP   = 0
    copyMask = copyMask32f
--    remap (LookupMap m) = remap32f m


instance Pix Word24
  where
    copy   = layerImages copy8u3
    set    = setROIs set8u3
    resize = selresize resize8u3 resize8u3NN
    warpon = warpong warpon8u3
    uradial = uradialG undistortRadial8u3
    crossCorr t = r3 . crossCorr8u3 t
    sqrDist t = r3 . sqrDist8u3 t
    absDiff = absDiff8u3
    sumPixels = sumPixels . flattenImage
    zeroP   = Word24 0 0 0
    copyMask = copyMask8u3
--    remap (LookupMap m) = remapRGB m

r3 :: Image Float -> Image Float
r3 x = resizeFull (Size r (c `div` 3)) x
  where
    Size r c = size x
    


resizeFull :: Pix p => Size -> Image p -> Image p
resizeFull sz'@(Size h' w') im = unsafePerformIO $ do
    r <- newImage undefined sz'
    return $ setROI newroi $ copy r [(x,Pixel r1' c1')]
 where
    Size h w = size im
    sr@(ROI r1 _ c1 _) = roi im
    Size rh rw = roiSize sr
    fh = g h' / g h :: Double
    fw = g w' / g w :: Double
    rh' = round (g rh*fh)
    rw' = round (g rw*fw)
    r1' = round (g r1*fh)
    c1' = round (g c1*fw)
    x = resize (Size rh' rw') im
    newroi = shift (r1',c1') (roi x)
    g n = fromIntegral n


constantImage :: Pix p => p -> Size -> Image p
constantImage v sz = unsafePerformIO $ do
    r <- newImage undefined sz
    return $ set r [(fullROI sz, v)]


warp :: Pix p => p -> Size -> Matrix Double -> Image p -> Image p
warp p sz h im = warpon (constantImage p sz) [(h,im)]



blockImage :: Pix p => [[Image p]] -> Image p
blockImage = colImage . map rowImage
  where
    rowImage = joinImage (\n r c -> Size r (c*n)) (\_ c k (Pixel r1 c1) -> Pixel r1 (c1+k*c))
    colImage = joinImage (\n r c -> Size (r*n) c) (\r _ k (Pixel r1 c1) -> Pixel (r1+k*r) c1)
    joinImage f g xs = copy base $ zip xs rois
      where
        n = length xs
        r = maximum (map (height.size) xs)
        c = maximum (map (width.size)  xs)
        base = constantImage zeroP (f n r c)
        rois = zipWith h [0..] (map roi xs)
          where
            h k (topLeft -> p) = g r c k p

--------------------------------------------------------------------------------


grayscale :: Channels -> Image Word8
grayscale = yCh

grayf :: Channels -> Image Float
grayf = fCh

{-
channels :: ImageYUV -> Channels
channels img = CHIm{..}
  where
    yuv = img
    yCh = fromYUV img
    uCh = u
    vCh = v
    rgb = rgbAux
    rCh = getChannel 0 rgbAux
    gCh = getChannel 1 rgbAux
    bCh = getChannel 2 rgbAux
    hsv = hsvAux
    hCh = getChannel 0 hsvAux
    sCh = getChannel 1 hsvAux
    fCh = float yCh
    rgbAux = fromYUV img
    hsvAux = rgbToHSV rgbAux
    (u,v) = yuvToUV img

-}

channelsFromRGB :: Image Word24 -> Channels
channelsFromRGB x = CHIm{..}
  where
    rgb = x
    yCh = rgbToGray x
    fCh = toFloat yCh

    rCh = getChannel 0 rgb
    gCh = getChannel 1 rgb
    bCh = getChannel 2 rgb

    yuv = rgbToYUV rgb
    (u,v) = yuvToUV yuv
    uCh = u
    vCh = v

    hsv = rgbToHSV rgb
    hCh = getChannel 0 hsv
    sCh = getChannel 1 hsv


channelsFromYUYV :: Image Word16 -> Channels
channelsFromYUYV x = CHIm{..} -- FIXME use original UV
  where
    rgb = yuyv2rgb x
    yCh = yuyv2gray x
    fCh = toFloat yCh

    rCh = getChannel 0 rgb
    gCh = getChannel 1 rgb
    bCh = getChannel 2 rgb

    yuv = rgbToYUV rgb
    (u,v) = yuvToUV yuv
    uCh = u
    vCh = v

    hsv = rgbToHSV rgb
    hCh = getChannel 0 hsv
    sCh = getChannel 1 hsv

--------------------------------------------------------------------------------


layerImages
    :: (Image p -> Image p -> Pixel -> IO ())
    -> Image p -> [(Image p, Pixel)] -> Image p
layerImages g im ptsIms = unsafePerformIO $ do
    res <- cloneImage im
    mapM_ (f res) ptsIms
    return res
  where
    f res (x, p) = g x res p

setROIs
    :: (p -> ROI -> Image p -> IO ())
    -> Image p -> [(ROI, p)] -> Image p
setROIs g im rps = unsafePerformIO $ do
    res <- cloneImage im
    mapM_ (f res) rps
    return res
  where
    f res (x, p) = g p x res


selresize
  :: (Size -> Image p -> t) -> (Size -> Image p -> t)
  -> Size -> Image p -> t
selresize f1 f2 sz im
    | roiArea sr < 1       = error $ "resize input " ++ show sr
    | r1 == r2 || c1 == c2 = f2 sz im
    | otherwise            = f1 sz im
  where
    sr@(ROI r1 r2 c1 c2) = roi im


warpong
  :: ([[Double]] -> Image p -> Image p -> IO ())
     -> Image p -> [(Matrix Double, Image p)] -> Image p
warpong g im hxs = unsafePerformIO $ do
    res <- cloneImage im
    mapM_ (f res) hxs
    return res
  where
    f res (h,x) | ok = g adapt x res
                | otherwise = error $ "warp homography wrong dimensions " ++ show szh
      where
        adapt = toLists $ inv (pixelToPointTrans (size res)) <> h <> pixelToPointTrans (size x)
        szh = (rows &&& cols) h
        ok = szh == (3,3)

uradialG :: (Float -> Float -> Float -> Float -> Float -> Float -> Image p -> Image p)
         -> Float -> Float -> Image p -> Image p
uradialG gen f k im = gen fp fp (fromIntegral w / 2) (fromIntegral h / 2) k 0 im
        where Size h w = size im
              fp = f * fromIntegral w / 2

--------------------------------------------------------------------------------

crossCorrLoc :: Pix p => Image p -> Image Float -> (Float, ROI)
crossCorrLoc t corr = (v, mkROI (Pixel (r-ho) (c-wo)) szrt)
  where
    (v,Pixel r c) = maxIdx corr
    szrt@(Size ht wt) = roiSize (roi t)
    ho = ht `div` 2
    wo = wt `div` 2

--------------------------------------------------------------------------------

-- | general linear filter for 32f images.
filter32f :: [[Float]]  -- ^ mask
          -> ImageFloat -- ^ input image
          -> ImageFloat -- ^ result
filter32f mask = f where
    r = length mask
    c = length (head mask)
    f = case (r,c) of
        (1,_) -> convolutionRow32f (concat mask)
        (_,1) -> convolutionColumn32f (concat mask)
        _     -> convolution32f mask

-- | general linear filter for 8u images.
filter8u :: [[Int]]   -- ^ mask
         -> Int       -- ^ divisor
         -> ImageGray -- ^ input image
         -> ImageGray -- ^ result
filter8u mask = f where
    r = length mask
    c = length (head mask)
    f = case (r,c) of
        (1,_) -> convolutionRow8u (concat mask)
        (_,1) -> convolutionColumn8u (concat mask)
        _     -> convolution8u mask

--------------------------------------------------------------------------------

class Pix p => NPix p
  where
    maxIdx :: Image p -> (p, Pixel)
    convolution :: [[Float]] -> Image p -> Image p
    filterMax :: Int -> Image p -> Image p
    filterMin :: Int -> Image p -> Image p
    filterBox :: Int -> Int -> Image p -> Image p
    gauss :: Mask -> Image p -> Image p
    compareImages :: IppCmp -> Image p -> Image p -> Image I8u
    compareValue  :: IppCmp -> Image p -> p -> Image I8u
    minEvery :: Image p -> Image p -> Image p
    maxEvery :: Image p -> Image p -> Image p
    thresholdVal :: p          -- ^ threshold
                 -> p          -- ^ value
                 -> IppCmp     -- ^ comparison function
                 -> Image p    -- ^ source image
                 -> Image p    -- ^ result
    getPoints :: Int -> Image p -> [Point]


instance NPix Word8
  where
    maxIdx = maxIndx8u
    filterMax = filterMax8u
    filterMin = filterMin8u
    filterBox = filterBox8u
    gauss = gauss8u
    compareImages = compare8u
    compareValue c x v = compareC8u v c x
    convolution mask = filter8u imask dmask
      where
        dmask = round . recip . minimum . concatMap (map abs) $ mask
        imask = map (map (round . (* fromIntegral dmask))) $ mask
    minEvery = minEvery8u
    maxEvery = maxEvery8u
    thresholdVal = thresholdVal8u
    getPoints n x = pixelsToPoints (size x) $ take n $ getPoints8u x

instance NPix Float
  where
    maxIdx = maxIndx32f
    filterMax = filterMax32f
    filterMin = filterMin32f
    filterBox = filterBox32f
    gauss = gauss32f
    compareImages = compare32f
    compareValue c x v = compareC32f v c x
    convolution = filter32f
    minEvery = minEvery32f
    maxEvery = maxEvery32f
    thresholdVal = thresholdVal32f
    getPoints n x = pixelsToPoints (size x) $ getPoints32f n x

--------------------------------------------------------------------------------

infix 4 .<., .>.

(.<.), (.>.) :: NPix p => Image p -> p -> Image I8u

img .<. v = compareValue IppCmpLess img v

img .>. v = compareValue IppCmpGreater img v

otsuBinarize :: Image I8u -> Image I8u
otsuBinarize x = x .>. otsuThreshold x

