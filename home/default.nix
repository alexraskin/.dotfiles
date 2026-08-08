{ primaryUser, ... }:
{
  imports = [
    ./packages.nix
    ./dotfiles.nix
    ../apps/config.nix
  ];

  home = {
    username = primaryUser;
    stateVersion = "25.05";
    sessionVariables = {
      # shared environment variables
    };

    file.".hushlogin".text = "";
  };
}
