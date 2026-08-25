# Roteiro de Uso — Claude Memories

> **Antes de começar:** este plugin depende do conector Google Drive
> expor ferramentas de conteúdo (criar, ler, buscar e escrever arquivo),
> não apenas metadados (título, lixeira, compartilhamento). Rode
> `/diagnostico` assim que instalar — se ele indicar que as ferramentas
> de conteúdo não estão disponíveis, o plugin não vai funcionar por
> completo até que uma integração com suporte completo esteja conectada.
>
> **Ao autorizar o conector Google Drive**, você verá dois grupos de
> permissão separados — algo como "Ferramentas somente leitura" e
> "Ferramentas de gravação/exclusão". Marque "Sempre permitir" nos
> **dois grupos**. Autorizar só um deles faz alguns comandos funcionarem
> e outros falharem sem aviso claro do motivo.

## O que este plugin faz

Você conversa bastante com o Claude sobre projetos, contratos, tarefas.
Sem esse plugin, cada sessão começa do zero — nada do que foi discutido
antes fica registrado de um jeito consultável.

O Claude Memories cria uma "memória" persistente numa pasta do seu Google
Drive. Nela, você (ou quem você compartilhar o acesso) registra coisas que
aconteceram numa sessão — um alerta, uma pendência, uma decisão, um
resumo — e consulta depois, inclusive em conversas futuras ou de outras
pessoas com acesso.

Não é um resumo automático de tudo que você fala. É você (ou o Claude, a
seu pedido) decidindo o que vale a pena registrar, com um comando
específico pra cada tipo de registro.

## Por que existem tipos diferentes de registro

- **Aviso**: um alerta que só precisa ser lido. Ex: "atenção, o prazo do
  edital mudou para dia 30."
- **Apontamento**: algo errado ou pendente que exige providência de
  alguém. Ex: "a cláusula 5 do contrato está com valor divergente —
  preciso que você confira."
- **Debate**: uma pergunta em aberto que precisa de resposta. Ex: "vamos
  usar o modelo A ou B pra essa proposta?"
- **Alteração**: registro histórico de algo que mudou. Ex: "trocamos o
  fornecedor X pelo Y."
- **Resumo**: o resumo do que foi tratado numa sessão.

A diferença entre eles é a expectativa: aviso pede leitura, apontamento
pede ação, debate pede resposta. Isso ajuda a filtrar depois o que
realmente precisa da sua atenção.

## Exemplo de uso, do começo ao fim

**Cenário:** Daniel está revisando um edital de licitação com uma colega,
Vanessa, que tem acesso à mesma memória compartilhada.

1. Daniel identifica um problema no edital:
   ```
   /apontamento A cláusula 5 do edital está com prazo de entrega
   incompatível com o cronograma da obra — preciso que a Vanessa
   confirme se isso foi intencional.
   ```
   O plugin grava essa entrada na memória compartilhada, com status
   "aberto".

2. Depois, ao abrir uma sessão nova, Vanessa recebe o aviso automático:
   > "Você tem 1 apontamento pendente."

3. Vanessa investiga e resolve:
   ```
   /resolver-apontamento #a3f9 Confirmado com o setor de engenharia:
   prazo será ajustado na próxima versão do edital.
   ```
   O status muda para "resolvido", com a providência registrada.

4. Semanas depois, Daniel quer relembrar o que foi tratado naquele
   edital especificamente:
   ```
   /listar-memoria-sessao edital-x
   ```
   E vê todo o histórico daquela sessão — apontamento, resposta,
   qualquer outro registro feito no meio do caminho.

## Primeiros passos

**Se você vai criar e compartilhar uma memória (dono):**
```
/config-memoria
```
Você informa o nome da pasta, com quem compartilhar e qual permissão
(leitura ou leitura+escrita) cada pessoa tem.

**Se alguém compartilhou uma memória com você (consumidor):**
```
/conectar-memoria-compartilhada
```
O plugin localiza a pasta compartilhada no seu Drive e vincula.

**A qualquer momento, para checar se está tudo funcionando:**
```
/diagnostico
```

**Para ver todos os comandos disponíveis:**
```
/ajuda
```

## Quando NÃO usar

Não é o lugar certo para:
- Anotações rápidas sem valor de consulta futura (isso é conversa normal)
- Dados sensíveis (senhas, informações financeiras) — a pasta é um Drive
  comum, sem criptografia extra do plugin
- Substituir documentação oficial de projeto — é complementar, não
  substituto
