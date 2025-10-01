# desc: Compacta todos arquivos e pastas da pasta atual em um zip com o nome da pasta
function aa
    set_color yellow
    set -l items (ls | grep -vE '\.zip$')
    if test (count $items) -eq 0
        set_color red
        echo "Nenhum arquivo ou pasta encontrado para zipar."
        set_color normal
        return 1
    end
    set_color cyan
    set -l zipname (basename (pwd))".zip"
    echo "📦 Compactando tudo em $zipname..."
    set_color normal
    zip -qr "$zipname" $items
    if test $status -eq 0
        set_color green
        echo "✅ Tudo zipado em $zipname!"
        set_color normal
        if command -q notify-send
            notify-send "Zip finalizado" "$zipname criado com sucesso!"
        end
    else
        set_color red
        echo "❌ Erro ao zipar arquivos/pastas."
        set_color normal
    end
end

# desc: Extrai cada arquivo .zip em uma pasta separada com o nome do zip
function ab
    set_color yellow
    set -l zips (ls *.zip 2>/dev/null)
    if test (count $zips) -eq 0
        set_color red
        echo "Nenhum arquivo .zip encontrado para extrair."
        set_color normal
        return 1
    end
    for z in $zips
        set -l folder (string replace -r '\.zip$' '' $z)
        set_color cyan
        echo "📂 Extraindo $z em $folder/..."
        set_color normal
        mkdir -p "$folder"
        unzip -q "$z" -d "$folder"
        if test $status -eq 0
            set_color green
            echo "✅ $z extraído em $folder!"
            set_color normal
            if command -q notify-send
                notify-send "Unzip finalizado" "$z extraído em $folder!"
            end
        else
            set_color red
            echo "❌ Erro ao extrair $z."
            set_color normal
        end
    end
end
