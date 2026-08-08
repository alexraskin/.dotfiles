{ self, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      # disabled due to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
    };
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
  };
}
