{ config, pkgs, lib, ... }:
let
  # Chemins de coffres supplémentaires à inclure même s'ils ne figurent pas
  # dans ~/.config/obsidian/obsidian.json ou hors de $HOME.
  extraVaultPaths = [ ];

  # Découvre tous les coffres Obsidian (obsidian.json + recherche dans $HOME +
  # extraVaultPaths) :
  # - `output` : utilisé par Noctalia (output_path_dynamic) pour écrire directement
  #   un vrai fichier <vault>/.obsidian/snippets/noctalia.css (pas de lien
  #   symbolique, pour que le hot-reload d'Obsidian détecte chaque mise à jour).
  # - `apply`  : appelé en post_hook pour activer le snippet "noctalia" dans
  #   <vault>/.obsidian/appearance.json sans écraser les autres réglages.
  obsidianSyncTheme = pkgs.writeShellApplication {
    name = "obsidian-sync-theme";
    runtimeInputs = [ pkgs.jq pkgs.findutils pkgs.coreutils ];
    text = ''
      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      obsidian_json="$config_home/obsidian/obsidian.json"

      find_obsidian_dirs() {
        {
          if [ -f "$obsidian_json" ]; then
            while IFS= read -r vault; do
              [ -d "$vault" ] && printf '%s/.obsidian\n' "$vault"
            done < <(jq -r '.vaults // {} | .[].path // empty' "$obsidian_json")
          fi

          find "$HOME" -maxdepth 4 -name ".obsidian" -type d 2>/dev/null || true

          ${lib.concatMapStringsSep "\n          " (v: ''[ -d ${lib.escapeShellArg v} ] && printf '%s/.obsidian\n' ${lib.escapeShellArg v}'') extraVaultPaths}
        } | sort -u
      }

      emit_output_paths() {
        while IFS= read -r obsidian_dir; do
          [ -n "$obsidian_dir" ] || continue
          snippets_dir="$obsidian_dir/snippets"
          mkdir -p "$snippets_dir"
          target="$snippets_dir/noctalia.css"
          # Supprime un éventuel ancien lien symbolique pour laisser Noctalia
          # écrire un vrai fichier dans snippets/.
          [ -L "$target" ] && rm -f "$target"
          printf '%s\n' "$target"
        done < <(find_obsidian_dirs)
      }

      enable_snippets() {
        while IFS= read -r obsidian_dir; do
          [ -n "$obsidian_dir" ] || continue
          mkdir -p "$obsidian_dir/snippets"
          appearance="$obsidian_dir/appearance.json"
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
        done < <(find_obsidian_dirs)
      }

      case "''${1:-sync}" in
        output)
          emit_output_paths
          ;;
        apply)
          enable_snippets
          ;;
        sync)
          enable_snippets
          if command -v noctalia >/dev/null 2>&1; then
            noctalia msg templates-apply >/dev/null 2>&1 || true
          fi
          ;;
        *)
          echo "Usage: obsidian-sync-theme {output|apply|sync}" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [ obsidianSyncTheme ];

  # Noctalia rend config/obsidian/noctalia.css directement dans chaque coffre
  # découvert via output_path_dynamic, puis active le snippet via post_hook.
  xdg.configFile = {
    "noctalia/templates/obsidian-theme.css".source = ../config/obsidian/noctalia.css;

    "noctalia/obsidian.toml".text = ''
      [theme.templates.user.obsidian]
      input_path = "templates/obsidian-theme.css"
      output_path_dynamic = "${lib.getExe obsidianSyncTheme} output"
      post_hook = "${lib.getExe obsidianSyncTheme} apply"
    '';
  };

  # Active le snippet dans les coffres existants et demande à Noctalia (s'il
  # tourne) de réappliquer immédiatement les modèles au rebuild.
  home.activation.obsidianTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe obsidianSyncTheme} sync
  '';
}
