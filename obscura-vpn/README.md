# Obscura VPN for NixOS

This flake packages the upstream Obscura Linux client for `x86_64-linux` and
provides a NixOS module for its system service. The client is built from a
pinned upstream source revision.

## Packages

- `nix build .#cli` builds the `obscura` CLI and service executable.
- `nix build .#gui` builds the GTK desktop client with its launcher, icons,
  AppStream metadata, and license.
- `nix build` builds both clients; the result includes `bin/obscura` and
  `bin/obscura-gui`.

## NixOS module

Add this flake as an input and import `obscura.nixosModules.default`. Then:

```nix
{
  services.obscura.enable = true;
}
```

Enabling the module adds its package to `environment.systemPackages`, creates
the `obscura` group, and starts a systemd service with persistent state,
runtime, and log directories. The service starts at boot and is restarted
automatically if it exits. To allow a user account to control the VPN, run
`sudo obscura add-operator <username>` once after enabling the module. Upstream
checks current group membership when handling commands, so a new login session
is not required.

The NixOS module installs the CLI, service, and GUI from the same package. Its
desktop launcher points directly to that package's GUI executable, avoiding
PATH selecting a stale GUI from another profile. After updating, rebuild and
switch the NixOS configuration, then fully quit and reopen the GUI. If the
version warning remains, check `nix profile list` for a separately installed
older `obscura-gui` package or a user desktop entry that takes precedence.

The upstream project is licensed under GPL-3.0-only with its linking source
exception. Review the upstream license and service terms for your use case.

## Updating Obscura

The flake follows the upstream repository's default branch, while
`flake.lock` records the exact source revision used for reproducible builds.
To fetch a newer upstream revision without updating Nixpkgs or the other
inputs, run:

```sh
nix flake update obscura
```

Review the lockfile change, then rebuild the package and evaluate the NixOS
module before activating the update.
