# modules/network.nix
{ config, pkgs, ... }:

{
  networking = {
    # ─── General Networking ───
    hostName = "nixos";
    networkmanager.enable = true;

    # ─── Wi-Fi Optimization ───
    wireless = {
      enable = true;
      regdomain = "BR";
    };

    networkmanager = {
      wifi.powersave = false; # ESTA É A OPÇÃO CORRETA
      settings.wifi.bg-scan = false;
    };

    # ─── DNS Configuration ───
    nameservers = [
      "9.9.9.9"
    ];

    # ─── Firewall ───
    firewall.enable = true;
  };
}
