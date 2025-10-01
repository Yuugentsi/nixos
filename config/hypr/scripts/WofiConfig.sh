#!/bin/bash
file=$(ls /etc/nixos | wofi --show dmenu -p '📂 Escolha o arquivo para editar:')
[ -n "$file" ] && sudo -E zeditor /etc/nixos/"$file"
