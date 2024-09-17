{config, pkgs, ...}:

{


environment.systemPackages = with pkgs; [
  keyd
];

services.keyd = {
  enable = true;
  keyboards.default.settings = {
    main = {
      capslock = ignore
};
};
};
}
