{ config, pkgs, lib, ... }:

let
  myRepo = pkgs.fetchFromGitHub {
    owner = "Andrew-Brad";
    repo = "Colonizer";
    rev = "master";
    sha256 = "9FFB7B62056BA90185881F2565177463E1E22A94FC6AE4EDF932EB682A8A7F57"; # Replace with the actual SHA-256 hash of the repository
  };

  myFile = builtins.readFile "${myRepo}/README.md"; # Replace with the actual path to the file in the repository
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
  };

  system.stateVersion = "23.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    (pkgs.writeTextFile {
      name = "myFile.md";
      text = myFile;
    })
  ];
}
