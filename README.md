# Backend Web com Haskell+Scotty

## 1. Identificação

- **Nome:** Emanuel Cristo
- **Curso:** Sistemas de Informação (UFSM)

---

## 2. Tema/objetivo

O objetivo deste trabalho é desenvolver uma **API de Curadoria Musical e Recomendação de Tablaturas**, focada em Guitarra e Contrabaixo, integrada a um banco de dados relacional (SQLite). Diferente de buscadores comuns (como CifraClub ou Songsterr) que apenas listam músicas, este sistema atua como um "professor virtual" e suas músicas podem ser registradas pela comunidade. 

A lógica principal do serviço reside em uma **avaliação interna** que recebe métricas reais da música (BPM e número de Variações Estruturais) e calcula matematicamente o nível técnico exigido (Fácil, Médio ou Difícil) para tocá-la, recomendando um acervo adequado ao nível do usuário.

**Aplicação da Programação Funcional:** A regra de negócio principal é isolada em funções puras utilizando conceitos de Álgebra de Tipos (Algebraic Data Types para Estilos e Instrumentos) e *Pattern Matching* com *Guards* para processar a dificuldade, mantendo o núcleo livre de efeitos colaterais. O código também separa estritamente o ambiente puro do impuro utilizando a mônada `IO` e a função `liftIO` para a comunicação com o servidor web (Scotty) e o banco de dados.

---

## 3. Processo de desenvolvimento

O desenvolvimento deste trabalho ocorreu de forma iterativa, partindo de um protótipo funcional em memória até alcançar uma aplicação web com persistência em banco de dados.

**Evolução da Ideia e Decisões de Arquitetura:**
Inicialmente, o acervo de músicas ficava em uma lista estática (em memória) diretamente no arquivo `Logica.hs`. No entanto, para cumprir o requisito de leitura/escrita e criar um ecossistema mais real, migrei para o uso de um banco de dados relacional (SQLite3). Isso mudou os rumos do projeto: o que antes era uma simples filtragem de listas puras virou um sistema que gerencia estados e "efeitos colaterais" através de comandos SQL (como o `UPDATE` para contar a popularidade das tablaturas).
Outra mudança de rumo importante foi nos links. No começo, eu salvava apenas o `idSongsterr` no banco, o que deixava o sistema refém de uma única plataforma. Decidi alterar a coluna para `linkTablatura` (armazenando a URL completa), tornando o recomendador agnóstico e permitindo mesclar links do Songsterr, CifraClub, entre outros. Também decidi reduzir o escopo de instrumentos (focando apenas em Guitarra e Contrabaixo) para garantir que a minha regra matemática de avaliação técnica fosse mais precisa.

**Separação da Lógica e Divisão de Esforços:**
Houve uma preocupação constante em manter o "Core" da aplicação limpo. Separei rigorosamente a interface web (`Main.hs`) do núcleo de processamento (`Logica.hs`). Como eu queria focar 100% em aprender a linguagem Haskell, a lógica funcional e o banco de dados, eu deleguei a criação de praticamente toda a interface visual (HTML/CSS/JS) para a Inteligência Artificial. A IA também me ajudou muito a entender as partes desconhecidas do framework Scotty, funcionando como uma tutora quando eu travava na sintaxe de rotas e conexões web.

*   **Estruturas de Dados:** Utilizei *Algebraic Data Types* (ADTs) como `data Instrumento = Guitarra | Baixo` e `data Estilo = Rock | Metal...`. Isso é um aspecto da programação funcional, pois o próprio compilador me impede de cadastrar uma música com um estilo inexistente, garantindo segurança de tipos.
*   **Funções Puras:** A função central do sistema, `calcularDificuldade`, é totalmente pura. Ela recebe o tipo `Metricas` e usa *Pattern Matching* com *Guards* (`|`) para determinar o nível técnico. Foi aqui que refinei a lógica: no início, músicas muito rápidas no baixo (como *Hysteria*) estavam caindo na categoria "Fácil" por causa de uma falha na minha expressão lógica booleana. Corrigi isso usando o operador lógico `OU` (`||`), garantindo que tanto a alta velocidade quanto a complexidade estrutural elevassem o nível da tablatura.
*   **Efeitos Colaterais (Mônada IO):** Compreendi na prática a diferença entre o mundo puro e o impuro. Para fazer o Scotty (que roda na mônada `ActionM`) conversar com o banco de dados (que exige a mônada `IO`), precisei entender e aplicar a função `liftIO`, criando uma ponte segura para operações de leitura e escrita no disco.

**Dificuldades, Erros e o abandono do Deploy:**
Enfrentei algumas dificuldades técnicas que exigiram pesquisa:
1.  **Erro de Threading no Servidor Web:** Ao tentar rodar o Scotty pela primeira vez, o terminal estourou o erro `requires linking against the threaded runtime`. Aprendi que o GHC compila programas em *single-thread* por padrão. A solução foi injetar a flag `-threaded` na compilação.
2.  **Ambiguidade de Tipos (SQLite):** Ao tentar inserir o valor `0` como popularidade inicial no comando `INSERT`, o GHC barrou a compilação com `Ambiguous type variable`. A solução foi tipar o dado explicitamente (`0 :: Int`).
3.  **A Dificuldade do Deploy:** A parte mais frustrante foi tentar colocar o projeto no ar no Render. Eu tentei várias vezes com o uso da IA, mexendo nos arquivos Docker e yaml, mas enfrentei muitos problemas de "Timed Out" na nuvem e não consegui achar a solução definitiva. Sendo sincero, eu acabei deixando o programa de última hora e isso me atrapalhou muito. Se eu tivesse feito antes, poderia ter consultado a professora para me ajudar com essa parte de redes e infraestrutura, que eu confesso não ter entendido muito bem. Diante disso, decidi focar na estabilidade do projeto rodando perfeitamente no meu próprio ambiente local.

---

## 4. Testes

Os testes unitários foram focados exclusivamente na ideia matemática da aplicação, garantindo que a regra de negócio funcione totalmente desvinculada do Scotty ou do banco de dados.

*   **Funções Testadas:** A função pura `calcularDificuldade`, que recebe o tipo `Metricas` (BPM e Variações) e retorna o tipo `Dificuldade`.
*   **Organização:** Criei um script independente chamado `Testes.hs` contendo uma função auxiliar personalizada `assert`, sem a necessidade de instalar bibliotecas pesadas como HUnit.
*   **Exemplos:** Foram validados cenários como "BPM extremo e muitas variações = Dificil" e "BPM no limite, mas pouca variação", forçando o teste das regras de restrição do *Pattern Matching*.

---

## 5. Execução

Para executar o projeto localmente:

1. **Instale as bibliotecas:**
   ```bash
   cabal update
   cabal install --lib scotty wai-extra text sqlite-simple http-types
   ```
2. **Compile o servidor habilitando multithreading:**
   ```bash
   ghc -isrc -package scotty -package text -package wai-extra -package sqlite-simple -package http-types -threaded src/Main/Main.hs -o app-musica
   ```
3. **Rodar os Testes Unitários Puros:**
   ```bash
   runhaskell -isrc src/Testes.hs
   ```
4. **Subir o Servidor:** `./app-musica` e acessar `http://localhost:3000`.

---

## 6. Deploy

**Link do serviço publicado:** Execução Local (O deploy na nuvem não foi concluído).

Conforme expliquei na seção de desenvolvimento, fiz várias tentativas de deploy utilizando a plataforma Render com Docker apoiado pela IA, mas não obtive sucesso. Acabei deixando essa parte para a última hora e não tive tempo hábil para consultar a professora sobre os erros de infraestrutura que surgiram. Sendo assim, a entrega e demonstração oficial estão focadas no pleno funcionamento da arquitetura e da lógica de negócio em Haskell rodando em `localhost`.

---

## 7. Resultado final

![Demonstração do Sistema](demonstracao.gif)

---

## 8. Uso de IA 

### 8.1 Ferramentas de IA utilizadas

*   **Gemini (Google):** Utilizado na versão "Gemini 3.1 Pro" como assistente principal para depuração de erros de compilação do GHC, estruturação das rotas do SQLite e apoio na interface visual.

---

### 8.2 Interações relevantes com IA

#### Interação 1
- **Objetivo da consulta:** Falha ao iniciar o servidor web do Scotty no terminal.
- **Trecho do prompt ou resumo fiel:** "GHC.Event.Thread.getSystemTimerManager: the TimerManager requires linking against the threaded runtime"
- **O que foi aproveitado:** A explicação de que o servidor Warp interno do Scotty requer suporte a múltiplas threads para gerenciar conexões.
- **O que foi modificado ou descartado:** Adicionada a compilação explícita com a flag `-threaded` no GHC.

#### Interação 2
- **Objetivo da consulta:** Solucionar o erro de compilação ao inserir dados numéricos no SQLite.
- **Trecho do prompt ou resumo fiel:** "Ambiguous type variable ‘h0’ arising from the literal ‘50’ prevents the constraint ‘(Num h0)’ from being solved."
- **O que foi aproveitado:** A correção de declarar estritamente o tipo de dado para a biblioteca `sqlite-simple` entender (`let popularidadeInicial = 0 :: Int`).

#### Interação 3 
- **Objetivo da consulta:** Tentar resolver os erros no deploy da plataforma Render.
- **Trecho do prompt ou resumo fiel:** "A parte do deploy ainda está sem funcionar... acredito que não está funcionando, o que eu faço socorro. ("texto do log")"
- **O que foi aproveitado:** A IA tentou criar arquivos Docker e render.yaml baseados nos exemplos da aula.
- **O que foi modificado ou descartado:** Apesar das várias tentativas e configurações sugeridas pela IA, o sistema continuou dando erro (Timed Out). Acabei descartando o deploy em nuvem para focar na execução local.

---

### 8.3 Exemplo de erro, limitação ou sugestão inadequada da IA

**O uso de funções legadas do Framework (A Autoria do Código):**
Durante a construção das rotas POST e GET, a IA sugeriu repetidamente que eu usasse a função genérica `param` do Scotty para capturar os dados do usuário. Ao tentar rodar e pesquisar, eu reconheci que a IA estava sugerindo um código defasado. O framework se atualizou e o uso do `param` genérico gera alertas ou falhas de precisão. Percebi que isso estava errado, assumi o controle do código e fui buscar a solução atual nas documentações, substituindo ativamente o que a IA sugeriu por `captureParam` (para resgatar dados da URL) e `formParam` (para os dados do formulário POST). Isso provou que eu não podia apenas copiar o que a IA gerava, mas sim entender a sintaxe.

Além disso, a IA também errou na prototipagem da regra matemática musical, sugerindo que uma música tocada muito rápido no contrabaixo fosse considerada "Fácil" apenas por não ter acordes complexos. Tive que usar a minha própria lógica musical e intervir nos *Guards* do Haskell.

---

### 8.4 Comentário pessoal sobre o processo envolvendo IA

O saldo de todo esse processo é extremamente positivo, pois eu aprendi muito Haskell e descobri um mundo de programação totalmente novo para mim. A minha experiência com a IA foi uma verdadeira parceria: eu usei a minha própria lógica para definir a regra de negócios, intervir em erros conceituais e garantir que o código usasse funções modernas do framework. Em contrapartida, a IA fez todo o trabalho braçal de montar a interface visual (HTML) e atuou como um excelente manual interativo para me guiar pelas partes desconhecidas do Scotty e pelas pesadas mensagens de erro do GHC.

---

## 9. Referências e créditos

- **Documentação do Web.Scotty:** https://hackage.haskell.org/package/scotty
- **Documentação do SQLite Simple:** https://hackage.haskell.org/package/sqlite-simple
- **Material de Aula (UFSM):** Repositório da disciplina https://github.com/AndreaInfUFSM/elc117-2026a e `demo-scotty-codespace-2026a`
- **Inteligência Artificial:** Google Gemini.
- **Acervo de Tablaturas:** Links públicos redirecionados para https://www.songsterr.com.
