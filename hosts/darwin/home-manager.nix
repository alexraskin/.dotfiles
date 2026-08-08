{
  inputs,
  self,
  primaryUser,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "mise-bak";
    users.${primaryUser} = {
      imports = [
        ../../home
      ];
    };
    extraSpecialArgs = {
      inherit inputs self primaryUser;
    };
  };
}
