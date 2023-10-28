# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master") # https://github.com/nix-community/nixos-vscode-server
      ./nano-configuration.nix
      # home manager requires nixos channel updates:
      # sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
      # sudo nix-channel --update
      <home-manager/nixos> 
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # enable experimental feature of nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.warden = {
    isNormalUser = true;
    description = "Warden Sharp";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ 
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFqE65cnhu7OjQfB1adcCa/SYalVXPbOqL991upv69AVg+zV9bidAD0hUOZeje+0fhKZog27XqsPIlw9EBLtXJB2ADm8o5Hzb6hRWVDc5Tuw2C5zio/ycIEQQkCC3JVsfkC+veIxcNKBjniuCbzBi+8A4JSkuj0KE6SK7n6z3oqHnNYiw== andrew@DESKTOP-TTHBBKN"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLiiu4kmxJZfrUw80pKy8lLl+oRD5l4hGWqJh0eM6j1TqvevJKe2TuZuWTbDcXWCgGSzSa5flS2HD1TesKjGCf0IU0VkUhDD725djIpvWLZZyjeMzyHIr8cXbX0t3Ijhf1KZqL0e7oIoDfFcbg0LY02EeK1ueZbLN85+Qkit35q2roSHzW1mMB6UCoLbW0kPFscbYpYAXKaUo+HyM8uFYZnbgpkyDX0fvYXwJp0GKB5ICmxeXCfzPcPSRUjktpRt+5qxQpszG1zwOBW/pG+y5eEVdR+kYoLXqIh9w7DCFHuCodt9fESVC2UTxUYeGs4wkasnroCS2OTHGQaEuIwLqNnrakoTzHMWWuait6p4Hwj4FhKefGomlJyW6tjBlGBGM/wSx9b6usSFpImuQm9g2uc00gs4dkyomaIDdmLTc0Zv5soKC5DDGhO0kzF1VXfGwMtxll8gMbXuiFd1CSAJspC7YZ+BnFrr5UsUWnP/r5q3il2DW0mR8q0p76TMw/IN8= ab@venture"
    ];
    #packages = with pkgs; []; # see home manager section
  };

  home-manager.users.warden = { pkgs, ... }: {
      home.packages = [ 
        pkgs.atool
        pkgs.httpie
        ];
      programs.bash.enable = true;
      programs.home-manager.enable = true;   
      
      #temp:
      #home.shellAliases = {
      #  g = "git";
      #  "..." = "cd ../..";
      #  "ab-nix-rebuild" = "sudo -i curl -o /etc/nixos/configuration.nix \"https://raw.githubusercontent.com/Andrew-Brad/Colonizer/master/os/linux/nixos/configuration.nix\" && sudo -i nixos-rebuild switch --show-trace";
      #};

      home.shellAliases = import "${pkgs.fetchFromGitHub {
        owner = \"ngandrass\";
        repo = \"git-aliases\";
        rev = \"a9d5c3f7b9e8b5d4a6c2a0d8f6e1c7f7d3c4d9f2\";
        sha256 = \"0jzjzv5q1xhjwqk8y3m6x5zv1gk7q4zr0s6y1vqy4m3n9n3l2v5h\";
      }}/git-aliases.bash";

      #home.file.".bash_aliases".source = "https://raw.githubusercontent.com/Andrew-Brad/Colonizer/master/os/linux/.bash_aliases";      
      #programs.bash.aliasesFile = "${users.users.warden.home}/.bash_aliases";

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "23.05";
    };
  home-manager.useGlobalPkgs = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  # traefik
   broot
   htop
   # btop
   # tldr
   # re
   glow # used for viewing markdown in the terminal
   git # todo: gitconfig https://search.nixos.org/options?channel=23.05&show=programs.git.config&from=0&size=50&sort=relevance&type=packages&query=gitconfig
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.vscode-server.enable = true; # https://github.com/nix-community/nixos-vscode-server

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Docker
  virtualisation.docker.enable = true; # https://nixos.wiki/wiki/Docker
  virtualisation.docker.enableOnBoot = true;
  users.extraGroups.docker.members = [ "warden" ];
  virtualisation.oci-containers.backend = "docker"; # not in the docs but needed apparently
  virtualisation.oci-containers.containers = {
     portainer = {
      image = "portainer/portainer-ce:linux-amd64-2.19.1";
      autoStart = true;
      ports = ["9443:9443"];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "portainer_data:/data"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
