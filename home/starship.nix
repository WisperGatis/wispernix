{ config, pkgs, lib, inputs, ... }:
{
  # Starship : le prompt est déclaré ici, mais Noctalia génère le fichier
  # final (palette + mise en page) dans ~/.config/starship.noctalia.
  # On ne crée jamais ~/.config/starship.toml, pour ne pas entrer en conflit
  # avec les fichiers de Noctalia.
  home.packages = [ pkgs.starship ];

  home.sessionVariables.STARSHIP_CONFIG =
    "${config.home.homeDirectory}/.config/starship.noctalia";

  programs.fish.interactiveShellInit = lib.mkAfter ''
    starship init fish | source
  '';

  xdg.configFile = {
    # Template rendu par Noctalia : les {{colors...}} sont remplacés par
    # les couleurs matugen du fond d'écran courant.
    "noctalia/templates/starship.toml".text = ''
      # Starship : généré par Noctalia, ne pas éditer à la main.
      palette = "noctalia"

      "$schema" = "https://starship.rs/config-schema.json"

      [palettes.noctalia]
      primary   = "{{colors.primary.default.hex}}"
      secondary = "{{colors.secondary.default.hex}}"
      tertiary  = "{{colors.tertiary.default.hex}}"
      error     = "{{colors.error.default.hex}}"

      add_newline = false

      # Tout le prompt reste à gauche, sur une seule ligne.
      format = """
      $os$directory$cmd_duration$character"""

      [os]
      disabled = false
      format = "[$symbol](bold primary) "

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
      # $read_only montre le cadenas quand le dossier n'est pas accessible en écriture.
      format = "[$path]($style)[$read_only]($read_only_style) "
      style = "bold secondary"
      read_only = " "
      read_only_style = "bold error"

      [cmd_duration]
      # N'affiche la durée qu'à partir de 500 ms.
      min_time = 500
      format = "[$duration](bold tertiary) "
      show_milliseconds = true

      [character]
      success_symbol = "[❯](bold primary)"
      error_symbol = "[❯](bold error)"
      vimcmd_symbol = "[❮](bold tertiary)"
    '';

    "noctalia/starship.toml".text = ''
      [theme.templates.user.starship]
      input_path = "templates/starship.toml"
      output_path = "$XDG_CONFIG_HOME/starship.noctalia"
    '';
  };
}
