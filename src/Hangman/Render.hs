module Hangman.Render where

--determina como se mostrara el acertijo en su estado actual al usuario
renderPuzzleChar :: Maybe Char -> Char
renderPuzzleChar Nothing = '_'
renderPuzzleChar (Just x) = x