{
  description = "Obscura VPN client packages and NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    obscura.url = "github:Sovereign-Engineering/obscuravpn-client";
    obscura.inputs.nixpkgs.follows = "nixpkgs";
    obscura.inputs.rust-overlay.follows = "rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      obscura,
      rust-overlay,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      upstream = obscura.packages.${system};

      mkPackage =
        {
          name,
          paths,
          installDesktop ? false,
          guiProgram ? null,
        }:
        pkgs.symlinkJoin {
          inherit name paths;
          postBuild = ''
            mkdir -p "$out/share/licenses/${name}"
            cp ${obscura}/LICENSE "$out/share/licenses/${name}/LICENSE"
            ${lib.optionalString installDesktop ''
              install -Dm644 ${obscura}/linux/common/net.obscura.vpn.gui.desktop \
                "$out/share/applications/net.obscura.vpn.gui.desktop"
              substituteInPlace "$out/share/applications/net.obscura.vpn.gui.desktop" \
                --replace-fail "Exec=obscura-gui %u" "Exec=${guiProgram}/bin/obscura-gui %u"
              install -Dm644 ${obscura}/linux/common/net.obscura.vpn.gui.metainfo.xml \
                "$out/share/metainfo/net.obscura.vpn.gui.metainfo.xml"
              for size in 64 128 256; do
                install -Dm644 "${obscura}/linux/common/icons/''${size}x''${size}/net.obscura.vpn.gui.png" \
                  "$out/share/icons/hicolor/''${size}x''${size}/apps/net.obscura.vpn.gui.png"
              done
            ''}
          '';
          meta = {
            description = "Obscura VPN ${if installDesktop then "desktop client" else "CLI and service"}";
            homepage = "https://obscura.com";
            license = "GPL-3.0-only WITH GPL-3.0-linking-source-exception";
            platforms = [ system ];
          };
        };

      # The upstream rust-cli-bin output currently omits OBSCURA_VERSION even
      # though the GUI and official Linux package builds set it. Use the
      # version file exported by the same upstream flake so IPC versions match.
      cliUpstream = upstream.rust-cli-bin.overrideAttrs (old: {
        preBuild = ''
          export OBSCURA_VERSION="$(cat ${upstream.version})"
          ${old.preBuild or ""}
        '';
      });

      cli = mkPackage {
        name = "obscura-cli";
        paths = [ cliUpstream ];
      };

      gui = mkPackage {
        name = "obscura-gui";
        paths = [ upstream.rust-gui-bin ];
        installDesktop = true;
        guiProgram = upstream.rust-gui-bin;
      };

      combined = mkPackage {
        name = "obscura";
        paths = [
          cli
          gui
        ];
        installDesktop = true;
        guiProgram = gui;
      };
    in
    {
      packages.${system} = {
        inherit cli gui;
        default = combined;
        obscura = combined;
      };

      nixosModules.default = args: import ./nixos-module.nix (args // { defaultPackage = combined; });
      nixosModules.obscura = self.nixosModules.default;

      checks.${system}.nixos-module = pkgs.testers.runNixOSTest {
        name = "obscura-nixos-module";
        nodes.machine = { ... }: {
          imports = [ self.nixosModules.default ];
          services.obscura.enable = true;
          systemd.services.obscura.serviceConfig.ExecStart =
            lib.mkForce "${pkgs.writeShellScript "obscura-test-service" ''
              ${pkgs.systemd}/bin/systemd-notify --ready
              exec ${pkgs.coreutils}/bin/sleep infinity
            ''}";
        };
        testScript = ''
          machine.start()
          machine.wait_for_unit("obscura.service")
          machine.succeed("getent group obscura")
          machine.succeed("test -d /var/lib/obscura")
          machine.succeed("test -d /run/obscura")
          machine.succeed("test -d /var/log/obscura")
          machine.succeed("test \"$(stat -c %G /var/lib/obscura)\" = obscura")
        '';
      };
    };
}
