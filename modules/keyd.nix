{config, pkgs, ...}:

{


environment.systemPackages = with pkgs; [
  keyd
];

services.keyd = {
  enable = true;
  config = ''
    [main]
    caps_lock = ignore
  '';
};
}
