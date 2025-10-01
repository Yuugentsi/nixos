function install --description 'Adiciona e instala pacotes no NixOS'
    if test (count $argv) -eq 0
        echo "Erro: forneça pelo menos um pacote para instalar."
        return 1
    end
    set any_added 0
    for pkg in $argv
        if grep -q "\<$pkg\>" /etc/nixos/modules/packages.nix
            echo "Pacote $pkg já está em packages.nix, pulando adição."
        else
            sudo sed -i "/environment.systemPackages = with pkgs; \[/a\      $pkg" /etc/nixos/modules/packages.nix
            set any_added 1
        end
    end
    if test $any_added -eq 1
        sudo nixos-rebuild switch
    else
        echo "Nenhum pacote novo adicionado, pulando nixos-rebuild."
    end
end
