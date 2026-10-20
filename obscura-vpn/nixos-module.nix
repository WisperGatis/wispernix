{
  config,
  lib,
  defaultPackage,
  ...
}:
let
  cfg = config.services.obscura;
in
{
  options.services.obscura = {
    enable = lib.mkEnableOption "the Obscura VPN service";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.obscura.packages.x86_64-linux.default";
      description = "Obscura package containing the CLI and desktop client.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    users.groups.obscura = { };

    systemd.services.obscura = {
      description = "Obscura VPN";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "notify";
        ExecStart = "${cfg.package}/bin/obscura service";
        FileDescriptorStoreMax = 8;
        Group = "obscura";
        UMask = "0007";
        StateDirectory = "obscura";
        StateDirectoryMode = "0750";
        RuntimeDirectory = "obscura";
        RuntimeDirectoryMode = "0750";
        RuntimeDirectoryPreserve = "restart";
        LogsDirectory = "obscura";
        LogsDirectoryMode = "0750";
        Restart = "always";
        RestartSec = 1;
        RestartSteps = 5;
        RestartMaxDelaySec = 30;
      };
    };
  };
}
