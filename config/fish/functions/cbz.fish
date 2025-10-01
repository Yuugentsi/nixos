function cbz --description 'Cria um CBZ para cada subpasta com JPGs e um CBZ completo na pasta atual'
    set complete_cbz "complete.cbz"
    rm -f "$complete_cbz" # Remove CBZ completo se já existir
    for dir in */
        if test -d "$dir"
            pushd "$dir" >/dev/null
            set archive_name (basename (pwd))
            set cbz_file "$archive_name.cbz"
            if ls *.jpg >/dev/null 2>&1
                zip -q "$cbz_file" *.jpg
                echo "🎉 Arquivo $cbz_file criado em $dir"
                zip -q -u "../$complete_cbz" *.jpg # Adiciona ao CBZ completo
            else
                echo "⚠️ Nenhuma imagem JPG encontrada em $dir"
            end
            popd >/dev/null
        end
    end
    if test -f "$complete_cbz"
        echo "🎉 Arquivo $complete_cbz criado com todas as imagens!"
    else
        echo "⚠️ Nenhuma imagem JPG encontrada nas subpastas."
    end
end
