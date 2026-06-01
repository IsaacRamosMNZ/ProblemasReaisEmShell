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
