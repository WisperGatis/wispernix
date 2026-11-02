{ config, pkgs, lib, inputs, ... }:
{
  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Very fun lines for KDE wallet.
  # THIS IS ON HOLD.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd = {
    enableGnomeKeyring = true;
    kwallet.enable = false;
  };

  services.desktopManager.plasma6.enable = true;
  services.desktopManager.budgie.enable = true;

  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR =
  lib.mkForce "${pkgs.gnome-gsettings-overrides or pkgs.budgie-desktop}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";

  programs.niri.enable = true;
  programs.hyprland.enable = true;
  # hyprlock needs its own PAM service to check the password.
  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = { };
  # Power profiles (performance / balanced / power-saver) for the desktop.
  services.power-profiles-daemon.enable = true;
  programs.mango.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.xserver.enable = true;
  services.displayManager.sessionPackages = [
    pkgs.unstable.mango

    # Umbriel session entry (uses its start-umbriel launcher).
    ((pkgs.runCommand "umbriel-session"
      { passthru.providedSessions = [ "umbriel" ]; }
      ''
        mkdir -p $out/share/wayland-sessions
        cat > $out/share/wayland-sessions/umbriel.desktop <<EOF
        [Desktop Entry]
        Name=Umbriel
        Comment=Umbriel Wayland compositor
        Exec=${pkgs.unstable.umbriel}/bin/start-umbriel
        Type=Application
        DesktopNames=Umbriel
        EOF
      ''))
  ];

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = false;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Ajouter COSMIC.
  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  # GPU screen recorder?
  programs.gpu-screen-recorder = {
    enable = true;
  };

  programs.ssh.askPassword = lib.mkForce
  "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
     PATH="$HOME/.cargo/bin:$PATH";
  };
}
