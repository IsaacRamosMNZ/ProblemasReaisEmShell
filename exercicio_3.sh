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
