FROM haskell:9.8.4

WORKDIR /app

RUN cabal update && cabal install --lib --package-env . scotty-0.20.1 wai-extra text

COPY src ./src

RUN ghc -isrc -package-env . src/Main/Main.hs -o app-musica

EXPOSE 3000

CMD ["./app-musica"]