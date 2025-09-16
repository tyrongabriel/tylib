{
  config,
  pkgs,
  pkgs-stables,
  ...
}:
{
  environment.systemPackages = with pkgs-stables; [
    cowsay
  ];
}
