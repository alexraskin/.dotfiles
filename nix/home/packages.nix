{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      curl
      wget
      htop
      tree
      ripgrep
      jq
      gh

      mise
      yt-dlp
      ffmpeg

      oh-my-zsh
      zsh-powerlevel10k
    ];
  };
}
