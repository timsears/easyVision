import EasyVision
import Graphics.UI.GLUT hiding (Matrix, Size, Point,set)
import Vision
import Control.Monad(when)
import Numeric.LinearAlgebra
import Text.Printf(printf)
import Classifier

machine = distance nearestNeighbour `onP` (const $ feat 8 (mpSize 8))

feat th sz = vector . lbpN th . resize sz . gray

main = do
    sz <- findSize
    ratio <- getOption "--ratio" (1.5)
    let szA4 = Size (32*10) (round (32*10*ratio))
        nm = "ratio " ++ printf "%.2f" ratio
    prepare

    (cam,ctrl) <- getCam 0 sz >>= withChannels >>= findRectangles ratio >>= withPause

    wimg <- evWindow () "original" sz Nothing (const $ kbdcam ctrl)
    wa4  <- evWindow () nm (Size (32*5*5) (round(32*5*ratio))) Nothing (const (kbdcam ctrl))

    Just catalog <- getRawOption "--catalog"
    protos <- readCatalog (catalog++".yuv") (mpSize 20) (catalog++".labels") Nothing channels

    let classify = fst $ machine protos

    launch (worker cam wimg wa4 ratio szA4 classify)

-----------------------------------------------------------------

worker cam wImage wA4 ratio szA4 classify = do

    (chs,a4s) <- cam
    let orig = rgb chs

    let f pts = fst . rectifyQuadrangle szA4 pts $ orig
        seen = map f a4s
        classes = map (classify. channelsFromRGB) seen

    inWin wImage $ do
        drawImage orig

        pointCoordinates (size orig)

        setColor 1 0 0
        lineWidth $= 3
        mapM_ (renderPrimitive LineLoop . (mapM_ vertex)) a4s

        setColor 0 1 0
        pointSize $= 5
        mapM_ (renderPrimitive Points . (mapM_ vertex)) a4s

        setColor 0 0 1
        let putclass c [Point x1 y1,_,Point x2 y2,_] = text2D' (Point ((x1+x2)/2)  ((y1+y2)/2)) c
        sequence $ zipWith putclass classes a4s

    inWin wA4 $ do
        when (length a4s >0) $ do
            let zeros sz = repeat (constImage (0,50,0) sz)
            let res = blockImage $ take 5 (map return $ seen++zeros szA4)
            drawImage res

text2D' (Point x y) s = do
    setColor 1 1 1
    rasterPos (Vertex2 x y)
    renderString TimesRoman24 s
