{ config, pkgs, ... }:

{
  # ─── Fonts ───
  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;

    # ─── Packages ───
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      proggyfonts
      ubuntu_font_family
      vazir-fonts
      gyre-fonts
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
    ];

    # ─── Fontconfig ───
    fontconfig = {
      enable = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        serif = [ "Liberation Serif" "Vazirmatn" ];
        sansSerif = [ "Ubuntu" "Vazirmatn" ];
        monospace = [ "Ubuntu Mono" ];
      };
      localConf = ''
        <match target="pattern">
          <test qual="any" name="family"><string>NewCenturySchlbk</string></test>
          <edit name="family" mode="assign" binding="same"><string>TeX Gyre Schola</string></edit>
        </match>
      '';
    };
  };
}
