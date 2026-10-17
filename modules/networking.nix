# Networking, VPN and the SSH daemon.
{ ... }:

{
  networking.networkmanager.enable = true;
  services.resolved.enable = true; # Steam download fix
  services.mullvad-vpn.enable = true;

  # Phone integration & local file sharing — each opens its own firewall ports.
  programs.kdeconnect.enable = true;
  programs.localsend.enable = true;

  # SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    ports = [ 22 ];
  };
}
