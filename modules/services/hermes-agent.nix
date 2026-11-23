# SPDX-FileCopyrightText: Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, pkgs, ... }:

let
  hostHome = "/mnt/state/hermes/home";
  workspaceDir = "/mnt/state/hermes/workspace";
  dataDir = "/mnt/data/hermes";
  workspaceInstructions = pkgs.writeText "hermes-workspace-AGENTS.md" ''
    # Workspace storage

    `${workspaceDir}` is the default working directory, shared by sessions that use it.
    It persists across container restarts but is not backed up. Use it for scratch work.
    Save valuable final deliverables and any files you want to keep in `${dataDir}`,
    which is included in the regular file backup.
  '';
  guestHermes = config.containers.hermes.config.services.hermes-agent;
  guestHome = "${guestHermes.stateDir}/.hermes";
  desktopPluginsDir = "${guestHome}/desktop-plugins";
  # Reserve this 64 Ki-ID range for Hermes on Bruna, above nspawn's pick range.
  privateUsersBase = 1879048192;
  hermesId = 976;
  hermesUserManager = "user@${toString hermesId}.service";
  shiftedId = toString (privateUsersBase + hermesId);
  veth = "ve-hermes";
  domain = config.networking.domain;
  webappHost = "agents.s.${domain}";
  webappUrl = "https://${webappHost}";
  webappPort = 9120;
  oidcClient = "hermes";
  oidcPolicy = "owner_only";
  oidcScopes = [ "openid" "profile" "email" "offline_access" ];
  addresses = {
    hostAddress = "172.31.148.1";
    localAddress = "172.31.148.2";
  };
  advancedDelegation = pkgs.runCommand "advanced-delegation" {
    src = "${flakes.hermes-official-plugins}/advanced-delegation";
  } ''
    cp -r "$src" "$out"
  '';
  writableOfficialPlugins = {
    memory-wiki = [
      "plugin.yaml"
      "__init__.py"
      "dashboard/manifest.json"
      "dashboard/dist/index.js"
      "dashboard/plugin_api.py"
      "dashboard/memory_wiki_core.py"
      "desktop/plugin.js"
    ];
  };
  readingWidth = pkgs.runCommand "hermes-reading-width" { } ''
    install -Dm644 ${../../pkgs/hermes-plugins/reading-width.js} "$out/plugin.js"
  '';
  lock = lib.importJSON ../../flake.lock;
  hermesInput = lock.nodes.${lock.nodes.${lock.root}.inputs.hermes-agent};
  hermesVersion = lib.removePrefix "v" hermesInput.original.ref;
  hermesPackage = guestHermes.package;
  nameservers = lib.filter (address: !(lib.hasInfix ":" address)) config.networking.nameservers;
  exportInGuest = pkgs.writeShellScript "hermes-export" ''
    set -eu
    umask 077
    tmp=$(${pkgs.coreutils}/bin/mktemp -d -- "${workspaceDir}/.hermes-backup.XXXXXXXXXX")
    trap '${pkgs.coreutils}/bin/rm -rf -- "$tmp"' EXIT
    export HERMES_HOME=${guestHome} HOME=${guestHermes.stateDir} TMPDIR="$tmp" TZ=UTC
    # Bundled skills can inherit Nix's pre-1980 store mtime. Match zipfile's
    # year check, including its conversion of fractional seconds.
    ${hermesPackage.hermesVenv}/bin/python3 - <<'PY'
from calendar import timegm
import os
from pathlib import Path
from stat import S_ISREG
from time import localtime

home = Path(os.environ['HERMES_HOME'])
profiles = home / 'profiles'
homes = [home, *(profiles.glob('*') if not profiles.is_symlink() else ())]
normalized = timegm((1980, 1, 2, 0, 0, 0)) * 10**9
for profile in homes:
    skills = profile / 'skills'
    if profile.is_symlink() or skills.is_symlink():
        continue
    for directory, _, files in os.walk(skills):
        for name in files:
            path = Path(directory) / name
            info = path.lstat()
            if S_ISREG(info.st_mode) and not 1980 <= localtime(info.st_mtime).tm_year <= 2107:
                os.utime(path, ns=(info.st_atime_ns, normalized), follow_symlinks=False)
PY
    ${lib.getExe hermesPackage} \
      backup --output "$tmp/hermes.zip" >&2
    ${pkgs.coreutils}/bin/cat -- "$tmp/hermes.zip"
  '';
in
{
  networking.nat = {
    enable = true;
    externalInterface = config.networking.defaultGateway.interface;
    internalInterfaces = [ veth ];
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = oidcClient;
      client_name = "Hermes";
      authorization_policy = oidcPolicy;
      public = true;
      token_endpoint_auth_method = "none";
      require_pkce = true;
      pkce_challenge_method = "S256";
      redirect_uris = [ "${webappUrl}/auth/callback" ];
      grant_types = [ "authorization_code" "refresh_token" ];
      response_types = [ "code" ];
      scopes = oidcScopes;
    }
  ];

  services.nginx.virtualHosts.${webappHost} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${addresses.localAddress}:${toString webappPort}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  systemd.tmpfiles.rules = map (path: "d ${path} 0750 ${shiftedId} ${shiftedId} - -") [ hostHome workspaceDir dataDir ] ++ [
    "C ${workspaceDir}/AGENTS.md 0640 ${shiftedId} ${shiftedId} - ${workspaceInstructions}"
  ];

  containers.hermes = addresses // {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    privateUsers = privateUsersBase;
    # Fixed UID ranges otherwise default to no root image ownership adjustment.
    extraFlags = [ "--private-users-ownership=auto" ];
    bindMounts = lib.genAttrs [ workspaceDir dataDir ] (_: { isReadOnly = false; }) // {
      ${guestHome} = {
        hostPath = hostHome;
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }:
    let
      upstreamPackage = flakes.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      gateway = config.systemd.services.hermes-agent;
      homeSetupScript = "${gateway.environment.HERMES_HOME}/home-setup.sh";
      # Keep this marker in the transient home, independent of XDG overrides.
      homeSetupMarker = "${gateway.environment.HOME}/.cache/hermes/home-setup-done";
    in
    {
      imports = [ flakes.hermes-agent.nixosModules.default ];

      system.stateVersion = "26.05";
      networking.nameservers = nameservers;
      networking.firewall.interfaces.eth0.allowedTCPPorts = [ webappPort ];
      nix.enable = false;
      environment.variables.NIX_REMOTE = "daemon";
      environment.etc."nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';
      # nix.registry is inactive with nix.enable = false. Keep the input's
      # store-path context so the guest closure includes the pinned checkout.
      environment.etc."nix/registry.json".text = builtins.toJSON {
        version = 2;
        flakes = [
          {
            exact = true;
            from = { type = "indirect"; id = "nixpkgs"; };
            to = {
              type = "path";
              path = flakes.nixpkgs.outPath;
              inherit (flakes.nixpkgs) rev narHash lastModified;
            };
          }
        ];
      };

      users.users.hermes.uid = hermesId;
      users.groups.hermes.gid = hermesId;
      systemd.tmpfiles.rules = [
        "d ${desktopPluginsDir} 0750 hermes hermes - -"
        "L+ ${desktopPluginsDir}/hermes-reading-width - - - - ${readingWidth}"
        # Retire the old standalone Desktop link without following it.
        "r ${desktopPluginsDir}/nix-managed-memory-wiki - - - -"
      ];

      services.hermes-agent = {
        enable = true;
        # Upstream uses group-writable config when the guest CLI is installed.
        addToSystemPackages = true;
        package = upstreamPackage.override {
          version = hermesVersion;
          # Use the guest's stable tools instead of upstream's binary bundles.
          pmPackages = {
            ffmpeg = pkgs.ffmpeg-headless;
            inherit (pkgs) ripgrep uv;
            node = pkgs.nodejs_26;
            pnpm = pkgs.pnpm_12;
            inherit (upstreamPackage) python;
          };
        };
        workingDirectory = workspaceDir;
        extraPackages = [ pkgs.nix ];
        extraPlugins = [ advancedDelegation ];
        # Install ordinary files with fresh mtimes for ZIP backup. Hermes can
        # then publish the writable Desktop copy and stamp its pairing marker.
        hermesHomeFiles = lib.concatMapAttrs (name: files:
          lib.listToAttrs (map (file: {
            name = "plugins/nixos-${name}/${file}";
            # The module copies store paths but treats nested store strings as text.
            value = builtins.path { path = "${flakes.hermes-official-plugins}/${name}/${file}"; };
          }) files)
        ) writableOfficialPlugins;
        settings = {
          plugins = {
            enabled = [ "advanced-delegation" ] ++ builtins.attrNames writableOfficialPlugins;
            disabled = [
              "hermes-achievements"
              # Bundled auth backends auto-load unless explicitly disabled.
              "dashboard_auth/basic"
              "dashboard_auth/drain"
              "dashboard_auth/nous"
              "dashboard_auth/session_token"
            ];
          };
        };
      };

      # Hermes's native managed scope pins only deployment wiring; it does not
      # replace the user's config.yaml or .env, or lock settings globally.
      environment.etc."hermes/config.yaml".source = (pkgs.formats.yaml { }).generate "hermes-webapp.yaml" {
        webapp = {
          enabled = true;
          # The pinned gateway accepts loopback or wildcard binds only.
          host = "0.0.0.0";
          port = webappPort;
          public_url = webappUrl;
        };
        dashboard = {
          trusted_proxies = [ addresses.hostAddress ];
          # A blank OIDC env secret falls back to YAML; pin both as public.
          oauth.self_hosted.client_secret = "";
        };
      };
      environment.etc."hermes/.env".text = ''
        HERMES_DASHBOARD_OIDC_ISSUER=https://auth.s.${domain}
        HERMES_DASHBOARD_OIDC_CLIENT_ID=${oidcClient}
        HERMES_DASHBOARD_OIDC_SCOPES=${lib.concatStringsSep " " oidcScopes}
        HERMES_DASHBOARD_OIDC_CLIENT_SECRET=
      '';

      systemd.services.hermes-home-setup = {
        description = "Set up the Hermes guest home";
        # Let a fresh user manager see any units installed by the optional setup.
        before = [ hermesUserManager ];
        wantedBy = [ hermesUserManager ];
        unitConfig.ConditionPathExists = [ homeSetupScript "!${homeSetupMarker}" ];
        environment = {
          inherit (gateway.environment) HOME HERMES_HOME NIX_REMOTE;
          # Use the final PATH instead of adding the default service tools again.
          PATH = lib.mkForce gateway.environment.PATH;
        };
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "20s";
          TimeoutStopSec = "2s";
          WorkingDirectory = gateway.environment.HOME;
          inherit (gateway.serviceConfig)
            User Group UMask NoNewPrivileges PrivateTmp ProtectHome ProtectSystem ReadWritePaths;
        };
        script = ''
          set -e
          ${lib.getExe pkgs.bash} "$HERMES_HOME/home-setup.sh"
          mkdir -p -- "$HOME/.cache/hermes"
          touch -- "$HOME/.cache/hermes/home-setup-done"
        '';
      };

      systemd.services.hermes-agent = {
        wants = [ "hermes-home-setup.service" ];
        after = [ "hermes-home-setup.service" ];
        serviceConfig = {
          ReadWritePaths = [ dataDir ];
          SupplementaryGroups = [ "systemd-journal" ];
        };
        environment = {
          # Opt out of the upstream all-or-nothing settings write guard.
          HERMES_MANAGED = lib.mkForce "false";
          NIX_REMOTE = "daemon";
          HERMES_MANAGED_DIR = "/etc/hermes";
        };
      };
    };
  };

  systemd.services."container@hermes".serviceConfig = {
    MemoryMax = "1G";
    MemorySwapMax = "2G";
  };

  backups.streams.hermes = {
    filename = "hermes.zip";
    command = toString (pkgs.writeShellScript "hermes-backup-stream" ''
      exec ${pkgs.systemd}/bin/systemd-run --machine=hermes --uid=hermes \
        --pipe --wait --quiet ${exportInGuest}
    '');
  };
}
