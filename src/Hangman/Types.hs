module Hangman.Types where
import Control.Monad.Trans.Writer (WriterT)
import Control.Monad.Trans.Reader (ReaderT)
import Control.Monad.Trans.State (StateT)
import Hangman.Puzzle (Puzzle)
--import Control.Monad.Trans.Class (MonadTrans (lift))

type WordList = [String]

newtype HangmanAppT m a = 
    HangmanAppT
    { runHangmanAppT
      :: WriterT
           String
           (ReaderT Int
              (StateT Puzzle m))
            a
    }
    --deriving (Functor, Applicative)

type HangmanAppM = HangmanAppT IO

--instance Functor m => Functor (HangmanAppT m)
--instance Monad m => Applicative (HangmanAppT m)

--instance MonadTrans HangmanAppT where 
--    lift = HangmanAppT . lift . lift . lift