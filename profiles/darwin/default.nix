{ ... }:

{
  imports = [
    ../base # base profile

    ../../modules/darwin/settings/macos-defaults
  ];

  modules.settings.macos-defaults.settings = {
    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      _FXSortFoldersFirst = true;
      FXPreferredViewStyle = "Clmv"; # column view
      FXDefaultSearchScope = "SCcf"; # search current folder
    };

    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };

    "com.apple.print.PrintingPrefs" = {
      # Automatically quit printer app once the print jobs complete
      "Quit When Finished" = true;
    };

    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };

    # Turn off app auto-update
    "com.apple.commerce".AutoUpdate = false;

    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;

    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      # Add a context menu item for showing the Web Inspector in web views
      WebKitDeveloperExtras = true;
    };
  };

}
