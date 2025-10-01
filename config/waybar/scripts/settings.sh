#!/usr/bin/env bash
set -eu

navigate() {
    local path="$1"
    shift
    local filter=("$@")
    local parent_menu="$PWD"

    while true; do
        local selected
        selected=$(
            (echo "⬅ Voltar";
             find "$path" -maxdepth 1 -mindepth 1 -type d | sort;
             find "$path" -maxdepth 1 -mindepth 1 -type f | sort) | while read f; do
                if [[ "$f" == "⬅ Voltar" ]]; then
                    echo "$f"
                    continue
                fi
                name=$(basename "$f")
                if [[ ${#filter[@]} -gt 0 ]]; then
                    [[ ! " ${filter[*]} " =~ " $name " ]] && continue
                fi
                if [[ -d "$f" ]]; then
                    echo "📁 $name"
                else
                    echo "📄 $name"
                fi
            done | wofi --dmenu --prompt "📂 $path" --width 500 --lines 20 --insensitive --matching fuzzy
        )

        [[ -z "$selected" ]] && break

        if [[ "$selected" == "⬅ Voltar" ]]; then
            return 1
        fi

        local fullpath="$path/${selected:2}"

        if [[ -d "$fullpath" ]]; then
            navigate "$fullpath"
            [[ $? -eq 0 ]] && break
        else
            sudo -E zeditor "$fullpath"
            break
        fi
    done
    return 0
}

main_menu() {
    while true; do
        local main_selection
        main_selection=$(wofi --dmenu --prompt "⚙️ Configurações" --width 400 --lines 10 --insensitive --matching fuzzy <<EOM
🗂️ Abrir .config
❄️ Abrir /etc/nixos
EOM
        )

        [[ -z "$main_selection" ]] && break

        case "$main_selection" in
            "🗂️ Abrir .config")
                navigate "$HOME/.config" fish hypr kitty mpv waybar wofi
                ;;
            "❄️ Abrir /etc/nixos")
                navigate "/etc/nixos"
                ;;
        esac
    done
}

main_menu
