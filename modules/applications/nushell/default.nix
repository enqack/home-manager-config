{ config, pkgs, lib, ... }:

let
  cfg = config.modules.applications.nushell;

  nuConfigDir = "${config.xdg.configHome}/nushell";
  nuLibDir = "${nuConfigDir}/lib";
  nuScriptsDir = "${nuConfigDir}/nu_scripts";

  nuScriptsPkg =
    if (pkgs ? nu_scripts) then pkgs.nu_scripts else null;

  # nixpkgs nu_scripts installs under share/nu_scripts
  nuScriptsRoot = "${nuScriptsDir}/share/nu_scripts";

  # -----------------------------
  # Build-time generated init scripts
  # -----------------------------
  zoxideInit = pkgs.runCommand "zoxide.nu" {} ''
    ${pkgs.zoxide}/bin/zoxide init nushell > $out
  '';

  starshipInit = pkgs.runCommand "starship.nu" {} ''
    ${pkgs.starship}/bin/starship init nu > $out
  '';

  # IMPORTANT: atuin init touches XDG/HOME. Provide writable locations at build-time.
  atuinInit = pkgs.runCommand "atuin.nu" {
    nativeBuildInputs = [ pkgs.coreutils ];
  } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$TMPDIR/xdg-config"
    export XDG_DATA_HOME="$TMPDIR/xdg-data"
    export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
    mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"
    ${pkgs.atuin}/bin/atuin init nu > $out
  '';

  # -----------------------------
  # Starship settings
  # -----------------------------
  starshipSettings = {
    add_newline = false;

    command_timeout = 750;
    scan_timeout = 30;

    format = ''
      [\[](bold red)$env_var[\]](bold red)[\[](bold red)$username[@](bold green)$hostname $directory[\]](bold red) $git_branch$git_status$git_commit$git_state$nix_shell$direnv$docker_context$container$python$nodejs$rust$golang$java$dotnet$lua$zig$jobs$battery
      ${"$"}{custom.status} $character
    '';

    custom = {
      status = {
        command = "printenv STARSHIP_STATUS";
        when = "test -n \"$(printenv STARSHIP_STATUS)\"";
        format = "$output";
        style = "bold red";
      };
    };

    time = {
      disabled = false;
      format = "[$time]($style)";
      time_format = "%Y-%m-%d %H:%M:%S";
      style = "bold green";
    };

    username = {
      show_always = true;
      format = "[$user]($style)";
      style_user = "bold yellow";
      style_root = "bold red";
    };

    hostname = {
      ssh_only = false;
      format = "[$hostname]($style)";
      style = "bold blue";
    };

    directory = {
      format = "[$path]($style)";
      style = "bold magenta";
      truncation_length = 0;
      truncate_to_repo = false;
      read_only = " ";
      read_only_style = "bold red";
    };

    status = {
      disabled = false;
      format = "[$status]($style)";
      style = "bold red";
      success_symbol = "0";
      map_symbol = false;
    };

    cmd_duration = {
      disabled = false;
      show_milliseconds = true;
      min_time = 0;
      show_notifications = true;
      format = "[$duration]($style)";
      style = "bold cyan";
    };

    env_var = {
      disabled = false;
      variable = "PROMPT_TIME";
      format = "[$env_value]($style)";
      style = "bold green";
      default = "0000-00-00 00:00:00";
    };

    character = {
      success_symbol = "[>](bold red)";
      error_symbol = "[>](bold red)";
      vimcmd_symbol = "[<](bold green)";
      vimcmd_visual_symbol = "[<](bold yellow)";
      vimcmd_replace_symbol = "[<](bold purple)";
    };

    git_branch = {
      disabled = false;
      format = " [$symbol$branch]($style)";
      symbol = " ";
      style = "bold purple";
    };

    git_status = {
      disabled = false;
      format = "([ \\[$all_status$ahead_behind\\] ]($style))";
      style = "bold red";
      stashed = "≡";
      ahead = "⇡";
      behind = "⇣";
      diverged = "⇕";
      modified = "!";
      staged = "+";
      untracked = "?";
      renamed = "»";
      deleted = "✘";
      conflicted = "=";
    };

    git_commit = {
      disabled = false;
      commit_hash_length = 7;
      format = " [(\\($hash\\))]($style)";
      style = "bold green";
    };

    git_state = {
      disabled = false;
      format = " [\\($state( $progress_current/$progress_total)\\)]($style)";
      style = "bold yellow";
    };

    git_metrics.disabled = true;

    nix_shell = {
      disabled = false;
      format = " via [$symbol$state( \\($name\\))]($style)";
      symbol = "❄️  ";
      style = "bold blue";
    };

    direnv = {
      disabled = false;
      format = " [$symbol$loaded/$allowed]($style)";
      symbol = "direnv ";
      style = "bold bright-yellow";
    };

    docker_context = {
      disabled = false;
      format = " via [$symbol$context]($style)";
      symbol = "🐳 ";
      style = "blue bold";
      only_with_files = true;
    };

    kubernetes.disabled = true;
    aws.disabled = true;
    gcloud.disabled = true;
    azure.disabled = true;
    openstack.disabled = true;

    python = {
      disabled = false;
      format = " via [${"$"}symbol${"$"}version( \\($virtualenv\\))]($style)";
      symbol = "🐍 ";
      style = "yellow bold";
    };

    golang = {
      disabled = false;
      format = " via [$symbol($version)]($style)";
      symbol = "🐹 ";
      style = "bold cyan";
    };

    rust = {
      disabled = false;
      format = " via [$symbol($version)]($style)";
      symbol = "🦀 ";
      style = "bold red";
    };

    nodejs = {
      disabled = false;
      format = " via [$symbol($version)]($style)";
      symbol = " ";
      style = "bold green";
    };

    java.disabled = false;
    dotnet.disabled = false;
    lua.disabled = false;
    zig.disabled = false;
    nim.disabled = false;

    ocaml.disabled = true;
    haskell.disabled = true;
    perl.disabled = true;
    ruby.disabled = true;

    sudo = {
      disabled = false;
      format = " [as $symbol]($style)";
    };

    jobs = {
      disabled = false;
      format = " [$symbol$number]($style)";
      symbol = "✦";
      style = "bold blue";
    };

    battery.disabled = true;
    memory_usage.disabled = true;
    follow_symlinks = true;
  };

  # -----------------------------
  # Nushell Toolkit
  # -----------------------------
  nuToolkit = pkgs.writeText "toolkit.nu" ''
    def trim-out [] { str trim }

    # def --env cd [dir?: string] {
    #   # No arg -> home
    #   if ($dir == null) {
    #     builtin cd ~
    #     return
    #   }

    #   # Preserve 'cd -'
    #   if $dir == "-" {
    #     builtin cd -
    #     return
    #   }

    #   # First try normal path semantics (tilde, relative, absolute)
    #   let expanded = ($dir | path expand)

    #   if ($expanded | path exists) {
    #     builtin cd $expanded
    #     return
    #   }

    #   # If it's a path-like string (contains / or starts with ~), don't zoxide it.
    #   # This prevents typos like ~/Muisc from teleporting you somewhere random.
    #   if ($dir | str contains "/") or ($dir | str starts-with "~") {
    #     error make {
    #       msg: $"Directory not found: ($expanded)"
    #     }
    #   }

    #   # Fallback: zoxide keyword search (no path syntax)
    #   let dest = (try { ^zoxide query --exclude (pwd) $dir | str trim } catch { "" })

    #   if ($dest | is-empty) {
    #     error make { msg: $"No match for: ($dir)" }
    #   } else {
    #     builtin cd $dest
    #   }
    # }

    # def --env td [] {
    #   let dest = (try { ^zoxide query - | str trim } catch { "" })
    #   if ($dest | is-empty) {
    #     error make { msg: "No previous directory" }
    #   } else {
    #     builtin cd $dest
    #   }
    # }


    def l [...args: string] { ^eza --color=always --icons=always --git ...$args }
    def la [...args: string] { ^eza --color=always --icons=always --git -la ...$args }
    def ll [...args: string] { ^eza --color=always --icons=always --git -lF --group ...$args }
    def lt [...args: string] { ^eza --color=always --icons=always --git -lt modified --group ...$args }

    def gft [] { ^git fetch }
    def gpl [] { ^git pull }
    def gps [] { ^git push }

    def gs [] {
      ^git status --porcelain=v1
      | lines
      | parse "{xy} {path}"
      | update xy { str trim }
    }

    def gitdiff [ --name-only (-n) ] {
      if $name_only { ^git diff --name-only | lines } else { ^git diff --color=always | ^delta }
    }
  '';

  # -----------------------------
  # Nushell Integrations
  # -----------------------------
  nuIntegrations = pkgs.writeText "integrations.nu" (''
    # Shell integration: record keys, not bool.
    $env.config.shell_integration = (
      $env.config.shell_integration
      | upsert osc2 true
      | upsert osc7 true
      | upsert osc8 true
      | upsert osc9_9 true
      | upsert osc133 true
      | upsert osc633 true
      | upsert reset_application_mode true
    )

    # -----------------------------
    # Prompt env vars for Starship
    # -----------------------------
    def prompt_time_string [] {
      date now | format date "%Y-%m-%d %H:%M:%S"
    }

    def starship_status_string [] {
      let code = ($env.LAST_EXIT_CODE? | default 0)
      "(rc: CODE)" | str replace "CODE" ($code | into string)
    }

    let pre_prompt = ($env.config.hooks.pre_prompt? | default [])
    $env.config.hooks.pre_prompt = (
      $pre_prompt
      | append {||
          $env.PROMPT_TIME = (prompt_time_string)
          $env.STARSHIP_STATUS = (starship_status_string)
        }
    )

    # Carapace completions
    if (which carapace | is-not-empty) {
      $env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

      let carapace_completer = { |ctx|
        let tokens = (
          if ($ctx | describe | str starts-with "record") and ($ctx | columns | any { |c| $c == "spans" }) {
            $ctx.spans
          } else if ($ctx | describe | str starts-with "list") {
            $ctx
          } else {
            $ctx | values
          }
        )

        let tokens = ($tokens | where { |x| ($x | describe) == "string" })

        if ($tokens | is-empty) { return [] }

        let cmd = ($tokens | first)
        let args = ($tokens | skip 1)

        carapace $cmd nushell ...$args
        | from json
      }

      $env.config = ($env.config
        | upsert completions.external.enable true
        | upsert completions.external.max_results 200
        | upsert completions.external.completer $carapace_completer
      )
    }

    # Direnv
    if (which direnv | is-not-empty) {
      let direnv_hook = { ||
        if not ('.envrc' | path exists) {
          return []
        }

        let out = (direnv export json | complete)
        if $out.exit_code != 0 {
          return []
        }

        let envar = (try { $out.stdout | from json } catch { null })
        if ($envar | describe) == "record" {
          load-env $envar
        }

        []
      }

      $env.config = ($env.config
        | upsert hooks.env_change.PWD (
            ($env.config.hooks.env_change.PWD? | default [])
            | append $direnv_hook
          )
      )
    }
  '' + lib.optionalString (cfg.enableIntegrations && nuScriptsPkg != null) ''
    # nu_scripts (nixpkgs layout: share/nu_scripts)
    source ${nuScriptsRoot}/custom-completions/git/git-completions.nu
    source ${nuScriptsRoot}/custom-completions/nix/nix-completions.nu
    source ${nuScriptsRoot}/custom-completions/cargo/cargo-completions.nu
    source ${nuScriptsRoot}/custom-completions/podman/podman-completions.nu
    source ${nuScriptsRoot}/custom-completions/eza/eza-completions.nu
    source ${nuScriptsRoot}/custom-completions/glow/glow-completions.nu
    source ${nuScriptsRoot}/custom-completions/tar/tar-completions.nu
    source ${nuScriptsRoot}/custom-completions/zoxide/zoxide-completions.nu
    source ${nuScriptsRoot}/aliases/git/git-aliases.nu
    source ${nuScriptsRoot}/aliases/eza/eza-aliases.nu
    source ${nuScriptsRoot}/modules/fuzzy/fuzzy_command_search.nu
    source ${nuScriptsRoot}/modules/fuzzy/fuzzy_history_search.nu
    source ${nuScriptsRoot}/modules/background_task/task.nu
    source ${nuScriptsRoot}/modules/formats/from-cpuinfo.nu
    source ${nuScriptsRoot}/modules/formats/from-dmidecode.nu
    source ${nuScriptsRoot}/modules/formats/from-env.nu
    # source ${nuScriptsRoot}/modules/formats/remove-diacritics.nu
    source ${nuScriptsRoot}/modules/formats/to-ini.nu
    source ${nuScriptsRoot}/modules/formats/to-number-format.nu

  '' + ''
    # Zellij autostart
    if (which zellij | is-not-empty) {
      let tty = ($env.TERM? | default "") != ""
      let in_mux = ($env.ZELLIJ? | default "") != "" or ($env.TMUX? | default "") != ""
      let disabled = ($env.NO_ZELLIJ? | default "") != ""
      let in_ssh = ($env.SSH_CONNECTION? | default "") != ""

      if $tty and (not $in_mux) and (not $disabled) and ($in_ssh | is-empty) {
        try { zellij attach -c main }
      }
    }
  '');

in
{
  options.modules.applications.nushell = {
    enable = lib.mkEnableOption "nushell";
    enableIntegrations = lib.mkEnableOption "integrations (carapace/direnv/zellij/atuin/nu_scripts)";
  };

  config = lib.mkIf cfg.enable {

    home.packages =
      (with pkgs; [
        eza zoxide starship fzf delta
      ])
      ++ lib.optionals cfg.enableIntegrations [
        pkgs.carapace
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.zellij
        pkgs.atuin
      ]
      ++ lib.optionals (cfg.enableIntegrations && nuScriptsPkg != null) [
        nuScriptsPkg
      ];

    home.file."${nuLibDir}/toolkit.nu".source = nuToolkit;
    home.file."${nuLibDir}/integrations.nu".source = nuIntegrations;

    home.file."${nuLibDir}/zoxide.nu".source = zoxideInit;
    home.file."${nuLibDir}/starship.nu".source = starshipInit;
    home.file."${nuLibDir}/atuin.nu".source = atuinInit;

    home.file."${nuScriptsDir}" = lib.mkIf (cfg.enableIntegrations && nuScriptsPkg != null) {
      source = nuScriptsPkg;
      recursive = true;
    };

    programs.nushell = {
      enable = true;

      settings = {
        show_banner = false;

        completions = {
          external = {
            enable = true;
            max_results = 200;
          };
        };

        history = {
          max_size = 100000;
          sync_on_enter = true;
          file_format = "sqlite";
          isolation = true;
        };
      };

      extraConfig = ''
        # Vendor init (generated at build time)
        source ${nuLibDir}/zoxide.nu
        source ${nuLibDir}/starship.nu

        # Your functions
        source ${nuLibDir}/toolkit.nu

        # Integrations (optional)
        ${lib.optionalString cfg.enableIntegrations ''
          source ${nuLibDir}/integrations.nu
          source ${nuLibDir}/atuin.nu
        ''}
      '';
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = starshipSettings;
    };
  };
}
