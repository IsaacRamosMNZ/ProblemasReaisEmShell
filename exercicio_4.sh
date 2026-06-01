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
