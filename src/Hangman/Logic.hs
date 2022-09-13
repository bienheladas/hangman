module Hangman.Logic where

import Hangman.Util ( io )
import Hangman.Puzzle ( Puzzle(..) )
import Control.Monad.Trans.State ( get, StateT )
import Control.Monad.IO.Class (liftIO)

--busca el caracter elejido dentro de la palabra del acertijo
charInWord :: Puzzle -> Char -> Bool
charInWord (Puzzle s _ _) c = c `elem` s

--busca si el caracter ya ha sido elejido
alreadyGuessed :: Puzzle -> Char -> Bool
alreadyGuessed (Puzzle _ _ guessed) c = c `elem` guessed

--reemplaza, de ser el caso, el caracter escogido en el acertijo
fillInCharacter :: Puzzle -> Char -> Puzzle
fillInCharacter (Puzzle word filledSoFar s) c =
  Puzzle word newFilledInSoFar (c:s)
  where combinator :: Char -> Char -> Maybe Char -> Maybe Char
        combinator guessed wordChar guessChar =
         if wordChar == guessed
         then Just wordChar
         else guessChar
        newFilledInSoFar =
          zipWith (combinator c) word filledSoFar

--evalua el caracter escogido e invoca la funcion para agregarlo al acertijo de ser el caso
handleGuess :: Puzzle -> Char -> IO Puzzle
handleGuess puzzle guess = do
   putStrLn $ "Letra adivinada: " ++ [guess]
   case (charInWord puzzle guess
        , alreadyGuessed puzzle guess) of
      (_, True) -> do
          putStrLn "Tu ya habias intentado\
                  \ esa letra, escoge otra!"
          return puzzle
      (True, _) -> do
          putStrLn "Esta letra estaba en la palabra\
                   \, llenando el acertijo\
                   \ acorde con la nueva letra adivinada"
          return (fillInCharacter puzzle guess)
      (False, _) -> do
          putStrLn "Esta letra no estaba en la palabra, intenta nuevamente"
          return (fillInCharacter puzzle guess)

handleGuessSIO :: Char -> StateT Puzzle IO Puzzle
handleGuessSIO guess = do
  io $ putStrLn $ "Letra adivinada: " ++ [guess]
  puzzle <- get
  case (charInWord puzzle guess
        , alreadyGuessed puzzle guess) of
      (_, True) -> do
          io $ putStrLn "Tu ya habias intentado\
                       \ esa letra, escoge otra!"
          return puzzle
      (True, _) -> do
          io $ putStrLn "Esta letra estaba en la palabra\
                      \, llenando el acertijo\
                       \ acorde con la nueva letra adivinada"
          return (fillInCharacter puzzle guess)
      (False, _) -> do
          io $ putStrLn "Esta letra no estaba en la palabra, intenta nuevamente"
          return (fillInCharacter puzzle guess)
          

  