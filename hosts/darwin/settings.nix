{
  pkgs,
  primaryUser,
  hostname,
  ...
}:
{
  imports = [
    ./macos-defaults.nix
    ./homebrew.nix
    ./aerospace.nix
    ./home-manager.nix
  ];

  networking = {
    computerName = hostname;
    hostName = hostname;
  };

  system.primaryUser = primaryUser;

  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.zsh;
  };

  environment = {
    systemPath = [
      "/opt/homebrew/bin"
    ];
    pathsToLink = [ "/Applications" ];
  };
}
