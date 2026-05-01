module Logica.Logica where

data Dificuldade = Facil | Medio | Dificil 
  deriving (Show, Eq)

data Musica = Musica 
  { titulo  :: String
  , artista :: String
  , idSongsterr :: Int 
  } deriving (Show, Eq)