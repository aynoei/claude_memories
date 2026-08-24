# Claude Memories

Plugin para registrar e consultar memorias de sessoes (avisos, apontamentos,
debates, alteracoes, resumos) em pastas do Google Drive, com suporte a
compartilhamento entre contas Claude.

Novo por aqui? Veja o [Roteiro de Uso](./ROTEIRO-DE-USO.md) — explica o
que o plugin faz e mostra um exemplo completo do começo ao fim.

## Requisitos
- Conector Google Drive conectado na sua conta Claude

## Instalacao
Aponte a instalacao de plugin para este repositorio:
https://github.com/aynoei/claude_memories

## Inicio rapido
- Dono: rode `/config-memoria` para criar sua pasta de memorias
- Consumidor: rode `/conectar-memoria-compartilhada` para vincular uma pasta
  compartilhada com voce
- Rode `/ajuda` a qualquer momento para ver todos os comandos
- Rode `/relatorio` para um diagnostico completo de todas as suas memorias

## Comportamento automatico
Ao iniciar uma sessao com uma memoria ativa configurada, o plugin verifica
automaticamente:
- Se o conector Google Drive esta funcionando
- Pendencias em aberto (avisos, debates, apontamentos), destacando as
  atrasadas (abertas ha mais de 7 dias)
- Se ha uma nova versao do plugin disponivel neste repositorio

## Versionamento
Releases marcadas por tag (ex: v1.0.0). A verificacao de atualizacao compara
o arquivo VERSION deste repositorio com a versao instalada localmente.
Atualizar exige reinstalar o plugin - nao e automatico.

## Comandos

### Gestao - dono da memoria
- `/config-memoria` - cria pasta e compartilha com e-mails/permissoes
- `/gerenciar-acesso` - adiciona/remove e-mail, altera permissao
- `/listar-acessos` - quem acessa e com qual permissao
- `/listar-memorias` - tabela de todas as memorias proprias

### Gestao - consumidor
- `/conectar-memoria-compartilhada` - localiza e vincula pasta compartilhada
- `/usar-memoria <nome>` - define memoria ativa entre varias conectadas
- `/listar-memorias` - tabela das memorias conectadas

### Acoes
- `/apontamento` - inconformidade que exige providencia de terceiro
- `/debate` - questao que exige posicionamento
- `/aviso` - alerta que exige apenas ciencia
- `/alteracao` - registro de mudanca relevante
- `/resumo` - resumo da sessao ate entao

### Encerramento
- `/dar-ciencia #id`
- `/responder-debate #id <resposta>`
- `/resolver-apontamento #id <providencia>`

### Consulta
- `/listar-pendencias`
- `/listar-mensagem-comando [tipo]`
- `/listar-mensagem-comando-totais [tipo]`
- `/listar-memoria-sessao [sessao]`
- `/ler-memoria`
- `/relatorio`
- `/diagnostico`
- `/verificar-atualizacao`

### Remocao (somente pelo autor original)
- `/remover-entrada #id`
- `/remover-memoria-sessao [sessao]`

### Sistema
- `/ajuda [comando]`
