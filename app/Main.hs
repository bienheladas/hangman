module Main where

import Data.Char (toLower) -- [2]
import Hangman.Puzzle (freshPuzzle)
import Hangman.Cli (runGame, runGameSIO)
import Hangman.Words (randomWord')
import Control.Monad.State

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
  runStateT runGameSIO puzzle >> return ()