{ config, pkgs, ... }:

{
  # ─── Packages ───
  environment.systemPackages = with pkgs; [
    adw-gtk3
    libsForQt5.qt5ct
    qt6ct
  ];

  # ─── Environment ───
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
