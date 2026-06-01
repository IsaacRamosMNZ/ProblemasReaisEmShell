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
