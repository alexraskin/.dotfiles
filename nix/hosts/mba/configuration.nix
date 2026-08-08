{
  pkgs,
  primaryUser,
  ...
}:
{
  networking = {
    computerName = "alexs-mba";
    hostName = "alexs-mba";
  };

  # host-specific homebrew casks
  homebrew.casks = [
    # "zed"
  ];

  home-manager.users.${primaryUser} = {
    home.packages = with pkgs; [
      # graphite-cli
    ];
  };
}
