let
  machines = {
    blanka = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBNvtklymKYtjj8hFhTYp59odfbN0fhVh2mi/NbNBtkR" ];
    bruna = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvC0F5+t3oO4Ewg2xZDAJ4mw05Dmnm4koaMlTQOpfhc" ];
    home = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/HU6zwd740qIHBHLsnQXCy+nAftR/qpY14PhuXwAFT" ];
    kirFw = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDlQzaZ4LkkXy3fWc90VJDQwmSVWCOmZmAxPa3PRnu4" ];
    orkolora = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3nyFzdEt8Jem3n83kf6q70OIEAAasAXJRC6U49GFvm" ];
  };

  kirelagin = [
    "age1yubikey1qdjwvsyg7fcje5uxe2lhhrtsmp394jjak9p3pyn9pf9h7cl925mck39a05j"  # disaster
    "age1yubikey1qt9t95u5thtq56sz3vh3arqmawk659df24h666c57ehafyz54fkszfz98x5"  # kirelagin
  ];
in

{
  "user.age".publicKeys = kirelagin ++ builtins.concatMap (xs: xs) (builtins.attrValues machines);

  "backups/bruna/password.age".publicKeys = kirelagin ++ machines.bruna;
  "backups/bruna/b2-creds.age".publicKeys = kirelagin ++ machines.bruna;

  "mailserver.age".publicKeys = kirelagin ++ machines.bruna;
  "wireguard.age".publicKeys = kirelagin ++ machines.bruna;
}
