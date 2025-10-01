# ─── default paths to backup ─── # ───✧ function: backup files and folders ───✧
function backup --description "Copy files to a timestamped folder, then create a zip archive inside it."
    set data (date "+%d-%m-%Y_%Hh%Mm%Ss")
    set backup_dir "/home/ls/ls/backup/backup_$data"

    mkdir -p "$backup_dir"


    # ─── default paths  ───
    set default_paths \
        "fish" \
        "hypr" \
        "kitty" \
        "mpv" \
        "aria2" \
        "waybar" \
        "wofi" \
        "gallery-dl" \
        "nano" \
        "swaylock"

    if test -z "$argv"
        echo "💾 Iniciando backup em: $backup_dir"

        # Backup ~/.config
        set config_dir "$backup_dir/config"
        mkdir -p "$config_dir"
        set config_ok_names ""
        for p in $default_paths
            set src "/home/ls/.config/$p"
            set dest "$config_dir/$p"
            if test -e "$src"
                cp -r "$src" "$dest"
                if test $status -eq 0
                    set config_ok_names "$config_ok_names$p, "
                end
            end
        end

        if test -n "$config_ok_names"
            set config_ok_names (string trim -r -c ", " "$config_ok_names")
            echo "↳ ⚙️  .config | $config_ok_names"
        end

        # Backup /etc/nixos
        set etc_nixos_src "/etc/nixos"
        set etc_nixos_dest "$backup_dir/nixos"
        if test -e "$etc_nixos_src"
            if cp -r "$etc_nixos_src" "$etc_nixos_dest"
                echo "↳ 🐧 /etc/nixos"
            end
        end

        # Backup ~/ls/bots
        set bots_src "/home/ls/ls/bots"
        set bots_dest "$backup_dir/bots"
        if test -e "$bots_src"
            if cp -r "$bots_src" "$bots_dest"
                echo "↳ 🤖 /ls/bots"
            end
        end

        # Backup ~/ls/k.kdbx
        set kdbx_src "/home/ls/ls/k.kdbx"
        set kdbx_dest "$backup_dir/k.kdbx"
        if test -e "$kdbx_src"
            if cp "$kdbx_src" "$kdbx_dest"
                echo "↳ 🔑 /ls/k.kdbx"
            end
        end

    else
        # Backup user-specified paths
        for item in $argv
            if test -e "$item"
                echo "↳ 📦 Copiando $item..."
                if cp -r "$item" "$backup_dir"
                else
                    echo "↳ ❌ Falha ao copiar $item"
                end
            else
                echo "↳ 🚫 Não encontrado: $item"
            end
        end
    end

    # --- Zip the backup ---
    set final_notification "Backup concluído em $backup_dir"
    if command -q zip
        echo "↳ 🗜️  Compactando backup..."
        set zip_filename (basename "$backup_dir").zip
        set dir_to_zip (basename "$backup_dir")

        set original_dir (pwd)
        cd (dirname "$backup_dir")

        # Cria o zip e o move para dentro da pasta de backup, verificando se ambos os comandos funcionam.
        if zip -r -q "$zip_filename" "$dir_to_zip"; and mv "$zip_filename" "$dir_to_zip/"
            echo "↳ ✅ Zip criado em: $backup_dir/"
            set final_notification "Backup e Zip concluídos com sucesso!"
        else
            echo "↳ ❌ Erro ao criar ou mover o arquivo zip."
            set final_notification "Backup concluído, mas a compactação/movimentação falhou."
        end

        cd "$original_dir"
    else
        echo "↳ ⚠️  Comando 'zip' não instalado. Pulando compactação."
        set final_notification "Backup concluído (sem compactação)."
    end

    # Notify user
    if command -q notify-send
        notify-send -i "document-save" "Backup Concluído" "$final_notification"
    end
end
