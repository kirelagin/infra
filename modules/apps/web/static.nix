{ config, ... }:

{
  config = {
    assertions = [
      { assertion = config.services.nginx.enable;
        message = "services.nginx.enable must be true";
      }
    ];

    services.nginx = {
      virtualHosts = {
        "${config.networking.hostName}.${config.networking.domain}" = {
          default = true;
          forceSSL = true;
          enableACME = !config.boot.isContainer;
          locations."/" = {
            root = "/var/www";
          };
        };
      };
    };
  };
}
