# Skill: Memoria Compartilhada (Google Drive)

## Proposito
Registrar, consultar e gerenciar entradas estruturadas de sessoes em pastas
do Google Drive, com controle de acesso, autoria e vinculo por sessao.

## Requisito de ferramentas do conector Google Drive
Este plugin so funciona por completo se o conector Google Drive conectado
expuser ferramentas de CRUD de conteudo, nao apenas de metadados. Integracoes
minimas (algumas contas/versoes do conector Google Drive) expoem apenas:
- Atualizar metadados de arquivo (titulo, pasta pai)
- Mover arquivo para lixeira
- Compartilhar arquivo com permissao (reader/commenter/writer)

Essas tres acoes NAO SAO SUFICIENTES para o plugin funcionar. O plugin
precisa, no minimo, que o conector disponibilize:
- Criar arquivo/pasta
- Ler conteudo de arquivo
- Buscar/listar arquivos dentro de uma pasta
- Escrever/atualizar conteudo dentro de um arquivo existente (append)

Se o conector disponivel so tiver as tres acoes basicas (metadados, lixeira,
compartilhamento), a maioria dos comandos deste plugin NAO PODE ser executada
de verdade — apenas /gerenciar-acesso, /listar-acessos (parcialmente) e
/remover-entrada (via trash) tem alguma chance de funcionar. Os comandos que
criam ou leem conteudo (/apontamento, /debate, /aviso, /alteracao, /resumo,
/ler-memoria, /listar-memorias, /relatorio, /config-memoria na parte de criar
pasta, etc.) vao falhar.

## Pre-requisito de execucao (TODO comando que acessa o Drive)
Antes de executar qualquer comando abaixo:
1. Verificar se o conector Google Drive esta disponivel e autorizado —
   tentar uma chamada leve (ex: acessar a pasta pelo ID salvo na config)
2. Verificar se as ferramentas necessarias para AQUELE comando especifico
   estao disponiveis no conector (ex: criar arquivo, ler conteudo, listar
   arquivos, escrever conteudo — conforme a lista acima)
3. Se o conector nao estiver conectado: parar e informar -
   "Nao consegui acessar o Google Drive. Verifique se o conector esta
   conectado em Configuracoes > Conectores. Se ja estiver conectado, pode
   ser necessario reautorizar o acesso."
4. Se o conector estiver conectado mas SEM a ferramenta necessaria: parar e
   informar -
   "O conector Google Drive conectado nao expoe a ferramenta necessaria
   para este comando (ex: criar/ler/escrever conteudo de arquivo). Isso e
   uma limitacao da integracao disponivel, nao uma falha de configuracao.

   Verifique se voce autorizou os DOIS grupos de permissao do conector —
   normalmente aparecem como 'Ferramentas somente leitura' e 'Ferramentas
   de gravação/exclusão'. Marque 'Sempre permitir' nos dois grupos; se
   apenas um estiver autorizado, comandos do outro grupo falham como
   este. Se ja autorizou os dois e o erro persiste, pode ser que a
   integracao disponivel nesta conta nao suporte as ferramentas de
   conteudo necessarias."
5. Nao prosseguir ate os dois pontos acima serem confirmados

## Formato de entrada
```
## [tipo] #id AAAA-MM-DD-HHmm — título curto
Sessão: <identificador da sessão>
Autor: <email>
Status: aberto/ciente/respondido/resolvido/fechado
Conteúdo: ...
Encerramento: (vazio até fechado; quando fechado: data + descrição + autor)
```
- `#id`: 4 caracteres alfanumericos, unico dentro do arquivo
- `Sessão`: identificador curto da conversa atual (inferido pelo contexto,
  ou perguntado se ambiguo)
- `Autor`: sempre quem executou o comando de criacao — nunca editavel depois

## Regras centrais
1. ID da pasta no Drive e a fonte de verdade — nunca localizar por nome
2. Vinculo e por entrada (campo Sessao), nao por pasta — uma memoria
   acumula varias sessoes ao longo do tempo
3. Permissao de escrita permite criar, nunca apagar conteudo de outro autor
4. Remocao (entrada ou sessao) so pelo autor original, sempre com
   confirmacao previa
5. Concorrencia de escrita simultanea e limitacao conhecida — nao resolvida
   automaticamente (last-write-wins do Drive)
6. Pendencia (aviso/debate/apontamento com Status = aberto) e considerada
   ATRASADA quando aberta ha mais de 7 dias (data atual − data no #id)

## Comportamento automatico — inicio de sessao
Quando uma memoria ativa esta configurada:
1. Verificar conector Google Drive (ver pre-requisito acima)
2. Checar pendencias (Status = aberto) na memoria ativa — resumo com
   totais, destacando separadamente as atrasadas (>7 dias)
3. Fetch do arquivo VERSION no repositorio
   (https://github.com/aynoei/claude_memories), comparar com versao
   instalada na config do plugin
4. Informar tudo em um resumo unico, por exemplo:
   "Você tem 2 avisos e 1 debate pendentes (1 atrasado há 12 dias). Nova
   versão do plugin disponível: v1.1 (você tem v1.0)."

---

## COMANDOS — Lado A (dono da memoria)

### /config-memoria
Perguntar: nome da pasta (sugestao: <identificador>_memories), e-mail(s) a
compartilhar, permissao de cada um (leitura / leitura+escrita).
Criar a pasta via conector, aplicar permissoes, salvar ID + config.

### /gerenciar-acesso
Listar e-mails atuais com permissao. Perguntar acao: adicionar novo e-mail
(com permissao) / remover e-mail / alterar permissao de existente. Aplicar
via conector, atualizar config.

### /listar-acessos
Tabela: e-mail | permissao — da memoria ativa (perguntar qual, se houver
mais de uma propria).

### /listar-memorias
Tabela: pasta | ID (abreviado) | compartilhado com | permissao de cada.
Cobre todas as memorias de que o usuario e dono.

---

## COMANDOS — Lado B (consumidor)

### /conectar-memoria-compartilhada
Buscar no Drive pastas com sufixo _memories em "Compartilhados comigo". Se
mais de uma, listar (nome, dono, ID abreviado) e pedir escolha ao usuario.
Ao confirmar, salvar ID + nome na config local como memoria conectada.

### /usar-memoria <nome>
Definir qual memoria conectada e a "ativa" para os proximos comandos.
Automatica se so houver uma conectada.

### /listar-memorias
Tabela: pasta | dono | ID (abreviado) | sua permissao — do ponto de vista
de quem consome.

---

## COMANDOS — Acoes (exigem permissao de escrita na memoria ativa)

Fluxo padrao: verificar permissao de escrita → recusar se nao tiver →
coletar sessao + conteudo → gerar #id + timestamp + Autor automatico →
anexar ao arquivo via conector (append, nunca sobrescrever o arquivo
inteiro) → confirmar "Registrado: [tipo] #id".

### /apontamento
Status inicial: aberto. Uso: inconformidade identificada que exige
providencia de terceiro (ou do proprio autor, futuramente). Fecha com
/resolver-apontamento.

### /debate
Status inicial: aberto. Uso: questao/discussao que precisa de
posicionamento. Fecha com /responder-debate.

### /aviso
Status inicial: aberto. Uso: alerta que so precisa ser lido/reconhecido.
Fecha com /dar-ciencia.

### /alteracao
Status: fechado. Registro historico de mudanca relevante — nao gera
pendencia.

### /resumo
Status: fechado. Registro informativo do que foi tratado na sessao ate
entao — nao gera pendencia.

---

## COMANDOS — Encerramento (nao exige ser o autor original da entrada)

### /dar-ciencia #id
Verificar: entrada existe, e do tipo aviso, esta aberta. Status → ciente.
Registrar em Encerramento: data + "ciencia dada por <autor da ciencia>".

### /responder-debate #id <resposta>
Verificar: entrada existe, e do tipo debate, esta aberta. Status →
respondido. Anexar a resposta ao conteudo (campo "Resposta:"), registrar
autor da resposta.

### /resolver-apontamento #id <descricao da providencia>
Verificar: entrada existe, e do tipo apontamento, esta aberta. Status →
resolvido. Registrar em Encerramento: data + descricao da providencia +
autor da resolucao.

---

## COMANDOS — Consulta

### /listar-pendencias
Filtrar Status = aberto em aviso/debate/apontamento, na memoria ativa.
Tabela: tipo | #id | titulo | sessao | autor | data | atrasada (sim/nao).

### /listar-mensagem-comando [tipo]
Parametro obrigatorio (apontamento/debate/aviso/alteracao/resumo). Sem
ele, recusar e informar que e obrigatorio. Listar todas as entradas
daquele tipo, independente de status.

### /listar-mensagem-comando-totais [tipo]
Sem parametro: tabela com todos os tipos e contagem de cada. Com
parametro: detalhar aquele tipo, contagem por status.

### /listar-memoria-sessao [sessao]
Sem parametro: assume sessao atual. Listar todas as entradas (qualquer
tipo) daquela sessao.

### /ler-memoria
Ler conteudo completo da memoria ativa. Filtro opcional por sessao.

### /relatorio
Diagnostico completo cruzando TODAS as memorias conectadas (proprias +
como consumidor):
1. Visao geral: total de memorias (N proprias, N como consumidor), total
   de entradas somadas
2. Tabela por memoria: memoria | papel | entradas | pendencias | ultima
   atividade
3. Pendencias consolidadas: totais por tipo (aviso/debate/apontamento) +
   destaque separado das atrasadas (>7 dias)
4. Contagem geral por tipo de acao, somando todas as memorias
5. Atividade por autor, por memoria compartilhada (quantas entradas cada
   autor criou)
6. Acessos (so memorias proprias): total de e-mails, split leitura vs.
   leitura+escrita
7. Memorias inativas: sem nenhuma entrada nova ha mais de 7 dias

### /verificar-atualizacao
Fetch manual do VERSION no repositorio, comparar com versao instalada na
config, informar se ha atualizacao disponivel.

---

## COMANDOS — Remocao (somente pelo autor original, sempre com confirmacao)

### /remover-entrada #id
Verificar Autor da entrada == usuario atual — senao recusar, informando de
quem e a entrada. Mostrar a entrada completa e pedir confirmacao explicita.
Remover so apos confirmar.

### /remover-memoria-sessao [sessao]
Sem parametro: assume sessao atual. Filtrar entradas daquela sessao cujo
Autor == usuario atual. Mostrar lista do que sera removido, pedir
confirmacao. Remover somente as proprias — entradas de outros autores na
mesma sessao permanecem intactas.

---

## /diagnostico
Health-check da instalacao do plugin — diferente do /relatorio (que mostra
conteudo das memorias), este comando confirma se o plugin esta operacional.

Executar cada checagem NA ORDEM abaixo e parar no primeiro item que falhar,
informando a causa especifica e a correcao sugerida (nao seguir para os
proximos itens se um anterior falhou):

1. Conector Google Drive conectado: testar com uma chamada leve. Se falhar:
   orientar reconexao em Configuracoes > Conectores.
2. Ferramentas do conector disponiveis (CHECAGEM CRITICA, SOMENTE LEITURA):
   verificar, sem executar nenhuma acao que crie/altere/apague dados, quais
   das seguintes acoes o conector Google Drive conectado declara suportar:
   - Criar arquivo/pasta
   - Ler conteudo de arquivo
   - Buscar/listar arquivos dentro de uma pasta
   - Escrever/atualizar conteudo dentro de um arquivo (append)
   - Atualizar metadados (titulo, pasta pai)
   - Mover para lixeira
   - Compartilhar com permissao
   Este comando NUNCA testa escrita de fato (nao cria nem apaga nada no
   Drive) — a checagem e sobre quais ferramentas estao disponiveis, nao
   se cada uma vai funcionar em tempo real. Avisar isso explicitamente no
   resultado: "A confirmacao definitiva de que consigo escrever so
   acontece na primeira vez que voce rodar um comando de acao (ex:
   /apontamento). Se as ferramentas de escrita estiverem listadas mas
   os grupos de permissao do conector nao tiverem sido autorizados
   (ex: 'Ferramentas de gravação/exclusão'), o comando pode falhar
   mesmo assim."
   Se as quatro primeiras (criar, ler, buscar, escrever conteudo) nao
   estiverem disponiveis, PARAR aqui e informar claramente: "O conector
   Google Drive conectado nao expoe as ferramentas de conteudo necessarias
   (criar/ler/buscar/escrever arquivo). Isso e uma limitacao da integracao
   disponivel — o plugin nao pode funcionar por completo nesta conta ate
   que uma integracao com essas ferramentas esteja disponivel." Listar
   explicitamente quais ferramentas FALTAM.
3. Memoria ativa configurada: existe uma memoria definida como ativa? Se
   nao houver nenhuma, orientar rodar /config-memoria (dono) ou
   /conectar-memoria-compartilhada (consumidor).
4. Acesso a pasta: o ID salvo na config ainda existe e e acessivel no
   Drive? Se nao, a pasta pode ter sido movida, renomeada ou o acesso
   revogado — orientar reconfigurar.
5. Permissao: confirmar se e leitura ou leitura+escrita na memoria ativa.
6. Arquivo de memoria legivel: tentar ler o conteudo e confirmar que o
   formato das entradas esta correto (sem blocos corrompidos).
7. Versao do plugin: comparar versao instalada com o VERSION do
   repositorio (mesmo mecanismo do /verificar-atualizacao).

Se todos os itens passarem, informar em formato de checklist (✓ para cada
item, incluindo a lista de ferramentas confirmadas no item 2) e concluir
com "Plugin operacional."

## /roteiro
Exibe o conteudo completo do arquivo ROTEIRO-DE-USO.md diretamente na
conversa (nao resumir/parafrasear). Util para quem acabou de instalar o
plugin e nao sabe o que ele faz — explica o proposito, a diferenca entre
os tipos de registro (aviso/apontamento/debate/alteracao/resumo) e mostra
um exemplo de uso do começo ao fim. Se o arquivo nao estiver acessivel,
informar e sugerir /ajuda como alternativa.

## /ajuda
Sem argumento: lista resumida de todos os comandos agrupados por categoria
(Acoes, Encerramento, Consulta, Remocao, Gestao dono, Gestao consumidor,
Sistema), uma linha cada.
Com argumento (/ajuda <comando>): detalha aquele comando especifico,
incluindo exemplo de uso.

## Limitacoes conhecidas (informar quando relevante, nao esconder)
- Concorrencia: escritas simultaneas de dois usuarios podem se sobrescrever
  (last-write-wins do Drive)
- Sem notificacao real fora de uma sessao ativa — depende do resumo
  automatico ao abrir sessao ou do comando /listar-pendencias / /relatorio
