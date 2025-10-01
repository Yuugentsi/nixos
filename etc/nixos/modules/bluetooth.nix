{ config, pkgs, ... }:

{
  # ─── Bluetooth ───
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
        FastConnectable = true;
        DiscoverableTimeout = 0;
        AutoEnable = true;
      };
      Policy = {
        AutoReconnect = true;
      };
    };
  };

  # ─── Applet ───
  services.blueman.enable = true;

  # ─── Dependencies ───
  services.dbus.enable = true;
  security.rtkit.enable = true;

  # ─── Packages ───
  environment.systemPackages = with pkgs; [ bluez bluez-tools ];
}
