
{-# LANGUAGE OverloadedStrings #-}
module Hangman.Util (io2, Config (Config), cfgMaxTries, cfgMinCharsWord, cfgMaxCharsWord) where
    
import Control.Monad.Trans.State (StateT)
import Hangman.Puzzle (Puzzle(Puzzle))
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Reader (ReaderT)
import Control.Monad.Trans.Writer (WriterT)
import Data.Text

io :: IO a -> StateT Puzzle IO a
io = liftIO

io2 :: IO a -> WriterT Text (ReaderT Config (StateT Puzzle IO)) a
io2 = liftIO

data Config = Config {
      cfgMaxTries :: Int,
      cfgMinCharsWord :: Int,
      cfgMaxCharsWord :: Int
    } deriving (Show)