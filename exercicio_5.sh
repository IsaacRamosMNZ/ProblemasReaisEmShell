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
