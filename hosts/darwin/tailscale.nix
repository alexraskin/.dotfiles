{ ... }:
{
  services.tailscale = {
    enable = true;
    overrideLocalDns = true;
  };

  networking.knownNetworkServices = [ "Wi-Fi" ];
}
