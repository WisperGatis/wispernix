{ config, pkgs, lib, ... }:
let
  # Chemins de coffres supplémentaires à lier même s'ils ne figurent pas encore
  # dans ~/.config/obsidian/obsidian.json.
  extraVaultPaths = [ ];

  # Lie ~/.config/obsidian/noctalia.css dans chaque coffre Obsidian connu
  # (.obsidian/snippets/noctalia.css) et active le snippet dans appearance.json
  # sans écraser les autres réglages d'apparence.
  obsidianSyncTheme = pkgs.writeShellApplication {
    name = "obsidian-sync-theme";
    runtimeInputs = [ pkgs.jq pkgs.coreutils ];
    text = ''
      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      theme_file="$config_home/obsidian/noctalia.css"
      obsidian_json="$config_home/obsidian/obsidian.json"

      mkdir -p "$(dirname "$theme_file")"
      if [ ! -e "$theme_file" ]; then
        printf '/* En attente du premier rendu Noctalia. */\n' > "$theme_file"
      fi

      sync_vault() {
        vault="$1"
        [ -d "$vault" ] || return 0

        snippets_dir="$vault/.obsidian/snippets"
        mkdir -p "$snippets_dir"
        ln -sfn "$theme_file" "$snippets_dir/noctalia.css"

        appearance="$vault/.obsidian/appearance.json"
        if [ -f "$appearance" ]; then
          tmp=$(mktemp)
          if jq '
            .enabledCssSnippets = (
              ((.enabledCssSnippets // []) + ["noctalia"]) | unique
            )
          ' "$appearance" > "$tmp"; then
            mv "$tmp" "$appearance"
          else
            rm -f "$tmp"
          fi
        else
          printf '{\n  "enabledCssSnippets": [\n    "noctalia"\n  ]\n}\n' > "$appearance"
        fi
      }

      if [ -f "$obsidian_json" ]; then
        while IFS= read -r vault; do
          [ -n "$vault" ] && sync_vault "$vault"
        done < <(jq -r '.vaults // {} | .[].path // empty' "$obsidian_json")
      fi

      ${lib.concatMapStringsSep "\n      " (v: "sync_vault ${lib.escapeShellArg v}") extraVaultPaths}
    '';
  };
in
{
  home.packages = [ obsidianSyncTheme ];

  # Noctalia rend config/obsidian/noctalia.css (modèle) vers
  # ~/.config/obsidian/noctalia.css, même schéma que helix (home/editors.nix)
  # et wezterm (home/terminals.nix).
  xdg.configFile = {
    "noctalia/templates/obsidian-theme.css".source = ../config/obsidian/noctalia.css;

    "noctalia/obsidian.toml".text = ''
      [theme.templates.user.obsidian]
      input_path = "templates/obsidian-theme.css"
      output_path = "$XDG_CONFIG_HOME/obsidian/noctalia.css"
    '';
  };

  # Relie et active le snippet dans tous les coffres existants à chaque activation HM.
  home.activation.obsidianTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe obsidianSyncTheme}
  '';
}
