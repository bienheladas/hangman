module Hangman.Logic where

import Hangman.Util ( Config, io2 )
import Hangman.Puzzle ( Puzzle(..) )
import Control.Monad.Trans.State ( get, StateT )
import Control.Monad.Trans.Reader (ReaderT)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Writer (WriterT, tell)
import Data.Text (Text, pack)

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

--evalua el caracter escogido e invoca la funcion para agregarlo al 
--acertijo de ser el caso 
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

--evalua el caracter escogido e invoca la funcion para agregarlo al 
--acertijo de ser el caso (usando Monad Transformers)
handleGuessWRSIO :: Char -> WriterT Text (ReaderT Config (StateT Puzzle IO)) Puzzle
handleGuessWRSIO guess = do
  io2 $ putStrLn $ "Letra adivinada: " ++ [guess]
  puzzle <- (lift . lift) get
  case (charInWord puzzle guess
        , alreadyGuessed puzzle guess) of
      (_, True) -> do
          _ <- tell $ pack "letra repetida"
          io2 $ putStrLn "Tu ya habias intentado\
                       \ esa letra, escoge otra!"
          return puzzle
      (True, _) -> do
          _ <- tell $ pack "letra acertada!"
          io2 $ putStrLn "Esta letra estaba en la palabra\
                      \, llenando el acertijo\
                       \ acorde con la nueva letra adivinada"
          return (fillInCharacter puzzle guess)
      (False, _) -> do
          _ <- tell $ pack "letra equivocada!"
          io2 $ putStrLn "Esta letra no estaba en la palabra, intenta nuevamente"
          return (fillInCharacter puzzle guess)