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
