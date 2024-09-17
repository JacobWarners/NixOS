{config, pkgs, ...}:

{
services.keyd = {
  enable = true;
  config = ''
    [main]
    caps_lock = ignore
  '';
};
}
