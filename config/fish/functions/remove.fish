function remove --description 'Remove one or more packages from packages.nix using fzf'
    if not type -q fzf
        echo "fzf is required. Please install fzf."
        return 1
    end

    # Lista apenas pacotes válidos (ajuste o regex conforme seu padrão)
    set pkgs (grep -oP '^\s*\K[a-zA-Z0-9._+-]+' /etc/nixos/modules/packages.nix | grep -v '^environment\.systemPackages' | grep -v '^with$' | grep -v '^\[' | grep -v '^\]' | grep -v '^-')
    if test (count $pkgs) -eq 0
        echo "No packages found to remove."
        return 1
    end

    # Permite seleção múltipla no fzf
    set selected (printf "%s\n" $pkgs | fzf --prompt="Remove which package(s)? > " --multi)
    if test -z "$selected"
        echo "No package selected."
        return 1
    end

    for pkg in $selected
        sudo sed -i '/^[[:space:]]*'"$pkg"'[[:space:]]*$/d' /etc/nixos/modules/packages.nix
        echo "Removed $pkg from packages.nix."
    end

    sudo nixos-rebuild switch
end
