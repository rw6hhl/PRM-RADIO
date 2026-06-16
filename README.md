Описание установки PMR Radio

Системные требования

Параметр	   Значение
Платформа	   Orange Pi One
ОС	           Armbian Linux 6.12.74-current-sunxi
Ядро	           6.12.74-sunxi
Логин	           root
Пароль	           kt315kt361

Архив repa.zip содержит:

repa/
├── pmr.c          # Исходный код программы
├── g711.c         # Таблицы кодека G.711
├── filter.c       # Фильтры аудио
├── pmr_start.sh   # Скрипт автозапуска
├── pmr.service    # Systemd сервис
└── README.md      # Документация

Установка

# 1. Установка зависимостей
apt update
apt install -y gcc libasound2-dev git

# 2. Установка WiringPi
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi && ./build && cd ..

# 3. Копирование файлов (WinSCP → /root/repa/)
# Распаковать repa.zip в /root/repa/

# 4. Компиляция
cd /root/repa
gcc -o pmr pmr.c -lpthread -lm -lz -lasound -lwiringPi

# 5. Создание скрипта запуска
cat > /root/repa/pmr_start.sh << 'EOF'
#!/bin/bash
cd /root/repa
while true; do
    ./pmr
    sleep 2
done
EOF
chmod +x /root/repa/pmr_start.sh

# 6. Установка сервиса
cp /root/repa/pmr.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable pmr.service
systemctl start pmr.service

# 7. Отключение UART3 для освобождения PA13
echo "overlays=uart3" >> /boot/armbianEnv.txt
echo "param_uart3=off" >> /boot/armbianEnv.txt
reboot

Подключение GPIO

Сигнал	                    GPIO	 WiringPi	Физ.пин	        На плате
Вход PTT (от радиостанции)	PA13	 wPi 8	         8	        GPIO13
Выход PTT (на радиостанцию)	PA21	 GPIO21	         26	        PA21
GND	-	-	                                         14	        GND

Логика работы:

PA13 = HIGH → передача аудио с радиостанции на сервер
PA13 = LOW → ожидание
PA21 = HIGH → передача аудио с сервера в эфир
PA21 = LOW → ожидание

Настройки по умолчанию

Параметр                Значение
Сервер	                185.221.154.39
Канал	                5
MailIndex	            11111
Звуковая карта	        plughw:0,0 (USB)
Частота дискретизации	16000 Гц
Кодек	                G.711 A-law

Управление

systemctl start pmr.service     # Запуск
systemctl stop pmr.service      # Остановка
systemctl status pmr.service    # Состояние
journalctl -u pmr.service -f    # Логи

Создание образа SD-карты

# На ПК с Linux (после остановки Orange Pi):
dd if=/dev/sdX of=pmr_gateway_v26.2.1.img bs=4M status=progress

Контакты

Документация и поддержка — в архиве repa.zip/README.md.

