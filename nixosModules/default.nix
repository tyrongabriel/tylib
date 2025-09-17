{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  environment.systemPackages = with pkgs-stable; [
    cowsay
  ];
}
