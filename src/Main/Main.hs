{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Data.Text.Lazy (pack)
import Text.Read (readMaybe)
import Logica.Logica

main :: IO ()
main = scotty 3000 $ do

    get "/" $ do
        text "Sistema de Recomendacao Musical"

    get "/recomendar/:estilo/:instrumento/:dificuldade" $ do
        estiloStr <- captureParam "estilo"      :: ActionM String
        instStr   <- captureParam "instrumento" :: ActionM String
        difStr    <- captureParam "dificuldade" :: ActionM String

        let estMaybe  = readMaybe estiloStr :: Maybe Estilo
            instMaybe = readMaybe instStr   :: Maybe Instrumento
            difMaybe  = readMaybe difStr    :: Maybe Dificuldade

        case (estMaybe, instMaybe, difMaybe) of
            (Just est, Just inst, Just dif) -> do
                let musicasFiltradas = recomendarMusica est inst dif bancoDeMusicas
                text $ pack $ "Recomendacoes encontradas: " ++ show musicasFiltradas
            _ -> 
                text "Erro: Estilo, Instrumento ou Dificuldade nao reconhecidos."

    get "/artista/:nome" $ do
        nomeArt <- captureParam "nome" :: ActionM String
        let musicas = filtrarPorArtista nomeArt bancoDeMusicas
        text $ pack $ "Musicas do artista " ++ nomeArt ++ ": " ++ show musicas

    get "/buscar/:nome" $ do
        nomeMusica <- captureParam "nome" :: ActionM String
        let resultado = buscarPorNome nomeMusica bancoDeMusicas
        case resultado of
            Just m  -> text $ pack $ "Musica Encontrada: " ++ show m
            Nothing -> text "Musica nao encontrada no acervo."