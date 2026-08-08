{
  pkgs,
  inputs,
  self,
  primaryUser,
  ...
}:
{
  imports = [
    ./homebrew.nix
    ./settings.nix
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  # nix config
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # disabled due to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
    };
    # nix-darwin manages nix + /etc/nix/nix.conf (installed via the official
    # nixos.org installer, which does not enable flakes on its own).
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix-homebrew = {
    user = primaryUser;
    enable = true;
    autoMigrate = true;
    trust = {
      casks = [ "nikitabobko/tap/aerospace" ];
      formulae = [ "alexraskin/tap/ata" ];
    };
  };

  # home-manager config
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "mise-bak";
    users.${primaryUser} = {
      imports = [
        ../home
      ];
    };
    extraSpecialArgs = {
      inherit inputs self primaryUser;
    };
  };

  # macOS-specific settings
  system.primaryUser = primaryUser;

  programs.zsh.enable = true;

  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.zsh;
  };
  environment = {
    systemPath = [
      "/opt/homebrew/bin"
    ];
    pathsToLink = [
      "/Applications"
      "/share/oh-my-zsh"
      "/share/zsh-powerlevel10k"
    ];
  };
}
