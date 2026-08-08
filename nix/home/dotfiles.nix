{ config, ... }:
let
  dots = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dots}/${path}";
in
{
  home.file = {
    ".zshrc".source = link "zsh/.zshrc";
    ".p10k.zsh".source = link "p10k/.p10k.zsh";
    ".aerospace.toml".source = link "aerospace/.aerospace.toml";
    ".claude/settings.json".source = link "claude/settings.json";
  };

  xdg.configFile = {
    "ghostty/config".source = link "ghostty/config";
    "ata/config.toml".source = link "ata/config.toml";
  };
}
