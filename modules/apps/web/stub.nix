{ config, lib, pkgs, ... }:

let
  fqdn = config.networking.hostName
    + lib.optionalString (config.networking.domain != null) ".${config.networking.domain}";

  stub = pkgs.writeTextFile {
    name = "nginx-stub";
    destination = "/stub.html";
    text = ''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <meta charset="utf-8">

        <title>${fqdn}</title>

        <!--[if lt IE 9]>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.js"></script>
        <![endif]-->

        <style>
          html, body {
            height: 100%;
            margin: 0;
          }
          body {
            background-color: #904000;
            display: flex;
            justify-content: center;
            align-items: center;
          }

          p#host {
            color: white;
            font-size: 14em;
            font-family:
              "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",
              Helvetica, Arial, "Lucida Grande", sans-serif;
            cursor: default;
          }
        </style>
      </head>
      <body>

        <p id="host">${config.networking.hostName}</p>

      </body>
      </html>
    '';
  };

in {
  config = {
    assertions = [
      { assertion = config.services.nginx.enable;
        message = "services.nginx.enable must be true";
      }
    ];

    services.nginx = {
      virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
        locations = {
          "=/index.html".alias = "${stub}/stub.html";
          "/".index = "/index.html";
        };
      };
    };
  };
}
