{ pkgs, ... }:

let
  superhostsDeny = pkgs.fetchurl {
    url = "https://hosts.ubuntu101.co.za/superhosts.deny;
    sha256 = " 00
      kdmyz6mgf24c4sd1ifdyijdgl0rqvg1xgzsc0000wkyckrh95m "; # placeholder
  };
in
{
  environment.etc."
      hosts.deny "   .source = superhostsDeny;
}




