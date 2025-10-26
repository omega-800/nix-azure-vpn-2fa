{
  description = "azure-vpn-2fa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # do not forget to add this input if using the openconnect version
    openconnect-sso = {
      # TODO: override original openconnect-sso inputs to include poetry2nix overlay instead of relying on fork
      url = "github:ThinkChaos/openconnect-sso/fix/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _: {
    nixosModules =
      let
        openconnect = ./nix/nixos-openconnect.nix;
      in
      {
        inherit openconnect;
        default = openconnect;
        networkmanager = ./nix/nixos-networkmanager.nix;
      };

    homeModules = {
      default = ./nix/home.nix;
    };
  };
}
