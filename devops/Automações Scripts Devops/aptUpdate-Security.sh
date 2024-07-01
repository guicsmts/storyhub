#!/bin/bash
# Script versionamento atualizacoes de seguranca
# ambiente Eskive
# eskive/infraestrutura
#
# Script para criação de rotinas para atualizações de SO base Debian
# Controla e notifica as atualizações de segurança programadas atraves
# do crontab.

# Pesquisa atualizações de segurança disponíveis e armazena em um arquivo temporário
temp_file=$(mktemp)
apt-get -s dist-upgrade | awk '/^Inst.*security/ {print $2, "-", $4}' | while read -r pacote versao; do
  versao_instalada=$(dpkg -l | awk -v p="$pacote" '$2==p {print $3}')
  echo "Pacote: $pacote" >> "$temp_file"
  echo "Versão Atual: ${versao_instalada:-N/A}" >> "$temp_file"
  echo "Nova Versão: $versao" >> "$temp_file"
  echo >> "$temp_file"  # Adiciona uma linha em branco entre pacotes
done

# Lê a mensagem consolidada do arquivo temporário
mensagem_slack=$(cat "$temp_file")

# Enviar notificação para o Slack
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$mensagem_slack\"}" https://hooks.slack.com/services/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

# Remove o arquivo temporário
rm "$temp_file"

