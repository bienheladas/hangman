module Hangman.Puzzle where

import Data.List (intersperse) -- [4]
import Hangman.Render (renderPuzzleChar)

--tipo de dato del acertijo
data Puzzle =
  Puzzle String [Maybe Char] [Char]

--instancia de show para el acertijo, lo formatea para su presentacion al usuario
instance Show Puzzle where
  show (Puzzle _ discovered guessed) =
    intersperse ' ' (fmap renderPuzzleChar discovered)
    ++ " Letras adivinadas hasta ahora: " ++ guessed

--inicializa una estructura en blanco para el acertijo
freshPuzzle :: String
                 -> Puzzle
freshPuzzle s = Puzzle s (fmap (const Nothing) s) []