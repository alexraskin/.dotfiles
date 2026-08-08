{ inputs, self, ... }:

name:
{
  system,
  user,
  hostname,
}:
inputs.darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit inputs self hostname;
    currentSystemName = name;
    primaryUser = user;
  };

  modules = [
    ../hosts/nix-settings.nix
    ../hosts/darwin/settings.nix
  ];
}
