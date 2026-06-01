# ProblemasReaisEmShell

# Exercícios de Automação com Shell Script

## Exercício 1 — O Caos no Servidor da Escola

### `organizar_alunos.sh`

```bash
#!/bin/bash

DIR="/home/alunos"
RELATORIO="$DIR/relatorio_organizacao.txt"

DOCS=0
IMAGENS=0
VIDEOS=0
OUTROS=0
REMOVIDOS=0
PROCESSADOS=0

mkdir -p "$DIR/documentos" "$DIR/imagens" "$DIR/videos" "$DIR/outros"

ESPACO_ANTES=$(du -sb "$DIR" | awk '{print $1}')

for arquivo in "$DIR"/*
do
    [ -f "$arquivo" ] || continue

    nome=$(basename "$arquivo")
    ext="${nome##*.}"

    case "$ext" in
        txt|pdf)
            mv "$arquivo" "$DIR/documentos/"
            DOCS=$((DOCS+1))
            ;;
        jpg)
            mv "$arquivo" "$DIR/imagens/"
            IMAGENS=$((IMAGENS+1))
            ;;
        mp4)
            mv "$arquivo" "$DIR/videos/"
            VIDEOS=$((VIDEOS+1))
            ;;
        tmp)
            rm "$arquivo"
            REMOVIDOS=$((REMOVIDOS+1))
            ;;
        *)
            mv "$arquivo" "$DIR/outros/"
            OUTROS=$((OUTROS+1))
            ;;
    esac

    PROCESSADOS=$((PROCESSADOS+1))

    if [ $((PROCESSADOS % 100)) -eq 0 ]; then
        echo "$PROCESSADOS arquivos processados..."
    fi
done

ESPACO_DEPOIS=$(du -sb "$DIR" | awk '{print $1}')
ESPACO_LIBERADO=$((ESPACO_ANTES - ESPACO_DEPOIS))

{
    echo "Relatório de Organização"
    echo "Data: $(date)"
    echo "Documentos movidos: $DOCS"
    echo "Imagens movidas: $IMAGENS"
    echo "Vídeos movidos: $VIDEOS"
    echo "Outros arquivos movidos: $OUTROS"
    echo "Arquivos temporários removidos: $REMOVIDOS"
    echo "Espaço liberado: $ESPACO_LIBERADO bytes"
} > "$RELATORIO"

echo "Organização concluída."
```

### Explicação

Esse script organiza os arquivos da pasta `/home/alunos`.

Ele cria as pastas `documentos`, `imagens`, `videos` e `outros`. Depois verifica a extensão de cada arquivo e move para a pasta correta.

Os arquivos `.tmp` são removidos, porque são temporários. No final, é criado um relatório com a data, quantidade de arquivos movidos e espaço liberado.

---

## Exercício 2 — Backup Noturno da Clínica

### `backup_clinica.sh`

```bash
#!/bin/bash

ORIGEM="/clinica/dados"
DESTINO="/mnt/hd_externo/backups"
LOG="/var/log/backup_clinica.log"

DATA=$(date +%F)
ARQUIVO="$DESTINO/backup_$DATA.tar.gz"

mkdir -p "$DESTINO"

if [ ! -d "$ORIGEM" ]; then
    echo "$(date) | ERRO | Pasta de origem não encontrada" >> "$LOG"
    echo "Erro: pasta de origem não encontrada."
    exit 1
fi

tar -czf "$ARQUIVO" "$ORIGEM"

if [ $? -eq 0 ]; then
    TAMANHO=$(du -h "$ARQUIVO" | awk '{print $1}')
    find "$DESTINO" -name "backup_*.tar.gz" -mtime +30 -delete

    echo "$(date) | SUCESSO | $ARQUIVO | $TAMANHO" >> "$LOG"

    echo "Backup criado com sucesso."
    echo "Arquivo: $ARQUIVO"
    echo "Tamanho: $TAMANHO"
else
    echo "$(date) | ERRO | Falha no backup" >> "$LOG"
    echo "Erro ao criar backup."
    exit 1
fi
```

### Cron

```bash
0 23 * * * /caminho/backup_clinica.sh
```

### Explicação

Esse script compacta a pasta `/clinica/dados` em um arquivo `.tar.gz` com a data no nome.

O backup é salvo em `/mnt/hd_externo/backups`. Também são apagados backups com mais de 30 dias.

Cada execução é registrada no arquivo `/var/log/backup_clinica.log`.

---

## Exercício 3 — Cadastro de Alunos

### `cadastrar_alunos.sh`

```bash
#!/bin/bash

CSV="alunos.csv"
RELATORIO="relatorio_cadastro.txt"
DIR_TURMAS="/turmas"

CRIADOS=0
FALHAS=0

> "$RELATORIO"

echo "Relatório de Cadastro" >> "$RELATORIO"
echo "Data: $(date)" >> "$RELATORIO"
echo "" >> "$RELATORIO"

if [ ! -f "$CSV" ]; then
    echo "Arquivo alunos.csv não encontrado."
    exit 1
fi

while IFS=',' read -r nome cpf turma email
do
    usuario=$(echo "$email" | cut -d '@' -f1)
    senha=$(echo "$cpf" | tr -d '.-')

    mkdir -p "$DIR_TURMAS/$turma"

    if id "$usuario" > /dev/null 2>&1; then
        echo "Falha: usuário $usuario já existe" >> "$RELATORIO"
        FALHAS=$((FALHAS+1))
        continue
    fi

    useradd -m "$usuario"

    if [ $? -eq 0 ]; then
        echo "$usuario:$senha" | chpasswd
        echo "$turma - $usuario" >> "$RELATORIO"
        CRIADOS=$((CRIADOS+1))
    else
        echo "Falha ao criar $usuario" >> "$RELATORIO"
        FALHAS=$((FALHAS+1))
    fi

done < <(tail -n +2 "$CSV")

{
    echo ""
    echo "Total de usuários criados: $CRIADOS"
    echo "Total de falhas: $FALHAS"
} >> "$RELATORIO"

echo "Cadastro finalizado."
```

### Explicação

Esse script lê o arquivo `alunos.csv`, ignorando a primeira linha.

Para cada aluno, ele cria um usuário no Linux usando `useradd`. A senha usada é o CPF sem pontos e traço.

Também cria as pastas das turmas dentro de `/turmas`. Se algum usuário já existir, o erro é registrado e o script continua.

---

## Exercício 4 — Análise de Logs

### `analisar_logs.sh`

```bash
#!/bin/bash

DATA=$(date -d "yesterday" +%F)
LOG="/var/log/webserver/$DATA.log"
RELATORIO="/relatorios/log_$DATA.txt"

mkdir -p "/relatorios"

if [ ! -f "$LOG" ]; then
    echo "Arquivo de log não encontrado."
    exit 1
fi

TOTAL=$(wc -l < "$LOG")
ERRO_404=$(grep " | 404 | " "$LOG" | wc -l)
ERRO_500=$(grep " | 500 | " "$LOG" | wc -l)
OK_200=$(grep " | 200 | " "$LOG" | wc -l)

{
    echo "Relatório de Logs"
    echo "Data de geração: $(date)"
    echo ""
    echo "Total de requisições: $TOTAL"
    echo "Código 200: $OK_200"
    echo "Código 404: $ERRO_404"
    echo "Código 500: $ERRO_500"
    echo ""
    echo "5 páginas com mais erro 404:"
    grep " | 404 | " "$LOG" | awk -F'|' '{print $3}' | sort | uniq -c | sort -nr | head -5
    echo ""
    echo "Requisições acima de 2 segundos:"
    awk -F'|' '{
        tempo=$4
        gsub("s","",tempo)
        if (tempo+0 > 2) print $0
    }' "$LOG"
} > "$RELATORIO"

if [ "$ERRO_500" -gt 10 ]; then
    echo "ALERTA: mais de 10 erros 500 encontrados."
fi

echo "Relatório salvo em $RELATORIO"
```

### Explicação

Esse script lê o log do dia anterior e conta os códigos HTTP `200`, `404` e `500`.

Ele também mostra as 5 páginas com mais erros `404` e lista as requisições que demoraram mais de 2 segundos.

Se tiver mais de 10 erros `500`, aparece um alerta no terminal.

---

## Exercício 5 — Monitoramento do Servidor

### `monitor_servidor.sh`

```bash
#!/bin/bash

LOG="/var/log/monitor_servidor.log"

CPU=$(top -bn1 | grep "Cpu" | awk '{print 100 - $8}')
RAM=$(free -m | awk '/Mem:/ {print int($3/$2 * 100)}')
DISCO=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

DATA=$(date "+%d/%m/%Y %H:%M:%S")
STATUS="[OK]"

if [ "${CPU%.*}" -gt 80 ] || [ "$RAM" -gt 85 ] || [ "$DISCO" -gt 90 ]; then
    STATUS="[ALERTA]"
fi

echo "$DATA $STATUS CPU: $CPU% | RAM: $RAM% | DISCO: $DISCO%" >> "$LOG"

for processo in nginx mysql postfix
do
    if pgrep "$processo" > /dev/null; then
        echo "$DATA [OK] Processo $processo rodando" >> "$LOG"
    else
        echo "$DATA [ALERTA] Processo $processo parado" >> "$LOG"
    fi
done
```

### Cron

```bash
*/5 * * * * /caminho/monitor_servidor.sh
```

### Explicação

Esse script verifica o uso de CPU, memória RAM e disco.

Se CPU passar de 80%, RAM passar de 85% ou disco passar de 90%, o log recebe `[ALERTA]`.

Ele também verifica se processos importantes estão rodando usando `pgrep`.

---

# Exercício para Avaliação — Fechamento Mensal

## Script 1 — `processar_filiais.sh`

```bash
#!/bin/bash

PENDENTES="/dados/filiais/pendentes"
TMP_FILIAIS="/tmp/filiais.txt"
TMP_TOTAL="/tmp/total.txt"

TOTAL="0"

if ! ls "$PENDENTES"/*.txt > /dev/null 2>&1; then
    echo "Nenhum arquivo encontrado."
    exit 1
fi

> "$TMP_FILIAIS"

for arquivo in "$PENDENTES"/*.txt
do
    FILIAL=$(grep "FILIAL:" "$arquivo" | cut -d ':' -f2 | sed 's/^ //')
    VALOR=$(grep "TOTAL:" "$arquivo" | sed 's/.*R\$ //' | tr -d '.' | tr ',' '.')

    TOTAL=$(echo "$TOTAL + $VALOR" | bc)

    echo "$FILIAL|$VALOR" >> "$TMP_FILIAIS"
    echo "$FILIAL → R$ $VALOR"
done

echo "$TOTAL" > "$TMP_TOTAL"
```

### Explicação

Esse script lê os arquivos das filiais dentro da pasta `/dados/filiais/pendentes`.

Ele pega a linha `TOTAL`, remove `R$`, pontos e troca a vírgula por ponto. Depois soma os valores usando `bc`.

---

## Script 2 — `gerar_relatorio.sh`

```bash
#!/bin/bash

TOTAL="$1"
MES="$2"
ANO="$3"

TMP_FILIAIS="/tmp/filiais.txt"
RELATORIO="/dados/relatorios/fechamento_${MES}_${ANO}.txt"

mkdir -p "/dados/relatorios"

{
    echo "Relatório de Fechamento"
    echo "Gerado em: $(date)"
    echo ""

    while IFS='|' read -r filial valor
    do
        echo "$filial - R$ $valor"
    done < "$TMP_FILIAIS"

    echo ""
    echo "Total geral consolidado: R$ $TOTAL"
    echo ""
    echo "Relatório gerado automaticamente em $(date '+%d/%m/%Y às %H:%M')"
} > "$RELATORIO"

echo "$RELATORIO"
```

### Explicação

Esse script recebe o total consolidado, mês e ano.

Depois gera o relatório com a lista de filiais, o valor de cada uma, o total geral e a assinatura automática.

---

## Script 3 — `arquivar_e_limpar.sh`

```bash
#!/bin/bash

MES="$1"
ANO="$2"

PENDENTES="/dados/filiais/pendentes"
DESTINO="/dados/arquivo/$ANO/$MES"
LOG="/var/log/fechamento.log"

mkdir -p "$DESTINO"

QTD=$(find "$PENDENTES" -maxdepth 1 -type f | wc -l)

mv "$PENDENTES"/* "$DESTINO"/

if [ "$(find "$PENDENTES" -maxdepth 1 -type f | wc -l)" -eq 0 ]; then
    echo "$(date) - $QTD arquivos movidos para $DESTINO" >> "$LOG"
    echo "$QTD"
else
    echo "$(date) - Erro ao limpar pendentes" >> "$LOG"
    exit 1
fi
```

### Explicação

Esse script cria a pasta `/dados/arquivo/ANO/MES/`.

Depois move os arquivos da pasta `pendentes` para essa pasta e verifica se a pasta ficou vazia.

A operação é registrada em `/var/log/fechamento.log`.

---

## Script principal — `fechamento_mensal.sh`

```bash
#!/bin/bash

LOG="/var/log/fechamento.log"

MES="maio"
ANO="2026"

echo "FECHAMENTO MENSAL — $MES/$ANO"

echo "[1/3] Processando arquivos das filiais..."
./processar_filiais.sh

if [ $? -ne 0 ]; then
    echo "$(date) - Erro ao processar filiais" >> "$LOG"
    echo "Erro ao processar filiais."
    exit 1
fi

TOTAL=$(cat /tmp/total.txt)

echo "[2/3] Gerando relatório..."
RELATORIO=$(./gerar_relatorio.sh "$TOTAL" "$MES" "$ANO")

if [ $? -ne 0 ]; then
    echo "$(date) - Erro ao gerar relatório" >> "$LOG"
    echo "Erro ao gerar relatório."
    exit 1
fi

echo "Relatório salvo em $RELATORIO"

echo "[3/3] Arquivando e limpando..."
QTD=$(./arquivar_e_limpar.sh "$MES" "$ANO")

if [ $? -ne 0 ]; then
    echo "$(date) - Erro ao arquivar arquivos" >> "$LOG"
    echo "Erro ao arquivar arquivos."
    exit 1
fi

echo "$QTD arquivos movidos."
echo "Fechamento concluído."

echo "$(date) - Fechamento concluído com sucesso" >> "$LOG"
```

### Explicação

Esse script principal chama os três scripts em ordem.

Primeiro ele processa os arquivos das filiais, depois gera o relatório e por último arquiva os arquivos.

Depois de cada etapa, ele verifica se deu erro usando `$?`. Se acontecer algum erro, o processo para e grava no log.
