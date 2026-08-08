{ pkgs, lib, ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig.settings = {
      experimental = true;
      verbose = false;
      auto_install = true;
    };
  };

  # activation script to set up mise configuration
  home.activation.setupMise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  '';
}
