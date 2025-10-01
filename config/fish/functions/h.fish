function h
    # Diretório inicial
    set -l entries "📁 /etc/nixos"
    
    # Primeira seleção
    set -l choice (printf "%s\n" $entries | fzf --prompt="Escolha pasta > " --height=4)
    if test -z "$choice"
        return
    end
    
    # Determinar caminho inicial
    switch "$choice"
        case "📁 /etc/nixos"
            set path "/etc/nixos"
    end
    
    echo "📂 Entrou em: $path"
    
    # Loop de navegação
    while true
        set -l sub_entries
        
        # Pastas primeiro, depois arquivos
        for d in (ls -1 $path 2>/dev/null)
            if test -d "$path/$d"
                set sub_entries $sub_entries "📁 $d"
            end
        end
        for f in (ls -1 $path 2>/dev/null)
            if test -f "$path/$f"
                set sub_entries $sub_entries "📄 $f"
            end
        end
        
        set -l sub_choice (printf "%s\n" $sub_entries | fzf --prompt="Escolha arquivo/pasta > " --height=12)
        if test -z "$sub_choice"
            break
        end
        
        set sub_name (string trim -c "📁📄 " "$sub_choice")
        set sub_path "$path/$sub_name"
        
        if test -d "$sub_path"
            set path "$sub_path"
            echo "📂 Entrou em: $sub_path"
        else
            echo "📄 Abrindo arquivo: $sub_path"
            sudo -E ZED_ALLOW_ROOT=true zeditor "$sub_path"
            if status --is-interactive
                kill -9 (pgrep -u $USER kitty)
            end
            break
        end
    end
end
