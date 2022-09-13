{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use void" #-}
module Hangman.Cli where

import Hangman.Util ( io )
import Hangman.Puzzle ( Puzzle(..) )
import Hangman.Logic (handleGuess, handleGuessSIO)
import Control.Monad (forever, when) -- [1]
import Data.Maybe (isJust) -- [3]
import System.Exit (exitSuccess) -- [5]
import Data.Char (toLower) -- [2]
import Control.Monad.Trans.Reader (ReaderT (..), ask, asks)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.State ( StateT, put, get )
import Control.Monad.IO.Class ( MonadIO(liftIO) )

--finaliza el juego si se han cometido mas de 5 equivocaciones
gameOver :: Puzzle -> IO ()
gameOver (Puzzle wordToGuess _ guessed) =
  if length (filter (not . (`elem` wordToGuess)) guessed) > 5 then
    do
      putStrLn "Perdiste! Tuviste mas de 5 equivocaciones!"
      putStrLn $ "La palabra era: " ++ wordToGuess
      exitSuccess
  else
    return ()

--finaliza el juego cuando todos los elementos de la estructura del acertijo se hayan descubierto (Just)
gameWin :: Puzzle -> IO ()
gameWin (Puzzle _ filledInSoFar _) =
  when (all isJust filledInSoFar) $
  do
    putStrLn "Ganaste!"
    exitSuccess

type RIO = ReaderT Char IO
type RSIO = StateT Puzzle RIO

--loop que controla la ejecucion del juego
runGame :: Puzzle -> IO ()
runGame puzzle = forever $ do
  gameOver puzzle
  gameWin puzzle
  putStrLn $
     "El acertijo actual es: " ++ show puzzle
  putStr "Adivina una letra: "
  guess <- getLine
  case guess of
    [c] -> handleGuess puzzle (toLower c) >>= runGame
    _ ->
      putStrLn "Solo puedes adivinar una letra a la vez"


gameOverSIO :: StateT Puzzle IO ()
gameOverSIO = do
  (Puzzle wordToGuess _ guessed) <- get
  when (length (filter (not . (`elem` wordToGuess)) guessed) > 5) $
    do
      io $ putStrLn "Perdiste! Tuviste mas de 5 equivocaciones!"
      io $ putStrLn $ "La palabra era: " ++ wordToGuess
      io exitSuccess

--finaliza el juego cuando todos los elementos de la estructura del acertijo se hayan descubierto (Just)
gameWinSIO :: StateT Puzzle IO ()
gameWinSIO = do
  (Puzzle _ filledInSoFar _) <- get
  when (all isJust filledInSoFar) $
    do
      io $ putStrLn "Ganaste!"
      io exitSuccess

--loop que controla la ejecucion del juego (usando Monad Transformers)
runGameSIO :: StateT Puzzle IO ()
runGameSIO = forever $ do
  --evalua si termino el juego
  gameOverSIO
  --evalua si gano el juego
  gameWinSIO
  --lee el puzzle actual
  puzzle <- get
  --obtiene del usuario un nuevo caracter para jugar
  io $ putStrLn ("El acertijo actual es: " ++ show puzzle)
  io $ putStr "Adivina una letra: "
  guess <- liftIO getLine
  --evalua que hacer con el caracter adivinado
  case guess of
   [c] -> do
            newPuzzle <- handleGuessSIO (toLower c)
            put newPuzzle  --PREGUNTA: Como hacer esto en 1 sola linea?
            runGameSIO
   _   -> io $ putStrLn "Solo puedes adivinar una letra a la vez!"


