{ ... }:

{
  config = {
    services.nsd = {
      enable = true;
      interfaces = [];
      verbosity = 2;
    };

    networking.firewall.allowedUDPPorts = [ 53 ];
    networking.firewall.allowedTCPPorts = [ 53 ];
  };
}
