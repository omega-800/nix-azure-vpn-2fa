{ pkgs, ... }:
{
  # networkmanager approach. doesn't require cookie but you'll have to authenticate every time you connect
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      (networkmanager-openconnect.override { withGnome = true; })
    ];
    ensureProfiles = {
      profiles.school = {
        connection = {
          id = "school";
          type = "vpn";
        };
        vpn = {
          # set these to your params
          gateway = "vpn.university.com";
          remote = "vpn.university.com";
          username = "alice@university.com";

          service-type = "org.freedesktop.NetworkManager.openconnect";
          cookie-flags = "1";
          autoconnect-flags = "0";
          protocol = "anyconnect";
          useragent = "AnyConnect";
          authtype = "password";
        };
      };
    };
  };
}
