FROM haskell:9.8.4

WORKDIR /app

RUN cabal update && cabal install --lib scotty-0.20.1 wai-extra text

COPY src ./src

RUN ghc -isrc -package text -package scotty src/Main/Main.hs -o app-musica

EXPOSE 3000

CMD ["./app-musica"]