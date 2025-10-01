function bot
    # Diretório base dos bots
    cd /home/ls/ls/bots

    # Menu de bots com opção "Voltar"
    set options (printf "%s\n" "↩️ Voltar" (for d in */; echo "📁 $d"; end | sort -r))
    set bot_dir (printf "%s\n" $options | fzf --reverse | sed 's/^📁 //')

    if test -z "$bot_dir" -o "$bot_dir" = "↩️ Voltar"
        echo "↩️ Voltando..."
        return
    end

    cd $bot_dir

    # Menu de arquivos Python com opção "Voltar"
    set options (printf "%s\n" "↩️ Voltar" (for f in *.py; echo "🐍 $f"; end | sort -r))
    set py_file (printf "%s\n" $options | fzf --reverse | sed 's/^🐍 //')

    if test -z "$py_file" -o "$py_file" = "↩️ Voltar"
        echo "↩️ Voltando ao menu de bots..."
        bot
        return
    end

    # Ativa venv
    if test -d venv
        echo "🟢 Ativando venv local"
        source venv/bin/activate.fish
    else if test -d .venv
        echo "🟢 Ativando .venv local"
        source .venv/bin/activate.fish
    else
        echo "🟢 Ativando venv global"
        source ~/0/venv/bin/activate.fish
    end

    echo "🚀 Executando $py_file"
    command python $py_file
    echo "✅ Execução finalizada"
end
