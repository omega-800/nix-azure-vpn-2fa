{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    optionalString
    mapAttrs'
    mkForce
    ;
  ocfg = config.networking.openconnect;
in
{
  # secrets can be set through sops-nix or any other secret management tool as described in ./home.nix
  sops.secrets = {
    "vpn/school/fingerprint" = { };
    "vpn/school/cookie" = { };
  };
  environment.systemPackages = with pkgs; [
    openconnect
    # don't forget to add the extra flake input
    inputs.openconnect-sso.packages.${sys.system}.openconnect-sso
  ];
  networking.openconnect.interfaces.school = {
    # change these
    gateway = "vpn.university.com";
    user = "alice@university.com";

    autoStart = false;
    protocol = "anyconnect";
    extraOptions = {
      # here you can change the commands to pass or anything else you like
      cookie = ''"$(cat ${config.sops.secrets."vpn/school/cookie".path})"'';
      servercert = ''"$(cat ${config.sops.secrets."vpn/school/fingerprint".path})"'';
    };
  };
  systemd.services = mapAttrs' (name: _: {
    name = "openconnect-${name}";
    value =
      let
        icfg = ocfg.interfaces.${name};
      in
      {
        # TODO: nixpkgs PR
        # here we have to override the ExecStart command to support command substitution.
        serviceConfig.ExecStart = mkForce (
          concatStringsSep " " (
            [
              "/bin/sh -c '${ocfg.package}/bin/openconnect"
            ]
            ++ (mapAttrsToList (
              name: value: "--${name}" + (optionalString (!(value == true)) " ${value}")
            ) icfg.extraOptions)
            ++ [
              (optionalString (icfg.protocol != null) "--protocol ${icfg.protocol}")
              (optionalString (icfg.user != null) "-u ${icfg.user}")
              (optionalString (icfg.certificate != null) "--certificate ${icfg.certificate}")
              (optionalString (icfg.privateKey != null) "--sslkey ${icfg.privateKey}")
              "${icfg.gateway}'"
            ]
          )
        );
      };
  }) ocfg.interfaces;
}
