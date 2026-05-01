module Logica.Logica where

data Dificuldade = Facil | Medio | Dificil deriving (Show, Eq)
data Instrumento = Violao | Guitarra | Baixo | Teclado deriving (Show, Eq)

data Musica = Musica 
  { titulo      :: String
  , artista     :: String
  , idSongsterr :: Int
  , estilo      :: String
  , instrumento :: Instrumento
  , dificuldade :: Dificuldade
  } deriving (Show, Eq)

filtrarPorEstilo :: String -> [Musica] -> [Musica]
filtrarPorEstilo estiloDesejado lista = filter (\musica -> estilo musica == estiloDesejado) lista

filtrarPorInstrumento :: Instrumento -> [Musica] -> [Musica]
filtrarPorInstrumento instrumentoDesejado lista = filter (\musica -> instrumento musica == instrumentoDesejado) lista

filtrarPorDificuldade :: Dificuldade -> [Musica] -> [Musica]
filtrarPorDificuldade dificuldadeDesejada lista = filter (\musica -> dificuldade musica == dificuldadeDesejada) lista

recomendarMusica :: String -> Instrumento -> Dificuldade -> [Musica] -> [Musica]
recomendarMusica estiloDesejado instrumentoDesejado dificuldadeDesejada lista = 
  filtrarPorEstilo estiloDesejado (filtrarPorInstrumento instrumentoDesejado (filtrarPorDificuldade dificuldadeDesejada lista))

bancoDeMusicas :: [Musica]
bancoDeMusicas = 
  [ Musica "Knockin' On Heaven's Door" "Bob Dylan" 1234 "Rock" Violao Facil
  , Musica "Master of Puppets" "Metallica" 5678 "Metal" Guitarra Dificil
  , Musica "Come As You Are" "Nirvana" 9012 "Rock" Violao Medio
  , Musica "Wonderwall" "Oasis" 3456 "Rock" Violao Facil
  ]