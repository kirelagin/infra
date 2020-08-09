{ config, pkgs, ... }:

{
  config = {
    services.nginx = {
      enable = true;
      package = pkgs.nginxMainline;

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      sslProtocols = "TLSv1 TLSv1.1 TLSv1.2";
      sslCiphers = "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:EDH+aRSA:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS";
      sslDhparam = config.security.dhparams.params.nginx.path;
    };

    security.dhparams = {
      enable = true;
      params = {
        nginx = 2048;
      };
    };

    networking.firewall.allowedTCPPorts = [
      80 443  # TODO: collect from virtualHosts
    ];
  };
}
