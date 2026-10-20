{ config, pkgs, lib, inputs, ... }:
{
  programs.zed-editor = {
    enable = true;

    # Extensions Zed à installer.
    # Les langages HTML, CSS, JSON, JS/TS et C/C++ sont déjà pris en charge
    # nativement par Zed, donc pas besoin de les mettre ici.
    extensions = [
      "nix"
      "rust"
      "csharp"
      "go"
      "toml"
      "dockerfile"
      "yaml"
      "svelte"
      "vue"
      "tailwindcss"
    ];

    # Outils rendus visibles dans le PATH de Zed :
    # LSP, formatteurs, linters, compilateurs et outils du terminal intégré.
    extraPackages = with pkgs; [
      # Nix
      nixd
      pkgs.nixfmt
      statix
      deadnix

      # Rust
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy

      # C / C++
      clang-tools
      cmake
      ninja
      gdb

      # C#
      dotnet-sdk_8
      csharp-ls

      #hardware funny things.
      unstable.mangohud

      # Go
      go
      gopls
      gofumpt
      golangci-lint

      # JavaScript / TypeScript / Node
      nodejs
      typescript
      typescript-language-server
      vscode-langservers-extracted
      eslint_d
      prettierd
      biome

      # Web stack, Vue, Svelte, Tailwind, données/configuration
      tailwindcss-language-server
      svelte-language-server
      vue-language-server
      yaml-language-server
      dockerfile-language-server
      taplo
      marksman

      # Outils pratiques pour le terminal Zed
      git
      just
      jq
      ripgrep
      fd
    ];

    userSettings = {
      vim_mode = true;
      base_keymap = "VSCode";

      # Charge .envrc quand un projet utilise direnv.
      load_direnv = "shell_hook";

      # Active le formatage lors de chaque sauvegarde, sauf override local.
      format_on_save = "on";

      terminal = {
        shell = "system";
        working_directory = "current_project_directory";
        dock = "bottom";
      };

      # Zed cherchera ces LSP installés dans le PATH.
      # Je ne force pas les autres LSP ici : leurs noms logiques dépendent
      # des extensions Zed et ils sont normalement détectés automatiquement.
      lsp = {
        nix = {
          binary = {
            path_lookup = true;
          };
        };

        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
        };
      };

      # OpenCode utilisé comme agent AI ACP.
      # Requiert pkgs.opencode, fourni soit par ton nixpkgs,
      # soit par l'overlay opencode-nix.
      agent_servers = {
        OpenCode = {
          command = lib.getExe pkgs.opencode;
          args = [ "acp" ];
        };

        claude-acp = {
          type = "registry";
        };
      };

      languages = {
        "Nix" = {
          format_on_save = "on";

          formatter = {
            external = {
              command = "nixfmt";
              arguments = [ ];
            };
          };
        };

        "Rust" = {
          format_on_save = "on";
        };

        "C" = {
          format_on_save = "on";
        };

        "C++" = {
          format_on_save = "on";
        };

        "C#" = {
          format_on_save = "on";
        };

        "Go" = {
          format_on_save = "on";
        };

        "JavaScript" = {
          format_on_save = "on";
        };

        "TypeScript" = {
          format_on_save = "on";
        };

        "JSX" = {
          format_on_save = "on";
        };

        "TSX" = {
          format_on_save = "on";
        };

        "HTML" = {
          format_on_save = "on";
        };

        "CSS" = {
          format_on_save = "on";
        };

        "JSON" = {
          format_on_save = "on";
        };

        "YAML" = {
          format_on_save = "on";
        };

        "Dockerfile" = {
          format_on_save = "on";
        };

        "Svelte" = {
          format_on_save = "on";
        };

        "Vue.js" = {
          format_on_save = "on";
        };

        "TOML" = {
          format_on_save = "on";
        };

        "Markdown" = {
          format_on_save = "on";
        };
      };
    };
  };

  # neovim config with the usual LV
  programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
  };

  xdg.configFile."nvim" = {
      source = ../config/nvim;
      recursive = true;
  };
}
