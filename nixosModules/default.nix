{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
