{config, pkgs, ...}:

{


environment.systemPackages = with pkgs; [
  keyd
];

services.keyd = {
  enable = true;
  keyboards."AT Translated Set 2 keyboard".settings = {
    main = {
      capslock = "ignore";
};
};
};
}
