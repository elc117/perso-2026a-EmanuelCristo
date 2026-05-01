FROM haskell:9.8.4

WORKDIR /app

COPY src ./src

RUN ghc -isrc -package=text src/Main/Main.hs -o app-musica

EXPOSE 3000

CMD ["./app-musica"]