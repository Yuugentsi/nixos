{ config, pkgs, ... }:

# ─── Path ───
let
  privatePath = "/home/ls/ls/samba";
in
{
  # ─── Group ───
  users.groups.sambashare = {};

  # ─── Discovery ───
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
  };

  environment.etc."avahi/services/smb.service".text = ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
        <type>_smb._tcp</type>
        <port>445</port>
      </service>
    </service-group>
  '';

  # ─── Samba ───
  services.samba = {
    enable = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Share";
        "netbios name" = "ls";
        "security" = "user";
        "map to guest" = "bad user";
        "socket options" = "TCP_NODELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "aio read size" = "1";
        "aio write size" = "1";
        "use sendfile" = "yes";
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "server min protocol" = "SMB2";
        "server max protocol" = "SMB3";
        "disable spoolss" = "yes";
      };

      samba = {
        path = privatePath;
        browseable = "yes";
        writable = "yes";
        "guest ok" = "no";
        "valid users" = "ls";
        "force create mode" = "0660";
        "force directory mode" = "0770";
        "force user" = "ls";
        "force group" = "sambashare";
      };
    };
  };

  # ─── Permissions ───
  systemd.tmpfiles.rules = [
    "d /home/ls 0755 ls users -"
    "d /home/ls/ls 0755 ls users -"
    "d ${privatePath} 0770 ls sambashare -"
  ];

  # ─── Firewall ───
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # ─── Password ───
  systemd.services.set-samba-password = {
    description = "Set Samba user password declaratively";
    after = [ "samba-smbd.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      (echo "7777"; echo "7777") | ${pkgs.samba}/bin/smbpasswd -a -s ls
    '';
  };
}
