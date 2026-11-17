{ config, pkgs, lib, ... }:
let
  logoFile = ../config/fastfetch/logo.txt;
  boxScript = ../config/fastfetch/box.py;

  # Noctalia's fastfetch template (apply.sh) deep-merges its colors into
  # ~/.config/fastfetch/config.jsonc, so that file must be a real, writable
  # file. A Nix-generated symlink would be read-only and the merge would fail.
  # The file is seeded from these settings only when it is missing or still a
  # symlink, the same pattern used for starship.toml in home/shell.nix.
  settings = {
    logo = {
      # "file" (not "file-raw") so $1 placeholders take logo.color.1 from the
      # Noctalia theme.
      type = "file";
      source = "${logoFile}";
      padding = {
        top = 1;
        left = 2;
        right = 4;
      };
    };

    display = {
      # Invisible separator: box.py uses it to split keys from values.
      separator = "⁣";
      key.type = "both";
    };

    modules = [
      { type = "users"; key = "user"; }
      { type = "command"; key = "hname"; text = "hostname"; }
      { type = "uptime"; key = "uptime"; }
      { type = "os"; key = "distro"; }
      { type = "kernel"; key = "kernel"; }
      { type = "wm"; key = "wm"; }
      { type = "terminal"; key = "term"; }
      # Software-only shell line: reads $SHELL and its version, so it is not
      # affected by the wrapper process that runs fetch-box.
      {
        type = "command";
        key = "shell";
        text = "printf '%s %s' \"\${SHELL##*/}\" \"$(\"\$SHELL\" --version 2>/dev/null | grep -oE '[0-9]+(\\.[0-9]+)+' | head -n1)\"";
      }
      { type = "locale"; key = "locale"; }
      { type = "theme"; key = "theme"; }
      "separator"
      "colors"
    ];
  };

  seed = pkgs.writeText "fastfetch-config.jsonc" (builtins.toJSON settings);

  fetchBox = pkgs.writeShellScriptBin "fetch-box" ''
    exec ${pkgs.python3}/bin/python3 ${boxScript} \
      ${logoFile} \
      "$HOME/.config/fastfetch/config.jsonc" \
      ${pkgs.fastfetch}/bin/fastfetch \
      "$HOME/.config/fastfetch/themes/noctalia.jsonc"
  '';
in
{
  home.packages = [ fetchBox ];

  home.activation.fastfetchConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    fastfetch_config="$HOME/.config/fastfetch/config.jsonc"
    if [ ! -e "$fastfetch_config" ] || [ -L "$fastfetch_config" ]; then
      run install -D -m 644 ${seed} "$fastfetch_config"
    fi
  '';
}
