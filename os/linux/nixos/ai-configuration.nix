{ config, pkgs, lib, ... }:

let
  myRepo = pkgs.fetchFromGitHub {
    owner = "Andrew-Brad";
    repo = "Colonizer";
    rev = "e921e07";
    sha256 = "0b56vmilrrn8sfg1gx79skkai9js2124zn3vw3bq63lhdkcij45a"; # Obtain with nix-prefetch-git
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

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    (pkgs.writeTextFile {
      name = "myFile.md";
      text = myFile;
    })
  ];
}
