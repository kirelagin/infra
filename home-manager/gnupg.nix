{ config , pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";

    settings = {
      no-greeting = true;
      charset = "utf-8";

      with-keygrip = true;
      keyid-format = "none";
      with-subkey-fingerprint = true;
      list-options = "show-unusable-subkeys";

      cert-digest-algo = "SHA256";
      personal-digest-preferences = "SHA256";
      personal-cipher-preferences = "AES256 AES192 AES";
      default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";

      # When verifying a signature made from a subkey, ensure that the cross
      # certification "back signature" on the subkey is present and valid.
      # This protects against a subtle attack against subkeys that can sign.
      # Defaults to --no-require-cross-certification.  However for new
      # installations it should be enabled.
      require-cross-certification = true;

      # Some old Windows platforms require 8.3 filenames.  If your system
      # can handle long filenames, uncomment this.
      no-mangle-dos-filenames = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome;
    enableSshSupport = true;
    enableExtraSocket = true;
  };
}
