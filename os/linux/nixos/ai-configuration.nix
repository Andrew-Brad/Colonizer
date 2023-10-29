{ config, pkgs, ... }:

let
  myRepo = import ./path/to/repo { inherit pkgs; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos> # Enable the Home Manager module for NixOS
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.Bobo = {
    isNormalUser = true;
    home = "/home/Bobo";
    description = "Bobo's user";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for Bobo and add to docker group
    openssh.authorizedKeys.keys = [ "your_ssh_public_key" ];
    packages = with pkgs; [ broot htop ]; # Install broot and htop for Bobo
  };

  services.openssh.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  # Home Manager configuration for the Bobo user
  home-manager.users.Bobo = { pkgs, ... }: {
    home.packages = with pkgs; [ broot htop ]; # Install broot and htop for Bobo

    programs.bash.aliases = {
      ll = "ls -l";
      la = "ls -A";
      lla = "ls -la";
      g = "git";
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
