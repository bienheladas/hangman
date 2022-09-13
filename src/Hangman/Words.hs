module Hangman.Words where

import System.Random (randomRIO) -- [6]
import Hangman.Types (WordList)

--carga todas las palabras del diccionario y las retorna en una lista
allWords :: IO WordList
allWords = do
  dict <- readFile "data/dict.txt"
  return (lines dict)

--numero minimo de caracteres para las palabras que jugaran
minWordLength :: Int
minWordLength = 5

--numero maximo de caracteres para las palabras que jugaran
maxWordLength :: Int
maxWordLength = 12

--selecciona las palabras que cumplen los requisitos del juego
--para el minimo y maximo de caracteres
gameWords :: IO WordList
gameWords = do
  filter gameLength <$> allWords
  where gameLength w =
          let l = length (w :: String)
          in   l >= minWordLength
            && l < maxWordLength

--escoge una palabra de la lista mediante un indice aleatorio
randomWord :: WordList -> IO String
randomWord wl = do
  randomIndex <- randomRIO (0, length wl - 1)
  return $ wl !! randomIndex

--enlaza la logica que genera las palabras del juego con la que escoge
--una de ellas aleatoriamente
randomWord' :: IO String
randomWord' = gameWords >>= randomWord