{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use void" #-}
module Hangman.Cli where

import Hangman.Util ( Config (..), io2)
import Hangman.Puzzle ( Puzzle(..) )
import Hangman.Logic (handleGuess, handleGuessWRSIO)
import Control.Monad (forever, when) -- [1]
import Data.Maybe (isJust) -- [3]
import System.Exit (exitSuccess) -- [5]
import Data.Char (toLower) -- [2]
import Control.Monad.Trans.Reader (ReaderT (..), ask)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.State ( StateT, put, get )
import Control.Monad.IO.Class ( MonadIO(liftIO) )
import Control.Monad.Trans.Writer (WriterT, tell)
import Data.Text (Text, pack)

--finaliza el juego si se han cometido mas de 5 equivocaciones
gameOver :: Puzzle -> IO ()
gameOver (Puzzle wordToGuess _ guessed) =
  when (length (filter (not . (`elem` wordToGuess)) guessed) > 5) $
  do
    putStrLn "Perdiste! Tuviste mas de 5 equivocaciones!"
    putStrLn $ "La palabra era: " ++ wordToGuess
    exitSuccess

--finaliza el juego cuando todos los elementos de la estructura del acertijo se hayan descubierto (Just)
gameWin :: Puzzle -> IO ()
gameWin (Puzzle _ filledInSoFar _) =
  when (all isJust filledInSoFar) $
  do
    putStrLn "Ganaste!"
    exitSuccess

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

--finaliza el juego si se han cometido mas de 5 equivocaciones (usando Monad Transformers)
gameOverWRSIO :: WriterT Text (ReaderT Config (StateT Puzzle IO)) ()
gameOverWRSIO = do
  cfg <- lift ask
  (Puzzle wordToGuess _ guessed) <- (lift . lift) get
  when (length (filter (not . (`elem` wordToGuess)) guessed) > cfgMaxTries cfg) $
    do
      _ <- tell $ pack "juego terminado: el jugador perdió"
      io2 $ putStrLn "Perdiste! Tuviste mas de 5 equivocaciones!"
      io2 $ putStrLn $ "La palabra era: " ++ wordToGuess
      io2 exitSuccess

--finaliza el juego cuando todos los elementos de la estructura del acertijo se
--han descubierto (Just)
gameWinWRSIO :: WriterT Text (ReaderT Config (StateT Puzzle IO)) ()
gameWinWRSIO = do
  (Puzzle _ filledInSoFar _) <- (lift . lift) get
  when (all isJust filledInSoFar) $
    do
      _ <- tell $ pack "juego terminado: el jugador ganó"
      io2 $ putStrLn "Ganaste! Felicitaciones!"
      io2 exitSuccess

--loop que controla la ejecucion del juego (usando Monad Transformers)
runGameWRSIO :: WriterT Text (ReaderT Config (StateT Puzzle IO)) ()
runGameWRSIO = forever $ do
  _ <- tell $ pack "inicia Rutina"
  gameOverWRSIO
  gameWinWRSIO

  puzzle <- (lift . lift) get

  io2 $ putStrLn ("El acertijo actual es: " ++ show puzzle)
  io2 $ putStr "Adivina una letra: "

  guess <- liftIO getLine
  _ <- tell $ pack ("letra ingresada por el jugador: " ++ guess)
  --evalua que hacer con el caracter adivinado
  case guess of
   [c] -> do
            newPuzzle <- handleGuessWRSIO (toLower c)
            (lift . lift) (put newPuzzle)  --PREGUNTA: Como hacer esto en 1 sola linea?
            runGameWRSIO
   _   -> io2 $ putStrLn "Solo puedes adivinar una letra a la vez!"