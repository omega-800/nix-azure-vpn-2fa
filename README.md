# nix-azure-vpn-2fa

This repo shows how to set up an AnyConnect vpn client to connect to Azure AD vpn servers.    

## setup 

1. Copy either `./nix/nixos-openconnect.nix` or `./nix/nixos-networkmanager.nix` to your `configuration.nix` and edit the relevant attributes (like user or domain).
2. Copy `./nix/home.nix` to your `home-configuration.nix` and edit the appropriate attributes again. 
3. If not using networkmanager: Get your cookie and fingerprint by executing the `vpn-cookie` alias and store them in your secret-management solution.
