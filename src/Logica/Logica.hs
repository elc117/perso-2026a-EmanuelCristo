module Logica.Logica where

data Dificuldade = Facil | Medio | Dificil deriving (Show, Eq)
data Instrumento = Violao | Guitarra | Baixo | Teclado deriving (Show, Eq)
data Estilo = Rock | Pop | Jazz | Metal | MPB  deriving (Show, Read, Eq)

data Musica = Musica 
  { titulo      :: String
  , artista     :: String
  , idSongsterr :: Int
  , estilo      :: Estilo
  , instrumento :: Instrumento
  , dificuldade :: Dificuldade
  } deriving (Show, Eq)

filtrarPorEstilo :: Estilo -> [Musica] -> [Musica]
filtrarPorEstilo estiloDesejado lista = filter (\musica -> estilo musica == estiloDesejado) lista

filtrarPorInstrumento :: Instrumento -> [Musica] -> [Musica]
filtrarPorInstrumento instrumentoDesejado lista = filter (\musica -> instrumento musica == instrumentoDesejado) lista

filtrarPorDificuldade :: Dificuldade -> [Musica] -> [Musica]
filtrarPorDificuldade dificuldadeDesejada lista = filter (\musica -> dificuldade musica == dificuldadeDesejada) lista

filtrarPorArtista :: String -> [Musica] -> [Musica]
filtrarPorArtista artistaDesejado lista = filter (\musica -> artista musica == artistaDesejado) lista

buscarNomeMusica :: String -> [Musica] -> [Musica]
buscarNomeMusica nomeDesejado lista = filter (\musica -> titulo musica == nomeDesejado) lista 

recomendarMusica :: Estilo -> Instrumento -> Dificuldade -> [Musica] -> [Musica]
recomendarMusica estiloDesejado instrumentoDesejado dificuldadeDesejada lista = 
  filtrarPorEstilo estiloDesejado (filtrarPorInstrumento instrumentoDesejado (filtrarPorDificuldade dificuldadeDesejada lista))

bancoDeMusicas :: [Musica]
bancoDeMusicas = 
  [ Musica "Knockin' On Heaven's Door" "Bob Dylan" 1234 Rock Violao Facil
  , Musica "Master of Puppets" "Metallica" 5678 Metal Guitarra Dificil
  , Musica "Come As You Are" "Nirvana" 9101 Rock Violao Medio
  , Musica "Wonderwall" "Oasis" 1213 Rock Violao Facil
  , Musica "Hysteria" "Muse" 1415 Rock Baixo Dificil
  , Musica "Another One Bites the Dust" "Queen" 1617 Rock Baixo Facil
  , Musica "Under the Bridge" "RHCP" 1819 Rock Guitarra Medio
  , Musica "So What" "Miles Davis" 2021 Jazz Teclado Medio
  , Musica "The Trooper" "Iron Maiden" 2223 Metal Baixo Dificil
  , Musica "Garota de Ipanema" "Tom Jobim" 2425 MPB Guitarra Facil
  ]