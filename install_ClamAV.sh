#!/bin/bash

LOG_DIR="/var/log/clamav"
SCAN_LOG="$LOG_DIR/clamav-scan.log"
CRON_FILE="/etc/cron.d/clamav_scan"

echo "Iniciando a configuração automática do ClamAV..."

#-----------------------------------------------------
# Atualizar repositórios e sistema
echo "Atualizando o sistema... 🟢"
sudo apt update && sudo apt upgrade -y

#-----------------------------------------------------
# Instalar ClamAV e ClamTK
echo "Instalando ClamAV e ClamTK... 🟢"
sudo apt install -y clamav clamav-daemon clamtk

#-----------------------------------------------------
# Habilitar e iniciar o FreshClam para atualizações automáticas
echo "Habilitando FreshClam para atualizações automáticas... 🟢"
sudo systemctl enable clamav-freshclam
sudo systemctl start clamav-freshclam

#-----------------------------------------------------
# Configurar o FreshClam
echo "Configurando FreshClam... 🟢"
sudo sed -i 's/^Checks .*$/Checks 12/' /etc/clamav/freshclam.conf
sudo systemctl restart clamav-freshclam

#-----------------------------------------------------
# Criar diretório de logs, se necessário
echo "Configurando logs... 🟢"
sudo mkdir -p "$LOG_DIR"
sudo touch "$SCAN_LOG"
sudo chmod 644 "$SCAN_LOG"

#-----------------------------------------------------
# Adicionar cron job para verificação diária
echo "Configurando cron job para verificação diária... 🟢"
echo "0 3 * * * root clamscan -r /home --log=$SCAN_LOG" | sudo tee "$CRON_FILE"
sudo chmod 644 "$CRON_FILE"

#-----------------------------------------------------
# Testar FreshClam e ClamAV
echo "Testando FreshClam... 🟢"
sudo freshclam

#-----------------------------------------------------
echo "Testando ClamAV... 🟢"
TEST_FILE="eicar.com"
wget -q https://secure.eicar.org/eicar.com -O /tmp/$TEST_FILE
sudo clamscan /tmp/$TEST_FILE

#-----------------------------------------------------
# Limpar arquivo de teste
rm -f /tmp/$TEST_FILE

echo "Instalação e configuração do ClamAV concluídas com sucesso! 🏁"
