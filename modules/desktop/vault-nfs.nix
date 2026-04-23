{ ... }:

let
  vaultShares = [
    "backup"
    "media"
    "music_backup"
    "PlexMediaServer"
    "temp"
  ];

  vaultMountOptions = [
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=10min"
    "x-systemd.mount-timeout=30s"
    "rw"
    "vers=3"
  ];

  mkVaultMount = share: {
    name = "/mnt/vault/${share}";
    value = {
      device = "vault.local:/volume1/${share}";
      fsType = "nfs";
      options = vaultMountOptions;
    };
  };
in
{
  fileSystems = builtins.listToAttrs (map mkVaultMount vaultShares);

  systemd.tmpfiles.rules = [
    "d /mnt/vault 0775 johan users - -"
  ]
  ++ map (share: "d /mnt/vault/${share} 0775 johan users - -") vaultShares;
}
