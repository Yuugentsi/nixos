{ config, pkgs, ... }:

# ─── Unstable ───
let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
{
  config = {
    # ─── Packages ───
    environment.systemPackages = with pkgs; [
      # ─── GUI ───
      easytag
      keepassxc
      kitty
      librewolf
      mpv
      sayonara
      spotify
      unstable.telegram-desktop
      zed-editor
      firefox
      # ─── Hyprland ───
      gammastep
      grim
      slurp
      swayidle
      swaylock
      waybar
      wofi

      # ─── XFCE ───
      mate.engrampa
      gvfs
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.xfconf
      xfce.mousepad
      xfce.xfwm4-themes

      # ─── CLI ───
      android-tools
      brightnessctl
      ffmpeg
      fzf
      git
      playerctl
      python3
      python3Packages.pip
      unzip
      xclip
      zip
      yt-dlp
      gallery-dl
      pulseaudio
    ];
  };
}
