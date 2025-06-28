lib: pkgs:

pkgs.writeShellScriptBin "yubi-oath-backup" ''
  ykman="${lib.getBin pkgs.yubikey-manager}/bin/ykman"
  gpg="${lib.getBin pkgs.gnupg}/bin/gpg"
  curl="${lib.getBin pkgs.curl}/bin/curl"

  dir="/tmp/oath-backup"
  pubkey="afterthought-02.asc"
  receiver="disaster@kir.elagin.me"


  die() {
    echo "$@" >&2
    exit 1
  }


  if [ -z "$1" ]; then
    die "Usage: $0 [<username>] <service>"
  fi

  if [ -z "$2" ]; then
    username="kirelagin@gmail.com"
    service="$1"
  else
    username="$1"
    service="$2"
  fi

  account="$service:$username"


  mkdir -p "$dir" || die "Cannot create working dir"

  $ykman info >/dev/null || die "YubiKey not detected"

  if ! [ -f "$dir/$pubkey" ]; then
    $curl -sS "https://bruna.kir.elagin.me/$pubkey" -o "$dir/$pubkey" -C - || die "Cannot download the key"
  fi

  export GNUPGHOME="$dir/gnupg"
  mkdir -p "$GNUPGHOME" || die "Cannot create a temporary gnupg home"
  chmod go-rwx "$GNUPGHOME" || die "Cannot chmod gnupg home"
  $gpg -q --import < "$dir/$pubkey" >/dev/null || die "Cannot import the key"

  echo "You are creating a credential for: $account"
  read -p "OATH secret: " -s secret
  echo ""

  $ykman oath accounts add --touch --issuer "$service" "$username" "$secret" || die "Cannot save the credential to yubikey"

  mkdir -p "$dir/acc" || die "Cannot create the directory for backups"
  echo "$secret" | $gpg --trust-model=always -er "$receiver" > "$dir/acc/$account.asc" || die "Cannot save the backup"

  echo "Your backup was saved to '$dir/acc/$account.asc'"
  printf "Your first OATH code is: "
  $ykman oath accounts code -s "$account" || die "Cannot get first OATH code"
''
