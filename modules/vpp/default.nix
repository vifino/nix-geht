{ config, pkgs, lib,
vpp-pkgs }:

let
  cfg = config.vpp;
  vpp = vpp-pkgs.vpp;

  MB = 1024 * 1024;

  loglevelType = types.enum [ "emerg" "alert" "crit" "error" "warn" "notice" "info" "debug" "disabled" ];
in
{
  options.vpp = {
    enable = mkEnableOption "Vector Packet Processor";
    pollSleepUsec = mkOption {
      type = with types; nullOr (int);
      default = 100;
      description = ''
        Amount of Microseconds to sleep between each poll, greatly reducing CPU usage,
        at the expense of latency/throughput.
        Defaults to 100us.
      '';
    };
    bootstrap = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Optional startup commands to execute on startup to bootstrap the VPP instance.
      '';
    };
    extraConfig = mkOption {
      type = types.lines;
      #default = "";
      description = ''
        Additional startup config to configure VPP with.
        Add clauses like `dpdk {` here.
      '';
    };
    defaultLogLevel = mkOption {
      type = loglevelType;
      default = "info";
      description = ''
        Set default logging level for logging buffer.
        Defaults to "info".
      '';
    };
    defaultSyslogLogLevel = mkOption {
      type = loglevelType;
      default = "notice";
      description = ''
        Set default logging level for syslog or stderr output.
        Defaults to "notice".
      '';
    };
    statsegSize = mkOption {
      type = types.int;
      default = 32;
      description = ''
        Size (in MiB) of the stats segment.
        Defaults to 32 MiB.
      '';
    };
    mainHeapSize = mkOption {
      type = types.int;
      default = 1024;
      description = ''
        Set the main heap page size (in MiB).
        Defaults to 1024 MiB.
      '';
    };
    buffersPerNuma = mkOption {
      type = types.int;
      default = 16384;
      description = ''
        Set the buffer count per NUMA Node.
        Defaults to 16384 buffers.
      '';
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ vpp ];
    users.groups.vpp = {};

    # Create a VPP Service.
    systemd.services.vpp = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Vector Packet Processor Engine";
      path = [ vpp ]; 
      serviceConfig = {
        Type = "simple";
        ExecStart = "${vpp}/bin/vpp -c /etc/vpp/startup.conf";
        ExecStartPost = "/bin/rm -f /dev/shm/db /dev/shm/global_vm /dev/shm/vpe-api";
      };
    };

    # Write the config files.
    environment.etc."vpp/startup.conf" = {
      enable = true;
      mode = "0644";
      text = ''
        unix {
          nodaemon
          log /var/log/vpp/vpp.log
          cli-listen /run/vpp/cli.sock
          gid vpp
          ${lib.optionalString cfg.pollSleepUsec ''
          poll-sleep-usec ${cfg.pollSleepUsec}
          ''}
          ${lib.optionalString cfg.bootstrap != "" ''
          exec /etc/vpp/bootstrap.vpp
          ''}
        }

        logging {
          default-log-level ${defaultLogLevel}
          default-syslog-log-level ${defaultSyslogLogLevel}
        }

        # Enable APIs.
        api-trace { on }
        api-segment { gid vpp }
        socksvr { default }

        statseg {
          size ${cfg.statsegSize}M
          page-size default-hugepage
          per-node-counters off
        }

        memory {
          main-heap-size ${mainHeapSize}M
          main-heap-page-size default-hugepage
        }
        buffers {
          buffers-per-numa ${buffersPerNuma}
          default data-size 2048 # KiB?
          page-size default-hugepage
        }

        ${lib.optionalString extraConfig != "" ''
        # Extra Config
        ${extraConfig}
        ''}
      '';
    };

    environment.etc."vpp/bootstrap.vpp" = {
      enable = cfg.bootstrap != "";
      mode = "0644";
      text = cfg.bootstrap;
    };

    kernel.sysctl = {
      # Set 64MB of netlink buffer size.
      "net.core.rmem_default" = lib.mkDefault 64 * MB;
      "net.core.wmem_default" = lib.mkDefault 64 * MB;
      "net.core.rmem_max" = lib.mkDefault 64 * MB;
      "net.core.wmem_max" = lib.mkDefault 64 * MB;

      # TODO: Hugepages.
    };
  };
}
