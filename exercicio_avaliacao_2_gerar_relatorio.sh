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
