{ ... }:
{
  # Per-application modules. Each app owns a directory under apps/ holding its
  # nix module alongside the config file it manages, where it has both.
  imports = [
    ./git/git.nix
    ./mise/mise.nix
    ./zsh/zsh.nix
  ];
}
