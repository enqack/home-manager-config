{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.modules.applications.paseo;
  system = pkgs.stdenv.hostPlatform.system;
  
  # The flake exposes `default`, `paseo` and `desktop` on Linux.
  #
  # These are NOT interchangeable, and conflating them is what broke this
  # module: `desktop` ships only `bin/paseo-desktop`, the Electron GUI. It
  # carries no `bin/paseo`, so a service pointed at `${desktop}/bin/paseo`
  # fails with status=203/EXEC and, with Restart=on-failure, does so forever.
  #
  # `default` is the package that ships `bin/paseo` and `bin/paseo-server`.
  # The daemon and the CLI must come from it on every platform.
  paseoCli = inputs.paseo.packages.${system}.default;

  # The GUI is Linux-only here and is additive: it does not replace the CLI.
  paseoDesktop = lib.optional pkgs.stdenv.isLinux
    inputs.paseo.packages.${system}.desktop;

  # MUST be the non-detaching invocation. Verify with `paseo daemon --help`.
  daemonArgs = [ "daemon" "start" "--foreground" ];

  # paseoCli here gives the daemon (and the agents it spawns) the `paseo`
  # binary on PATH. It must be the CLI package, not the desktop one, for the
  # same reason ExecStart must.
  #
  # Declared packages first, so their versions win, then the user profile and
  # the system profile.
  #
  # The trailing two are not laziness. This daemon's job is to spawn worktree
  # hooks and agent terminals that run arbitrary toolchains - Paseo shells out
  # to `bash` for every hook, and an agent may reach for nix, go, mage, python
  # or anything else a task needs. A PATH of only the declared packages fails
  # closed and badly: `spawn bash ENOENT` kills worktree setup, and because
  # Paseo runs setup in the BACKGROUND for `paseo run`, the agent then starts
  # anyway in a worktree whose child repos are empty directories. Every git
  # command inside one silently resolves to the PARENT repo, so the failure
  # reports plausible, wrong answers rather than an error.
  #
  # An agent's toolchain cannot be enumerated in advance. Pin what matters,
  # inherit the rest.
  runtimePath = lib.concatStringsSep ":" [
    (lib.makeBinPath ([ paseoCli pkgs.git pkgs.openssh ] ++ cfg.agentPackages))
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/run/current-system/sw/bin"
  ];

  jsonFormat = pkgs.formats.json { };

  # Every voice option defaults to null, meaning "do not emit the key, let
  # Paseo apply its own default". Emitting a null instead would be a lie: the
  # daemon reads it as an explicit value, not as absence. Strip them, and strip
  # the containers that end up empty as a result, so a module with no voice
  # settings produces no `features`/`providers` blocks at all.
  pruneNulls = value:
    if lib.isAttrs value then
      lib.filterAttrs (_: v: v != null && !(lib.isAttrs v && v == { }))
        (lib.mapAttrs (_: pruneNulls) value)
    else value;

  voice = cfg.voice;

  voiceConfig = pruneNulls {
    features = {
      dictation.stt = voice.dictation.stt;
      voiceMode = {
        llm = voice.voiceMode.llm;
        stt = voice.voiceMode.stt;
        tts = voice.voiceMode.tts;
      };
    };
    providers = {
      local.modelsDir = voice.providers.local.modelsDir;
      openai = {
        stt.baseUrl = voice.providers.openai.stt.baseUrl;
        tts.baseUrl = voice.providers.openai.tts.baseUrl;
      };
    };
  };

  usesOpenAiSpeech = lib.any (p: p == "openai") [
    voice.dictation.stt.provider
    voice.voiceMode.stt.provider
    voice.voiceMode.tts.provider
  ];

  speechOptions = { tts ? false }: {
    provider = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "local" "openai" ]);
      default = null;
      description = ''
        Speech provider. Null leaves Paseo's default (local) in place.
      '';
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = if tts then "kokoro-en-v0_19" else "parakeet-tdt-0.6b-v2-int8";
      description = ''
        Model ID. Local models are downloaded at daemon startup into
        providers.local.modelsDir if missing.
      '';
    };
  } // lib.optionalAttrs (!tts) {
    language = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "en";
      description = ''
        STT language. This applies ONLY to the OpenAI provider. The local
        Parakeet models ignore it: v2 is English-only and v3 auto-detects,
        so setting it alongside provider = "local" changes nothing.

        When voiceMode.stt.language is unset, Paseo falls back to
        dictation.stt.language, then to "en".
      '';
    };
  } // lib.optionalAttrs tts {
    speakerId = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 0;
      description = ''
        Speaker index for the local TTS model. Local provider only.
      '';
    };

    speed = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.int lib.types.float);
      default = null;
      example = 1.1;
      description = ''
        Playback rate multiplier for the local TTS model, 1.0 being the
        model's native rate. Local provider only.

        Undocumented upstream: only the PASEO_VOICE_LOCAL_TTS_SPEED
        environment variable is described. The config key is real -
        speech/providers/local/config.js resolves it from
        features.voiceMode.tts.speed - but being undocumented it carries no
        compatibility promise, so treat a future daemon dropping it as
        expected rather than as a bug in this module.
      '';
    };
  };
in
{
  options.modules.applications.paseo = {
    enable = lib.mkEnableOption "paseo";

    agentPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.claude-code ]";
      description = ''
        Agent CLIs the daemon must be able to execute, appended to its PATH.

        The daemon runs with a pinned PATH, so it does not inherit your login
        shell's. A provider whose binary is absent from that PATH reports
        status "unavailable" in `paseo provider ls` and in the GUI, even
        though the CLI is installed and works in your terminal - the daemon
        simply cannot see it. Listing the package here is what makes the
        provider usable.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/paseo-voice.env";
      description = ''
        Path to a systemd EnvironmentFile read by the daemon unit.

        This exists because of a collision between two decisions made
        elsewhere in this module: the generated config.json lands in the Nix
        store (world-readable, so an API key must never be written into it),
        and the daemon runs with a pinned Environment, so it does NOT inherit
        OPENAI_STT_API_KEY or friends from your login shell. Without this
        option there is no path by which an OpenAI speech key reaches the
        daemon at all, and voice fails at request time rather than at switch.

        Linux only. launchd has no equivalent; on Darwin the key has to be
        supplied another way.
      '';
    };

    # Mirrors the doc's shape (features.dictation / features.voiceMode /
    # providers.*) rather than inventing a flatter one, so a setting here maps
    # to the upstream docs by name. See https://paseo.sh/docs/voice.
    voice = {
      dictation.stt = speechOptions { };

      voiceMode = {
        llm = {
          provider = lib.mkOption {
            type = lib.types.nullOr
              (lib.types.enum [ "claude" "codex" "opencode" ]);
            default = null;
            example = "claude";
            description = ''
              Agent provider that orchestrates voice mode. Paseo reuses an
              agent already installed and authenticated on this machine, so
              the same PATH caveat as agentPackages applies: a provider the
              daemon cannot execute is not usable here.
            '';
          };

          model = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "haiku";
            description = "Model the voice orchestration agent runs.";
          };
        };

        stt = speechOptions { };
        tts = speechOptions { tts = true; };
      };

      providers = {
        local.modelsDir = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "~/.paseo/models/local-speech";
          description = ''
            Where local ONNX speech models are stored and downloaded to.
            Defaults to $PASEO_HOME/models/local-speech.
          '';
        };

        # No apiKey option, deliberately: this config.json is a store file, so
        # any key placed here would be world-readable on the host and retained
        # in the store. Supply credentials through environmentFile instead.
        openai = {
          stt.baseUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "https://api.openai.com/v1";
            description = ''
              Endpoint for dictation and voice mode speech-to-text. Falls back
              to OPENAI_STT_BASE_URL, then OPENAI_BASE_URL. Affects only
              Paseo's speech traffic, not Codex or other OpenAI-backed tools.
            '';
          };

          tts.baseUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "https://api.openai.com/v1";
            description = ''
              Endpoint for voice mode text-to-speech. Resolved independently
              of the STT endpoint, so the two may differ. Falls back to
              OPENAI_TTS_BASE_URL, then OPENAI_BASE_URL.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # The CLI in your terminal, plus the GUI on Linux.
      home.packages = [ paseoCli ] ++ paseoDesktop;

      # Declarative and therefore IMMUTABLE: this lands as a read-only symlink
      # into the store, so the daemon cannot persist anything changed through
      # the Paseo UI, and every key it would otherwise write must be declared
      # here. An earlier revision declared only listen/hostnames/mcp.enabled,
      # which silently dropped the rest on the next switch - including
      # mcp.injectIntoAgents, the setting that gives spawned agents the Paseo
      # MCP tools.
      #
      # If you ever want the UI to be able to change settings, this whole
      # block has to go; there is no half-measure.
      warnings = lib.optional
        (usesOpenAiSpeech && pkgs.stdenv.isLinux && cfg.environmentFile == null) ''
          modules.applications.paseo: an OpenAI speech provider is selected but
          environmentFile is unset. The daemon runs with a pinned Environment
          and so cannot see OPENAI_STT_API_KEY / OPENAI_TTS_API_KEY from your
          shell; voice will fail at request time.
        '';

      # Generated through pkgs.formats.json rather than builtins.toJSON so the
      # result is jq-formatted: this file is meant to be read by a human
      # debugging the daemon, and a single-line blob is not.
      home.file.".paseo/config.json".source =
        jsonFormat.generate "paseo-config.json" (lib.recursiveUpdate voiceConfig {
        "$schema" = "https://paseo.sh";
        version = 1;
        daemon = {
          listen = "127.0.0.1:6767";
          hostnames = [ "localhost" ];
          mcp = {
            enabled = true;
            injectIntoAgents = true;
          };
          browserTools.enabled = false;
          autoArchiveAfterMerge = false;
          enableTerminalAgentHooks = true;
          appendSystemPrompt = "";
          relay.enabled = true;
        };
        agents.providers = {
          codex.enabled = false;
          copilot.enabled = false;
          opencode.enabled = false;
          pi.enabled = false;
        };
      });
    }

    (lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.startServices = "sd-switch";

      systemd.user.services.paseo = {
        Unit = {
          Description = "Paseo AI Agent Coordinator Daemon";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];

          # The desktop GUI also starts a daemon, and there is no way to tell
          # it not to - it has no opt-out setting or env var. Ownership is
          # arbitrated by a PID lock at ~/.paseo/paseo.pid, first come. Since
          # this unit is WantedBy=default.target it starts at login, before
          # the GUI is ever launched, so normally it wins and the GUI attaches.
          #
          # When it loses - GUI already up, as after a mid-session switch - the
          # daemon exits 1 with "Another Paseo daemon is already running". That
          # is a legitimate state, not a fault worth retrying into forever, and
          # each attempt costs about 950ms of CPU and peaks near 300MB. Bound
          # it: three tries in a minute, then land in `failed` and stay there.
          StartLimitIntervalSec = 60;
          StartLimitBurst = 3;
        };
        Service = {
          Type = "exec";
          ExecStart = "${paseoCli}/bin/paseo ${lib.concatStringsSep " " daemonArgs}";
          Restart = "on-failure";
          RestartSec = 5;
          Environment = [
            "PASEO_HOME=%h/.paseo"
            "PATH=${runtimePath}"
          ];
        } // lib.optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = toString cfg.environmentFile;
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf pkgs.stdenv.isDarwin {
      launchd.agents.paseo = {
        enable = true;
        config = {
          ProgramArguments = [ "${paseoCli}/bin/paseo" ] ++ daemonArgs;
          RunAtLoad = true;
          KeepAlive.SuccessfulExit = false;
          ProcessType = "Background";
          WorkingDirectory = config.home.homeDirectory;
          StandardErrorPath = "${config.home.homeDirectory}/.paseo/daemon.err.log";
          StandardOutPath = "${config.home.homeDirectory}/.paseo/daemon.out.log";
          EnvironmentVariables = {
            PASEO_HOME = "${config.home.homeDirectory}/.paseo";
            PATH = "${runtimePath}:/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };
    })
  ]);
}
