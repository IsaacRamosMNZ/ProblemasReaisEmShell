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
