{
  home.shellAliases =
    let
      domain = "vpn.university.com";
      user = "alice@university.com";
      # you can use any secrets manager for this. this would be an example using sops-nix
      cookie = ''"$(sudo cat /run/secrets/vpn/school/cookie)"'';
      # this would be an example using pass
      # cookie = ''"$(pass school/vpn)"'';
      # or even hardcoded (not recommended)
      # cookie = "value-of-my-cookie";
      # same applies to servercert
      servercert = ''"$(sudo cat /run/secrets/vpn/school/fingerprint)"'';
    in
    {
      # for getting the cookie and fingerprint/servercert
      vpn-cookie = "openconnect-sso -s ${domain} --authenticate json";
      # without systemd or networkmanager. requires the cookie
      vpn-start = ''sudo openconnect --useragent AnyConnect --protocol anyconnect -C ${cookie} --servercert ${servercert} -u ${user} ${domain}'';
      # with systemd service. requires the cookie above as well as nixos configuration, see ./nixos-openconnect.nix
      vpn-svc-start = "sudo systemctl start openconnect-school";
      vpn-svc-stop = "sudo systemctl stop openconnect-school";
      # with networkmanager. requires the nixos configuration but no cookie needed, see ./nixos-networkmanager.nix
      vpn-nm-start = "nmcli con up school";
      vpn-nm-stop = "nmcli con down school";
    };

  # important! if you choose the networkmanager option you have to start nm-applet on login
  # put this in xinitrc (or your window manager) on Xorg, inside of your compositor config on wayland

  # Xorg example
  xdg.configFile."X11/xinitrc".text = ''
    nm-applet &
  '';

  # Wayland example (sway)
  wayland.windowManager.sway.config.startup = [
    { command = "exec nm-applet &"; }
  ];
}
