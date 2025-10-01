function geral
    set_color cyan
    set -l funcdir ~/.config/fish/functions
    set -l files (ls $funcdir/*.fish 2>/dev/null)
    if test (count $files) -eq 0
        set_color red
        echo "Nenhum comando personalizado encontrado."
        set_color normal
        return 1
    end
    set -l descs
    for f in $files
        set -l name (basename $f .fish)
        set -l help (grep -m1 -E '# desc:|# descrição:|# Descrição:|# Desc:' $f | string replace -r '^# desc(ripção)?:( )?' '')
        if test -z "$help"
            set help "(sem descrição)"
        end
        set descs $descs "$name: $help"
    end
    set_color yellow
    set -l choice (printf "%s\n" $descs | fzf --prompt="Escolha um comando > " --height=15)
    set_color normal
    if test -z "$choice"
        return 0
    end
    set -l cmd (string split ":" $choice)[1]
    set_color magenta
    echo "Executando: $cmd"
    set_color normal
    eval $cmd
end
# desc: Mostra só comandos fish customizados do usuário, permite navegar e executar com fzf. Comente cada função com '# desc:' para aparecer a descrição.
