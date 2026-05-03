{-# LANGUAGE OverloadedStrings #-}
module Logica.Logica where

import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow

data Dificuldade = Facil | Medio | Dificil deriving (Show, Read, Eq)
data Instrumento = Guitarra | Baixo deriving (Show, Read, Eq)
data Estilo = Rock | Metal | Pop | Jazz deriving (Show, Read, Eq)

data Metricas = Metricas { bpm :: Int, variacoes :: Int } deriving (Show, Eq)

data Musica = Musica 
  { idDb :: Int, titulo :: String, artista :: String, linkTablatura :: String
  , estilo :: Estilo, instrumento :: Instrumento, metricas :: Metricas, popularidade :: Int } deriving (Show, Eq)

instance FromRow Musica where
    fromRow = do
        id_db <- field; tit <- field; art <- field; link <- field
        est_str <- field; inst_str <- field; b <- field; v <- field; pop <- field
        return (Musica id_db tit art link (read est_str) (read inst_str) (Metricas b v) pop)

calcularDificuldade :: Metricas -> Dificuldade
calcularDificuldade (Metricas b v)
    | b >= 160 || v >= 5 = Dificil
    | b > 110 || v >= 3  = Medio
    | otherwise          = Facil

recomendarDoBanco :: Estilo -> Instrumento -> Dificuldade -> IO [Musica]
recomendarDoBanco estiloDesejado instrumentoDesejado dificuldadeDesejada = do
    conn <- open "musicas.db"
    resultadoBruto <- query conn "SELECT id, titulo, artista, linkTablatura, estilo, instrumento, bpm, variacoes, popularidade FROM musicas WHERE estilo = ? AND instrumento = ? ORDER BY popularidade DESC" (show estiloDesejado, show instrumentoDesejado) :: IO [Musica]
    close conn
    return $ filter (\m -> calcularDificuldade (metricas m) == dificuldadeDesejada) resultadoBruto

buscarNomeDoBanco :: String -> IO [Musica]
buscarNomeDoBanco nomeDesejado = do
    conn <- open "musicas.db"
    let busca = "%" ++ nomeDesejado ++ "%" 
    resultado <- query conn "SELECT id, titulo, artista, linkTablatura, estilo, instrumento, bpm, variacoes, popularidade FROM musicas WHERE titulo LIKE ? ORDER BY popularidade DESC" (Only busca) :: IO [Musica]
    close conn; return resultado

buscarArtistaDoBanco :: String -> IO [Musica]
buscarArtistaDoBanco artistaDesejado = do
    conn <- open "musicas.db"
    let busca = "%" ++ artistaDesejado ++ "%"
    resultado <- query conn "SELECT id, titulo, artista, linkTablatura, estilo, instrumento, bpm, variacoes, popularidade FROM musicas WHERE artista LIKE ? ORDER BY popularidade DESC" (Only busca) :: IO [Musica]
    close conn; return resultado

-- NOVA FUNÇÃO: Recebe o ID interno do banco, atualiza a popularidade e retorna o Link salvo
tocarMusica :: Int -> IO (Maybe String)
tocarMusica idDaMusica = do
    conn <- open "musicas.db"
    resultado <- query conn "SELECT linkTablatura FROM musicas WHERE id = ?" (Only idDaMusica) :: IO [Only String]
    case resultado of
        [Only link] -> do
            execute conn "UPDATE musicas SET popularidade = popularidade + 1 WHERE id = ?" (Only idDaMusica)
            close conn
            return (Just link)
        _ -> do
            close conn
            return Nothing

cadastrarMusica :: String -> String -> String -> Estilo -> Instrumento -> Int -> Int -> IO ()
cadastrarMusica tit art link est inst b v = do
    conn <- open "musicas.db"
    let estStr = show est; instStr = show inst; popInicial = 0 :: Int
    execute conn "INSERT INTO musicas (titulo, artista, linkTablatura, estilo, instrumento, bpm, variacoes, popularidade) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" (tit, art, link, estStr, instStr, b, v, popInicial)
    close conn

inicializarBanco :: IO ()
inicializarBanco = do
    conn <- open "musicas.db"
    execute_ conn "CREATE TABLE IF NOT EXISTS musicas (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, artista TEXT, linkTablatura TEXT, estilo TEXT, instrumento TEXT, bpm INTEGER, variacoes INTEGER, popularidade INTEGER)"
    [Only count] <- query_ conn "SELECT COUNT(*) FROM musicas" :: IO [Only Int]
    if count == 0
        then do
            let insercoes = map (\(tit, art, link, est, inst, b, v, pop) -> (tit, art, link, show est, show inst, b, v, pop :: Int)) dadosIniciais
            executeMany conn "INSERT INTO musicas (titulo, artista, linkTablatura, estilo, instrumento, bpm, variacoes, popularidade) VALUES (?, ?, ?, ?, ?, ?, ?, ?)" insercoes
            putStrLn "\n[SISTEMA] Acervo massivo cadastrado com sucesso!\n"
        else putStrLn "\n[SISTEMA] Banco de dados SQLite carregado com sucesso!\n"
    close conn

dadosIniciais :: [(String, String, String, Estilo, Instrumento, Int, Int, Int)]
dadosIniciais = 
  [ ("Back in Black", "AC/DC", "https://www.songsterr.com/a/wsa/ac-dc-back-in-black-tab-s1024", Rock, Guitarra, 92, 3, 0)
  , ("Smells Like Teen Spirit", "Nirvana", "https://www.songsterr.com/a/wsa/nirvana-smells-like-teen-spirit-bass-tab-s269", Rock, Baixo, 116, 2, 0)
  , ("Master of Puppets", "Metallica", "https://www.songsterr.com/a/wsa/metallica-master-of-puppets-tab-s455118", Metal, Guitarra, 212, 8, 0)
  , ("Autumn Leaves", "Joe Pass", "https://www.songsterr.com/a/wsa/joe-pass-autumn-leaves-tab-s3392278", Jazz, Guitarra, 110, 8, 0)
  , ("Billie Jean", "Michael Jackson", "https://www.songsterr.com/a/wsa/michael-jackson-billie-jean-bass-tab-s10586t5", Pop, Baixo, 117, 2, 0)
  ]