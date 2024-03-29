{ config, pkgs, ... }: {
  services = {
    syncthing = {
      enable = true;
      user = "johan";
      dataDir = "/home/johan/test_syncthing";
      configDir = "/home/johan/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "kubernetes" = {
            id =
              "C4B74PA-4D4IQLC-ZNWGDAS-RHFXUZJ-E7QAU3N-TUVYGP4-K62ENZA-ARU2NQZ";
          };
        };
      };
    };
  };
}
