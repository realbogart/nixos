module Main where

import Control.Concurrent (MVar, forkOS, newEmptyMVar, putMVar, readMVar, tryReadMVar)
import Control.Exception (bracket, finally)
import Control.Monad (unless, void, when)
import Data.IORef (IORef, atomicWriteIORef, newIORef, readIORef)
import qualified Foreign.Store as Store
import Raylib.Core
import Raylib.Core.Shapes (drawCircle, drawRectangle)
import Raylib.Core.Text (drawText)
import Raylib.Types (Color (..))
import Raylib.Util (drawing)
import System.Environment (getArgs)

-- Run with --smoke-test to capture a frame and close after three seconds.
main :: IO ()
main = do
  args <- getArgs
  unless (null args || args == ["--smoke-test"]) $
    fail "Usage: RaylibWindow.hs [--smoke-test]"
  withWindow $ \start -> loop drawFrame (pure False) (args == ["--smoke-test"]) start 0

withWindow :: (Double -> IO ()) -> IO ()
withWindow action =
  bracket (initWindow 800 450 "Haskell scratch | h-raylib") (closeWindow . Just) $ \_ -> do
    ready <- isWindowReady
    unless ready $ fail "Graphics window did not initialize"
    setTargetFPS 60
    start <- getTime
    action start

loop :: (Double -> IO ()) -> IO Bool -> Bool -> Double -> Int -> IO ()
loop render shouldStop smoke start frame = do
  closing <- windowShouldClose
  stopping <- shouldStop
  elapsed <- subtract start <$> getTime
  unless (closing || stopping || (smoke && elapsed >= 3)) $ do
    drawing (render elapsed)
    when (smoke && frame == 30) $ takeScreenshot "raylib-smoke.png"
    loop render shouldStop smoke start (frame + 1)

-- Edit this function while mainDev is running. The animation clock survives.
drawFrame :: Double -> IO ()
drawFrame elapsed = do
  clearBackground (Color 20 25 42 255)
  drawText "Hello, Haskell!!" 48 48 40 (Color 240 244 255 255)
  drawText "A standalone script powered by h-raylib" 50 104 20 (Color 159 176 205 255)
  drawRectangle 48 330 704 2 (Color 56 68 94 255)
  let x = 400 + round (260 * sin (elapsed * 1.7))
      y = 230 + round (45 * sin (elapsed * 2.4))
  drawCircle x y 36 (Color 102 224 194 255)
  drawText "Animated at 60 FPS  /  Esc to close" 50 372 20 (Color 159 176 205 255)

-- The stored type must stay unchanged across reloads. Slot 0 belongs to this
-- demo's GHCi process. Only the REPL thread accesses Foreign.Store itself.
devStore :: Store.Store (IORef (Double -> IO ()), IORef Bool, MVar ())
devStore = Store.Store 0

mainDev :: IO ()
mainDev = do
  existing <- Store.lookupStore 0
  case existing of
    Nothing -> startDev
    Just _ -> do
      (renderRef, _, finished) <- Store.readStore devStore
      stopped <- tryReadMVar finished
      case stopped of
        Just () -> Store.deleteStore devStore >> startDev
        Nothing -> do
          atomicWriteIORef renderRef drawFrame
          putStrLn "Drawing function reloaded; window and animation clock preserved."

startDev :: IO ()
startDev = do
  renderRef <- newIORef drawFrame
  stopRef <- newIORef False
  finished <- newEmptyMVar
  Store.writeStore devStore (renderRef, stopRef, finished)
  void
    $ forkOS
    $ ( withWindow $ \start ->
          loop (\elapsed -> readIORef renderRef >>= ($ elapsed)) (readIORef stopRef) False start 0
      )
      `finally` putMVar finished ()
  putStrLn "Development window started. Edit drawFrame and save to reload."

-- In a manual GHCi session, stopDev closes on the rendering thread.
stopDev :: IO ()
stopDev = do
  existing <- Store.lookupStore 0
  case existing of
    Nothing -> pure ()
    Just _ -> do
      (_, stopRef, finished) <- Store.readStore devStore
      atomicWriteIORef stopRef True
      readMVar finished
      Store.deleteStore devStore
