# macos-defaults/restartMap.nix
#
# Maps NSUserDefaults domains to the processes that must be killed
# for their changes to take effect. Processes are killall'd non-fatally
# after each activation in which their domain appears.
#
# Extend via macosDefaults.extraRestartProcesses — do not edit here.

{
  "com.apple.dock" = [ "Dock" ];
  "com.apple.finder" = [ "Finder" ];
  "com.apple.SystemUIServer" = [ "SystemUIServer" ];
  "com.apple.controlcenter" = [ "ControlCenter" ];
  "com.apple.notificationcenter" = [ "NotificationCenter" ];
  "NSGlobalDomain" = [ "cfprefsd" ];
}
