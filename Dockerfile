FROM haskell:9.8.4 AS build
WORKDIR /app

RUN apt-get update && apt-get install -y libsqlite3-dev

COPY src ./src

RUN cabal update && \
    cabal install --lib scotty-0.20.1 wai-extra text-2.0.2 sqlite-simple http-types && \
    ghc -isrc -package scotty -package text-2.0.2 -package wai-extra -package sqlite-simple -package http-types -threaded src/Main/Main.hs -o app-musica

FROM debian:bookworm-slim
WORKDIR /app

RUN apt-get update && apt-get install -y \
    libgmp10 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/app-musica .

EXPOSE 3000

CMD ["./app-musica"]