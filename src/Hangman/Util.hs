module Hangman.Util where
    
import Control.Monad.Trans.State (StateT)
import Hangman.Puzzle (Puzzle(Puzzle))
import Control.Monad.IO.Class (liftIO)

io :: IO a -> StateT Puzzle IO a
io = liftIO