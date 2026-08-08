{ ... }:
{
  # system defaults and preferences
  system = {
    startup.chime = false;

    defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        _FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
        FXPreferredViewStyle = "Nlsv"; # list view
      };

      screencapture.location = "~/Documents/Screencaps";

      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        AppleShowAllExtensions = true;

        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        ApplePressAndHoldEnabled = false;
      };

      screensaver.askForPasswordDelay = 300;

      CustomUserPreferences = {
        "com.apple.finder" = {
          WarnOnEmptyTrash = false;
          DisableAllAnimations = true;
        };
        "com.apple.controlcenter" = {
          "NSStatusItem Visible NowPlaying" = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
      };
    };
  };
}
