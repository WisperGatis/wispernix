{ config, pkgs, lib, inputs, ... }:
{
  # Gestionnaire de fichiers Luciole (noctalia-dev/luciole).
  # Le module fourni par le flake installe le paquet ; la config reste
  # modifiable depuis l'interface (settings.toml).
  imports = [ inputs.luciole.homeModules.default ];

  programs.luciole.enable = true;

  # Noctalia rend le modèle fourni par Luciole vers
  # ~/.config/luciole/colors.toml, que Luciole recharge dès qu'il est écrit.
  xdg.configFile = {
    "noctalia/templates/luciole-colors.toml".source =
      "${inputs.luciole}/assets/noctalia/colors.toml";

    "noctalia/luciole.toml".text = ''
      [theme.templates.user.luciole]
      input_path = "templates/luciole-colors.toml"
      output_path = "$XDG_CONFIG_HOME/luciole/colors.toml"
    '';
  };
}
