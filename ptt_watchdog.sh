#!/bin/bash
while true; do
    sleep 1
    # Если нет аудио в буфере (файл pmr не обновлялся), выключаем PTT
    echo 0 > /sys/class/gpio/gpio21/value 2>/dev/null
done
