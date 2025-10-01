function m
    if test (count $argv) -eq 0
        echo "Uso: m <nome-da-pasta>"
        return 1
    end
    set dir (string join " " $argv)
    mkdir "$dir"
end
