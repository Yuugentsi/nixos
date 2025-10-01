{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
    ./modules/bluetooth.nix
    ./modules/locale.nix
    ./modules/samba.nix
    ./modules/fonts.nix
    ./modules/themes.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.nameservers = [ "9.9.9.9" ];

  users.users.ls = {
    isNormalUser = true;
    description = "oki";
    extraGroups = [ "networkmanager" "wheel" "disk" "plugdev" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
    initialPassword = "changeme";
  };

  services.printing.enable = true;
  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    configPackages = [ pkgs.xdg-desktop-portal-wlr ];
  };

  programs.fish.enable = true;
  programs.nm-applet.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.gtk.enable = true;

  system.stateVersion = "25.05";
}
