function botstart
    set base_dir /home/ls/ls/bots
    
    # Lista todos os bots disponíveis
    set all_bots (for d in $base_dir/*/; echo (basename $d); end | sort)
    
    # Seleciona múltiplos bots com fzf
    echo "Selecione os bots que quer iniciar (CTRL+SPACE para múltiplos, ENTER para confirmar):"
    set selected_bots (printf "%s\n" $all_bots | fzf --multi)
    
    if test -z "$selected_bots"
        echo "❌ Nenhum bot selecionado."
        return
    end
    
    for bot in $selected_bots
        set bot_dir "$base_dir/$bot"
        cd $bot_dir
        
        # Ativa venv
        if test -d venv
            source venv/bin/activate.fish
        else if test -d .venv
            source .venv/bin/activate.fish
        else
            source ~/0/venv/bin/activate.fish
        end
        
        # Executa main.py e bot.py se existirem
        for py_file in main.py bot.py
            if test -f $py_file
                echo "🚀 Iniciando $py_file em background: $bot_dir"
                nohup python $py_file > "$bot_dir/$py_file.log" 2>&1 &
            end
        end
        
        if functions -q deactivate
            deactivate
        end
    end
    
    echo "🎉 Bots selecionados iniciados em background!"
end
