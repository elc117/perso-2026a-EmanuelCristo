module Main where

import Logica.Logica

assert :: String -> Bool -> IO ()
assert nomeDoTeste True  = putStrLn $ "✅ PASSOU: " ++ nomeDoTeste
assert nomeDoTeste False = putStrLn $ "❌ FALHOU: " ++ nomeDoTeste

main :: IO ()
main = do
    putStrLn "INICIANDO BATERIA DE TESTES UNITÁRIOS n"

    putStrLn "-> Testando Regras de Negócio (calcularDificuldade)"
    
    let met1 = Metricas 180 6
    assert "BPM Alto (180) e muitas variacoes (6) = Dificil" (calcularDificuldade met1 == Dificil)
    
    let met2 = Metricas 160 2
    assert "BPM no limite (160), pouca variacao (2) = Dificil" (calcularDificuldade met2 == Dificil)

    let met3 = Metricas 120 3
    assert "BPM moderado (120) e media variacao (3) = Medio" (calcularDificuldade met3 == Medio)

    let met4 = Metricas 90 1
    assert "BPM lento (90) e repetitivo (1) = Facil" (calcularDificuldade met4 == Facil)

    putStrLn "TESTES CONCLUÍDOS"