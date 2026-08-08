{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    global.brewfile = true;

    casks = [
      "nikitabobko/tap/aerospace"
      "shottr"

      # dev
      "ghostty"
      "zed"
      "claude-code"

      # browsers
      "google-chrome"

      # media
      "plex"
      "spotify"

      # fonts
      "font-b612"
      "font-iosevka"

      # other
      "1password"
      "1password-cli"
      "wifiman"
    ];
    brews = [
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
      "mas"
    ];
    taps = [
      "nikitabobko/tap"
    ];
    masApps = {
      "Tailscale" = 1475387142;
      "WhatsApp Messenger" = 310633997;
      "Menu World Time" = 1446377255;
      "Flycut" = 442160987;
      "Passepartout" = 1433648537;
      "Yubico Authenticator" = 1497506650;
      "Xcode" = 497799835;
      "Infuse" = 1136220934;
      "Gifski" = 1351639930;
    };
  };
}
