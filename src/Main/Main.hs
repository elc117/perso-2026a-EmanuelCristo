{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import qualified Data.Text.Lazy as T
import Logica.Logica

converterDificuldade :: String -> Dificuldade
converterDificuldade "Facil"   = Facil
converterDificuldade "Medio"   = Medio
converterDificuldade "Dificil" = Dificil
converterDificuldade _         = Facil 

converterInstrumento :: String -> Instrumento
converterInstrumento "Violao"   = Violao
converterInstrumento "Guitarra" = Guitarra
converterInstrumento "Baixo"    = Baixo
converterInstrumento "Teclado"  = Teclado
converterInstrumento _          = Violao

main :: IO ()
main = scotty 3000 $ do
  middleware logStdoutDev

  get "/" $ do
    text "Página inicial"

  get "/hello" $ do
    text "Hello, Haskell Web Service!"

  get "/recomendar/:estilo/:instrumento/:dificuldade" $ do
    
    estiloStr <- pathParam "estilo"      :: ActionM String
    instStr   <- pathParam "instrumento" :: ActionM String
    difStr    <- pathParam "dificuldade" :: ActionM String

    let instTipo = converterInstrumento instStr
        difTipo  = converterDificuldade difStr

    let musicasFiltradas = recomendarMusica estiloStr instTipo difTipo bancoDeMusicas
    
    text (T.pack (show musicasFiltradas))