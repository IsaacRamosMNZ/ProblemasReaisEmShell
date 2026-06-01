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
