{ config, pkgs, lib, ... }:

let
  myRepo = pkgs.fetchFromGitHub {
    owner = "Andrew-Brad";
    repo = "Colonizer";
    rev = "e921e07"; # long sha's don't work, only short sha's *facepalm*
    sha256 = "0b56vmilrrn8sfg1gx79skkai9js2124zn3vw3bq63lhdkcij45a"; # Obtain with nix-prefetch-git
  };

  aliasesFile = builtins.readFile "${myRepo}/os/linux/.bash_aliases";
  _ = builtins.trace aliasesFile "contents of aliases.txt";  
  # aliases = builtins.filter (alias: (builtins.length (builtins.split "=" alias)) == 2) (builtins.filter (alias: alias != "") (builtins.split "\n" aliasesFile));
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
    openssh.authorizedKeys.keys = [ 
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFqE65cnhu7OjQfB1adcCa/SYalVXPbOqL991upv69AVg+zV9bidAD0hUOZeje+0fhKZog27XqsPIlw9EBLtXJB2ADm8o5Hzb6hRWVDc5Tuw2C5zio/ycIEQQkCC3JVsfkC+veIxcNKBjniuCbzBi+8A4JSkuj0KE6SK7n6z3oqHnNYiw== andrew@DESKTOP-TTHBBKN"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLiiu4kmxJZfrUw80pKy8lLl+oRD5l4hGWqJh0eM6j1TqvevJKe2TuZuWTbDcXWCgGSzSa5flS2HD1TesKjGCf0IU0VkUhDD725djIpvWLZZyjeMzyHIr8cXbX0t3Ijhf1KZqL0e7oIoDfFcbg0LY02EeK1ueZbLN85+Qkit35q2roSHzW1mMB6UCoLbW0kPFscbYpYAXKaUo+HyM8uFYZnbgpkyDX0fvYXwJp0GKB5ICmxeXCfzPcPSRUjktpRt+5qxQpszG1zwOBW/pG+y5eEVdR+kYoLXqIh9w7DCFHuCodt9fESVC2UTxUYeGs4wkasnroCS2OTHGQaEuIwLqNnrakoTzHMWWuait6p4Hwj4FhKefGomlJyW6tjBlGBGM/wSx9b6usSFpImuQm9g2uc00gs4dkyomaIDdmLTc0Zv5soKC5DDGhO0kzF1VXfGwMtxll8gMbXuiFd1CSAJspC7YZ+BnFrr5UsUWnP/r5q3il2DW0mR8q0p76TMw/IN8= ab@venture"
    ];
    packages = with pkgs; [ broot htop ]; # Install broot and htop for Bobo
  };

  users.users.warden = {
    isNormalUser = true;
    description = "Warden Sharp";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ 
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFqE65cnhu7OjQfB1adcCa/SYalVXPbOqL991upv69AVg+zV9bidAD0hUOZeje+0fhKZog27XqsPIlw9EBLtXJB2ADm8o5Hzb6hRWVDc5Tuw2C5zio/ycIEQQkCC3JVsfkC+veIxcNKBjniuCbzBi+8A4JSkuj0KE6SK7n6z3oqHnNYiw== andrew@DESKTOP-TTHBBKN"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLiiu4kmxJZfrUw80pKy8lLl+oRD5l4hGWqJh0eM6j1TqvevJKe2TuZuWTbDcXWCgGSzSa5flS2HD1TesKjGCf0IU0VkUhDD725djIpvWLZZyjeMzyHIr8cXbX0t3Ijhf1KZqL0e7oIoDfFcbg0LY02EeK1ueZbLN85+Qkit35q2roSHzW1mMB6UCoLbW0kPFscbYpYAXKaUo+HyM8uFYZnbgpkyDX0fvYXwJp0GKB5ICmxeXCfzPcPSRUjktpRt+5qxQpszG1zwOBW/pG+y5eEVdR+kYoLXqIh9w7DCFHuCodt9fESVC2UTxUYeGs4wkasnroCS2OTHGQaEuIwLqNnrakoTzHMWWuait6p4Hwj4FhKefGomlJyW6tjBlGBGM/wSx9b6usSFpImuQm9g2uc00gs4dkyomaIDdmLTc0Zv5soKC5DDGhO0kzF1VXfGwMtxll8gMbXuiFd1CSAJspC7YZ+BnFrr5UsUWnP/r5q3il2DW0mR8q0p76TMw/IN8= ab@venture"
    ];
    # packages = with pkgs; []; # see home manager section
  };

  services.openssh.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  # Home Manager configuration for the Bobo user
  home-manager.users.Bobo = { pkgs, ... }: {
    home.packages = with pkgs; [ broot htop ]; # Install broot and htop for Bobo

  # testing aliases
  # programs.bash.aliases = builtins.listToAttrs (map (alias: {
  #     name = builtins.elemAt (builtins.split "=" alias) 0;
  #     value = builtins.elemAt (builtins.split "=" alias) 1;
  #   }) aliases);

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05"; # Did you read the comment?

  
}
