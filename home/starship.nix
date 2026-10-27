{ config, pkgs, lib, inputs, ... }:
{
  # Starship : un seul fichier, ~/.config/starship.toml, généré par Noctalia.
  # Nix ne fournit que le template (lecture seule, comme celui de zellij) ;
  # Noctalia écrit le fichier final, qui reste un vrai fichier modifiable.
  home.packages = [ pkgs.starship ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    starship init fish | source
  '';

  xdg.configFile = {
    # Template rendu par Noctalia : palette et mise en page dans un seul fichier.
    "noctalia/templates/starship.toml".text = ''
      palette = "noctalia"

      "$schema" = "https://starship.rs/config-schema.json"

      [palettes.noctalia]
      blue   = "{{colors.primary.default.hex}}"
      red    = "{{colors.error.default.hex}}"
      green  = "{{colors.tertiary.default.hex}}"
      mauve  = "{{colors.secondary.default.hex}}"

      add_newline = false

      # Tout le prompt reste à gauche, sur une seule ligne.
      format = """
      $os$directory$cmd_duration$character"""

      [os]
      disabled = false
      format = "[$symbol](bold blue) "

      [os.symbols]
      NixOS = ""

      [directory]
      # Garde jusqu'à 8 segments dans le chemin.
      truncation_length = 8

      # Ne coupe pas le chemin au root d'un dépôt Git.
      truncate_to_repo = false

      # Abrège les dossiers parents à une lettre ; garde le dossier actuel entier.
      fish_style_pwd_dir_length = 1

      truncation_symbol = ""

      # $read_only montre le cadenas automatiquement lorsque le dossier
      # courant n'est pas accessible en écriture pour ton utilisateur.
      format = "[$path]($style)[$read_only]($read_only_style) "

      style = "bold mauve"
      read_only = " "
      read_only_style = "bold red"

      [cmd_duration]
      # N'affiche la durée qu'à partir de 500 ms.
      min_time = 500
      format = "[$duration](bold green) "
      show_milliseconds = true

      [character]
      success_symbol = "[❯](bold blue)"
      error_symbol = "[❯](bold red)"
      vimcmd_symbol = "[❮](bold green)"
    '';

    "noctalia/starship.toml".text = ''
      [theme.templates.user.starship]
      input_path = "templates/starship.toml"
      output_path = "$XDG_CONFIG_HOME/starship.toml"
    '';
  };
}
