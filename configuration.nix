# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.luks.devices = [
    {
      name = "luksroot";
      device = "/dev/sda3";
      preLVM = true;
    }
  ];

  #blacklist i2c_hid so touchpad will work
  boot.blacklistedKernelModules = [ "i2c_hid" ];

  # clean /tmp dir
  boot.cleanTmpDir = true;

  # steam controller
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
    KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
  '';

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
      withGTK2 = true;
      withGTK3 = false;
  });

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    libnotify
    keybinder
    vim                      # text editor
    git                      # version control
    xclip                    # clipboard
    arandr                   # GUI frontend for xrandr
    pavucontrol              # sound control
    rxvt_unicode             # terminal
    pass                     # password manager
    gnupg                    # encryption
    dmenu                    # launcher
    firefox                  # web browser
    thunderbird              # email
    zeal                     # documentation
    haskellPackages.stack    # haskell packages

    # emacs
    (import ./emacs.nix { inherit pkgs; })

  ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    extraOptions = "--userns-remap=default";
  };

  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = "set -o vi";
  };

  # needed for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
  };

  services.xserver.displayManager = {
    sessionCommands = ''
      feh --bg-fill /home/ryan/Pictures/Firefox_wallpaper.png &
    '';
  };

  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
  };

  users.groups.dockremap.gid = 10000;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ryan = {
      home = "/home/ryan";
      createHome = true;
      isNormalUser = true;
      uid = 1001;
      group = "users";
      extraGroups = ["wheel" "networkmanager" "docker"];
    };
    dockremap = {
      isSystemUser = true;
      uid = 10000;
      group = "dockremap";
      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];
      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];
    };
  };

  security.apparmor.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
