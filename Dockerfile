FROM haskell:9.8.4

WORKDIR /app

COPY src ./src

RUN cabal update && \
    cabal install --lib scotty-0.20.1 wai-extra text-2.0.2 && \
    ghc -isrc -package scotty -package text-2.0.2 src/Main/Main.hs -o app-musica

EXPOSE 3000

CMD ["./app-musica"]