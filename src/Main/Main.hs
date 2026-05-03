{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Data.Text.Lazy (pack)
import Text.Read (readMaybe)
import Logica.Logica
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Control.Monad.IO.Class (liftIO) 

formatarMusicaHTML :: Musica -> String
formatarMusicaHTML m = 
    "<div class='card'>" ++
    "<h3 style='margin:0 0 10px 0;'>" ++ titulo m ++ " (" ++ artista m ++ ")</h3>" ++
    "<p style='margin:5px 0;'><strong>Instrumento:</strong> " ++ show (instrumento m) ++ " | <strong>Estilo:</strong> " ++ show (estilo m) ++ "</p>" ++
    "<p style='margin:5px 0;'><strong>Nivel Técnico:</strong> " ++ show (calcularDificuldade (metricas m)) ++ " (BPM: " ++ show (bpm (metricas m)) ++ " | Var: " ++ show (variacoes (metricas m)) ++ ")</p>" ++
    "<p style='margin:5px 0; color:#aaa;'><em>" ++ show (popularidade m) ++ " acessos registrados</em></p>" ++
    -- O Link agora usa o ID interno do Banco de Dados
    "<a href='/tocar/" ++ show (idDb m) ++ "' target='_blank' class='btn-tocar'>▶ Tocar Agora</a>" ++
    "</div>"

formatarListaHTML :: [Musica] -> String
formatarListaHTML [] = "<p>Nenhuma musica encontrada com esses filtros no banco de dados.</p>"
formatarListaHTML lista = concatMap formatarMusicaHTML lista

main :: IO ()
main = do
    inicializarBanco

    scotty 3000 $ do
        middleware logStdoutDev

        get "/" $ do
            setHeader "Content-Type" "text/html; charset=utf-8"
            file "index.html"

        -- ROTA DE REDIRECIONAMENTO CORRIGIDA
        get "/tocar/:id" $ do
            idStr <- captureParam "id" :: ActionM String
            case readMaybe idStr :: Maybe Int of
                Just idDaMusica -> do
                    -- Chama a função que incrementa e busca o link completo
                    maybeLink <- liftIO $ tocarMusica idDaMusica
                    case maybeLink of
                        Just linkReal -> redirect (pack linkReal)
                        Nothing       -> html "<b style='color:red;'>Erro: Música não encontrada no banco.</b>"
                Nothing -> html "<b style='color:red;'>ID invalido.</b>"

        get "/recomendar/:estilo/:instrumento/:dificuldade" $ do
            estiloStr <- captureParam "estilo"      :: ActionM String
            instStr   <- captureParam "instrumento" :: ActionM String
            difStr    <- captureParam "dificuldade" :: ActionM String

            let estMaybe  = readMaybe estiloStr :: Maybe Estilo
                instMaybe = readMaybe instStr   :: Maybe Instrumento
                difMaybe  = readMaybe difStr    :: Maybe Dificuldade

            case (estMaybe, instMaybe, difMaybe) of
                (Just est, Just inst, Just dif) -> do
                    resultados <- liftIO $ recomendarDoBanco est inst dif
                    html $ pack $ formatarListaHTML resultados
                _ -> html "<b style='color:red;'>Erro nos parametros.</b>"

        get "/buscar/:nome" $ do
            nomeMusica <- captureParam "nome" :: ActionM String
            resultado <- liftIO $ buscarNomeDoBanco nomeMusica
            html $ pack $ formatarListaHTML resultado

        get "/artista/:nome" $ do
            nomeArt <- captureParam "nome" :: ActionM String
            resultado <- liftIO $ buscarArtistaDoBanco nomeArt
            html $ pack $ formatarListaHTML resultado

        -- ROTA POST DE CADASTRO CORRIGIDA (Recebe o link completo agora)
        post "/cadastrar" $ do
            tit <- formParam "titulo"      :: ActionM String
            art <- formParam "artista"     :: ActionM String
            linkTab <- formParam "linkTablatura" :: ActionM String
            estStr <- formParam "estilo"   :: ActionM String
            instStr <- formParam "instrumento" :: ActionM String
            b <- formParam "bpm"           :: ActionM Int
            v <- formParam "variacoes"     :: ActionM Int

            let estMaybe  = readMaybe estStr :: Maybe Estilo
                instMaybe = readMaybe instStr :: Maybe Instrumento

            case (estMaybe, instMaybe) of
                (Just est, Just inst) -> do
                    liftIO $ cadastrarMusica tit art linkTab est inst b v
                    text "Sucesso! A musica foi cadastrada e já pode ser buscada."
                _ -> text "Erro: Estilo ou Instrumento invalido."