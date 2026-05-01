{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Network.Wai.Middleware.RequestLogger (logStdoutDev)

main :: IO ()
main = scotty 3000 $ do
  middleware logStdoutDev

  get "/" $ do
    text "Página inicial"

  get "/hello" $ do
    text "Hello, Haskell Web Service!"

  -- Add more routes as needed
