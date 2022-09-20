module Main where

import Hangman.Puzzle (freshPuzzle)
import Hangman.Cli (runGame, runGameWRSIO)
import Hangman.Words (randomWord')
import Control.Monad.Trans.State (runStateT)
import Control.Monad.Trans.Writer (execWriterT)
import Control.Monad.Trans.Reader (runReaderT)
import Data.Char (toLower) -- [2]
import Hangman.Util (Config (Config), cfgMaxTries,cfgMinCharsWord,cfgMaxCharsWord)
import Control.Monad ( void )


--funcion principal, inicializa la ejecucion del juego
main :: IO ()
main = do
  word <- randomWord'
  let puzzle = freshPuzzle (fmap toLower word)
  runGame puzzle

--funcion principal, inicializa la ejecucion del juego (MT)
main2 :: IO ()
main2 = do
  word <- randomWord'
  let puzzle = freshPuzzle (fmap toLower word)
      cfg = Config {cfgMaxTries=5, cfgMinCharsWord=7, cfgMaxCharsWord=9}
  void (runStateT (runReaderT (execWriterT runGameWRSIO) cfg) puzzle)
  