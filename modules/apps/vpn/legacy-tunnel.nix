# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ ... }:

{
  config = {
    networking.firewall.allowedTCPPorts = [
      65222  # sshtun: raya
    ];

    users.users.router= {
      isSystemUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAwCJ1mMdPz/Tjrk/I09oLHB8V+e8+PW0Ilv5QeD0+7GKYrQyHU/nQYNCxrLgvvBXi7WLbwsUwfeCEbVlfsgIEjcWkZvNOsSz52+daxIb2CirarYHwuzM0tCx5mpcPWE+WxggW2YQP4szXa3u44m/IjRGyiyUAZkQlQbbuI4omJZu4eoYhPpSaHOWIMsIq17hfs271+kNEtSPYXEbc+YVNjZL7twoxUu1xKE5euAi2K30Jz9Bb/rYvC5m05RuwchXHY6lztfPyFi5E/BIH/KA1YbAXasF4cg7NreMZlUJyAoSd8M1qXU6/ZVQz8LowjghDCqW+7Va5NfwQw36zTIRp1KjQhM= raya:54222"
      ];
    };

    services.openssh = {
      extraConfig = ''
        Match User router
          AllowTcpForwarding yes
          X11Forwarding no
          PermitTunnel no
          GatewayPorts yes
          AllowAgentForwarding no
          ForceCommand echo 'Tunnel only'
          ClientAliveInterval 20
          ClientAliveCountMax 2
      '';
    };
  };
}
