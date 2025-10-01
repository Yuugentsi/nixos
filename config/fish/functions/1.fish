function 1
    function navigate --argument-names path --inherit-variable PWD
        set -l filters $argv[2..-1]
        while true
            set -l selected (
                begin
                    echo "⬅ Voltar"
                    echo "📝 Criar novo arquivo"
                    echo "🗑️ Excluir arquivo"
                    echo "📖 Abrir todos os arquivos aqui"
                    find "$path" -maxdepth 1 -mindepth 1 -type d | sort
                    find "$path" -maxdepth 1 -mindepth 1 -type f | sort
                end |
                while read -l f
                    if test "$f" = "⬅ Voltar" -o "$f" = "📝 Criar novo arquivo" -o "$f" = "🗑️ Excluir arquivo" -o "$f" = "📖 Abrir todos os arquivos aqui"
                        echo "$f"
                        continue
                    end
                    set name (basename "$f")
                    if test (count $filters) -gt 0
                        if not contains "$name" $filters
                            continue
                        end
                    end
                    if test -d "$f"
                        echo "📁 $name"
                    else
                        echo "📄 $name"
                    end
                end | fzf --multi --prompt "📂 $path > " --height 20 --layout=reverse --border
            )

            if test -z "$selected"
                return 0
            end

            if test (count $selected) -eq 1
                set fullpath "$path/"(string sub --start=3 "$selected")
                switch "$selected"
                    case "⬅ Voltar"
                        return 1
                    case "📝 Criar novo arquivo"
                        read -P "Nome do arquivo: " new_file
                        if test -n "$new_file"
                            sudo -E zeditor "$path/$new_file" && exit
                        end
                        continue
                    case "🗑️ Excluir arquivo"
                        set -l files_to_delete (find "$path" -maxdepth 1 -mindepth 1 -type f | sort | while read -l f; echo "📄 "(basename "$f"); end | fzf --multi --prompt "🗑️ Selecione (use Tab) > ")
                        if test -n "$files_to_delete"
                            for file in $files_to_delete
                                set file (string sub -s 3 "$file")
                                read -P "Confirmar exclusão de $file? (s/n): " confirm
                                if test "$confirm" = "s"
                                    sudo rm -f "$path/$file"
                                    echo "Arquivo excluído."
                                end
                            end
                        end
                        continue
                    case "📖 Abrir todos os arquivos aqui"
                        set -l all_files (find "$path" -maxdepth 1 -mindepth 1 -type f)
                        if test (count $all_files) -gt 0
                            sudo -E zeditor $all_files && exit
                        else
                            echo "Nenhum arquivo encontrado."
                        end
                        continue
                end
                if test -d "$fullpath"
                    navigate "$fullpath"
                    if test $status -eq 0
                        return 0
                    end
                else if test -f "$fullpath"
                    sudo -E zeditor "$fullpath" && exit
                    return 0
                end
            else
                set -l files_to_open
                for item in $selected
                    if string match -q -- "⬅ Voltar" "📝 Criar novo arquivo" "🗑️ Excluir arquivo" "📖 Abrir todos os arquivos aqui" "$item"
                        continue
                    end
                    set item_full_path "$path/"(string sub -s 3 "$item")
                    if test -d "$item_full_path"
                        for f in (find "$item_full_path" -maxdepth 1 -type f)
                            set -a files_to_open "$f"
                        end
                    else if test -f "$item_full_path"
                        set -a files_to_open "$item_full_path"
                    end
                end

                if test (count $files_to_open) -gt 0
                    sudo -E zeditor $files_to_open && exit
                else
                    echo "Nenhum arquivo para abrir."
                end
            end
        end
    end

    while true
        set -l main_selection ( echo -e "❌ Sair\n🤖 Executar bot\n🚀 Ações do Sistema\n⭐ Favoritos\n🗂️ Abrir .config\n❄️ Abrir /etc/nixos\n📹 Baixar com yt-dlp" | fzf --prompt "⚙️ Configurações > " --layout=reverse --border )
        if test -z "$main_selection"
            break
        end

        switch "$main_selection"
            case "❌ Sair"
                break
            case "🤖 Executar bot"
                cd ~/ls/bots; set bot_dir (printf "%s\n" "↩️ Voltar" (for d in */; echo "📁 $d"; end | sort -r) | fzf --reverse | sed 's/^📁 //'); if test -z "$bot_dir" -o "$bot_dir" = "↩️ Voltar"; continue; end
                cd $bot_dir; set py_file (printf "%s\n" "↩️ Voltar" (for f in *.py; echo "🐍 $f"; end | sort -r) | fzf --reverse | sed 's/^🐍 //'); if test -z "$py_file" -o "$py_file" = "↩️ Voltar"; continue; end
                if test -d venv; source venv/bin/activate.fish; else if test -d .venv; source .venv/bin/activate.fish; else; source ~/ls/venv/bin/activate.fish; end
                command python $py_file

            case "🚀 Ações do Sistema"
                while true
                    set -l action_selection ( echo -e "↩️ Voltar\n📦 Instalar programas\n🔄 Atualizar o sistema\n🧹 Limpeza do Sistema" | fzf --prompt "🚀 Ações > " --height 10 --layout=reverse --border )

                    if test -z "$action_selection" -o "$action_selection" = "↩️ Voltar"; break; end

                    switch "$action_selection"
                        case "📦 Instalar programas"
                            sudo -E zeditor /etc/nixos/modules/packages.nix && exit

                        case "🔄 Atualizar o sistema"
                            set confirm (echo -e "Sim\nNão" | fzf --prompt "Executar 'sudo nixos-rebuild switch'?" --height 4 --layout=reverse --border)
                            if test "$confirm" = "Sim"; sudo nixos-rebuild switch && exit; else; echo "Operação cancelada."; end

                        case "🧹 Limpeza do Sistema"
                            while true
                                set -l clean_selection ( echo -e "↩️ Voltar\n🔥 Limpar Cache do Usuário (~/.cache)\n🗑️ Nix: Coletar Lixo (Garbage Collect)\n✨ Nix: Limpeza Completa (GC + Otimizar Store)" | fzf --prompt "🧹 Limpeza > " --height 10 --layout=reverse --border )

                                if test -z "$clean_selection" -o "$clean_selection" = "↩️ Voltar"; break; end

                                switch "$clean_selection"
                                    case "🔥 Limpar Cache do Usuário (~/.cache)"
                                        echo "Limpando $HOME/.cache/* ..."
                                        # Usamos /* para limpar o conteúdo, mantendo a pasta
                                        sudo rm -rf $HOME/.cache/*
                                        if test $status -eq 0
                                            echo "✅ Cache limpo."
                                        else
                                            echo "❌ Erro ao limpar cache."
                                        end
                                        sleep 1

                                    case "🗑️ Nix: Coletar Lixo (Garbage Collect)"
                                        set confirm (echo -e "Sim\nNão" | fzf --prompt "Executar 'nix-collect-garbage -d'?" --height 4 --layout=reverse --border)
                                        if test "$confirm" = "Sim"
                                            echo "Executando nix-collect-garbage -d..."
                                            nix-collect-garbage -d
                                            if test $status -eq 0
                                                echo "✅ Garbage collection concluída."
                                            else
                                                echo "❌ Erro no garbage collection."
                                            end
                                        else
                                            echo "Cancelado."
                                        end
                                        sleep 1

                                    case "✨ Nix: Limpeza Completa (GC + Otimizar Store)"
                                        set confirm (echo -e "Sim\nNão" | fzf --prompt "Limpeza completa? (Leva tempo)" --height 4 --layout=reverse --border)
                                        if test "$confirm" = "Sim"
                                            echo "Iniciando limpeza profunda do Nix..."

                                            echo "1/2: Executando garbage collection (-d)..."
                                            nix-collect-garbage -d

                                            echo "2/2: Otimizando store..."
                                            sudo nix-store --optimise

                                            if test $status -eq 0
                                                echo "✅ Limpeza completa concluída."
                                            else
                                                echo "❌ Erro durante a limpeza."
                                            end
                                        else
                                            echo "Cancelado."
                                        end
                                        sleep 1
                                end
                            end
                    end
                end

            case "⭐ Favoritos"
                 while true
                    set -l fav_main_selection ( echo -e "↩️ Voltar\n🗂️ Acessar .config\n❄️ Acessar /etc/nixos\n🐟 Acessar ~/.config/fish" | fzf --prompt "⭐ Favoritos > Locais" --height 10 --layout=reverse --border )
                    if test -z "$fav_main_selection" -o "$fav_main_selection" = "↩️ Voltar"; break; end
                    switch "$fav_main_selection"
                        case "🗂️ Acessar .config"
                            set action ( echo -e "↩️ Voltar\n▶️ Abrir TODOS os arquivos em .config\n📂 Navegar em .config" | fzf --prompt "🗂️ .config > Ações" --height 10 --layout=reverse --border )
                            switch "$action"
                                case "▶️ Abrir TODOS os arquivos em .config"
                                    set -l all_files (find "$HOME/.config" -type f)
                                    if test (count $all_files) -gt 0; sudo -E zeditor $all_files && exit; end
                                    continue
                                case "📂 Navegar em .config"
                                    navigate "$HOME/.config" fish hypr kitty mpv waybar wofi
                                    break 2
                            end
                        case "❄️ Acessar /etc/nixos"
                            set action ( echo -e "↩️ Voltar\n▶️ Abrir TODOS os arquivos em nixos\n📂 Navegar em nixos\n❄️ Reconstruir o sistema" | fzf --prompt "❄️ nixos > Ações" --height 10 --layout=reverse --border )
                            switch "$action"
                                case "▶️ Abrir TODOS os arquivos em nixos"
                                    set -l all_files (find "/etc/nixos" -type f)
                                    if test (count $all_files) -gt 0; sudo -E zeditor $all_files && exit; end
                                    continue
                                case "📂 Navegar em nixos"
                                    navigate "/etc/nixos"; break 2
                                case "❄️ Reconstruir o sistema"
                                    set confirm (echo -e "Sim\nNão" | fzf --prompt "Reconstruir sistema?" --height 4 --layout=reverse --border)
                                    if test "$confirm" = "Sim"; sudo nixos-rebuild switch && exit; end
                            end
                        case "🐟 Acessar ~/.config/fish"
                            set action ( echo -e "↩️ Voltar\n▶️ Abrir TODOS os arquivos em fish\n📂 Navegar em fish" | fzf --prompt "🐟 fish > Ações" --height 10 --layout=reverse --border )
                            switch "$action"
                                case "▶️ Abrir TODOS os arquivos em fish"
                                    set -l all_files (find "$HOME/.config/fish" -type f)
                                    if test (count $all_files) -gt 0; sudo -E zeditor $all_files && exit; end
                                    continue
                                case "📂 Navegar em fish"
                                    navigate "$HOME/.config/fish"; break 2
                            end
                    end
                end
            case "🗂️ Abrir .config"
                navigate "$HOME/.config" fish hypr kitty mpv waybar wofi
            case "❄️ Abrir /etc/nixos"
                navigate "/etc/nixos"
            case "📹 Baixar com yt-dlp"
                while true
                    set base_download_dir ~/ls/videos
                    set -l ytdlp_action (
                        echo -e "↩️ Voltar\n🎵 Baixar Áudio (MP3)\n📼 Baixar Vídeo (MP4 720p)" |
                        fzf --prompt "📹 yt-dlp > " --height 10 --layout=reverse --border
                    )

                    if test -z "$ytdlp_action" -o "$ytdlp_action" = "↩️ Voltar"; break; end

                    switch "$ytdlp_action"
                        case "🎵 Baixar Áudio (MP3)" "📼 Baixar Vídeo (MP4 720p)"
                            read -P "🔗 Cole o link: " video_url
                            if test -z "$video_url"; continue; end
                            set clean_url (echo "$video_url" | string trim | sed "s/['\"]//g")
                            set video_title (yt-dlp --get-title "$clean_url" 2>/dev/null || echo "Título Indisponível")
                            set video_duration (yt-dlp --get-duration "$clean_url" 2>/dev/null || echo "0:00")
                            set current_date (date +%d/%m/%Y)
                            set log_file "$base_download_dir/downloads.txt"
                            set downloaded_file ""

                            switch "$ytdlp_action"
                                case "📼 Baixar Vídeo (MP4 720p)"
                                    set download_dir "$base_download_dir/mp4"; mkdir -p "$download_dir"; set log_prefix "📼 mp4"
                                    set downloaded_file (yt-dlp -f "bv[height<=720]+ba/b[height<=720]" --print filename -o "$download_dir/%(title)s.%(ext)s" "$clean_url")

                                case "🎵 Baixar Áudio (MP3)"
                                    set download_dir "$base_download_dir/mp3"; mkdir -p "$download_dir"; set log_prefix "🎵 mp3"
                                    set downloaded_file (yt-dlp -x --audio-format mp3 -q 0 --print filename -o "$download_dir/%(title)s.%(ext)s" "$clean_url")
                            end

                            if test $status -eq 0 -a -n "$downloaded_file"
                                echo -e "═══════\n$log_prefix ═ $video_duration ═ 📅 $current_date\n$video_title\n$clean_url\n═══════" >> $log_file
                                echo "✅ Download concluído."
                                set post_action ( echo -e "✅ Concluir (Sair)\n↩️ Voltar ao menu" | fzf --prompt "O que fazer? > " )
                                switch "$post_action"
                                    case "✅ Concluir (Sair)"; exit
                                    case "↩️ Voltar ao menu"; continue
                                end
                            else
                                echo "❌ Falha no download."
                            end
                    end
                end
        end
    end
end
