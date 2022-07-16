# new cmd: nix-build '<nixpkgs/nixos>' -A config.system.build.kexec_tarball -I nixos-config=./configuration.nix -Q -j 4

{ lib, pkgs, config, ... }:

with lib;

{
  imports = [ <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix> ./autoreboot.nix ./kexec.nix ./justdoit.nix ];

  boot.supportedFilesystems = [ "xfs" ];
  boot.loader.grub.enable = false;
  boot.kernelParams = [
    "console=ttyS0" "console=tty1"  # allows certain forms of remote access, if the hardware is setup right
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
    "nvme.shutdown_timeout=10" "libiscsi.debug_libiscsi_eh=1" # Oracle-cloud specific
  ];
  systemd.services.sshd.wantedBy = mkForce [ "multi-user.target" ];
  networking.hostName = "kexec";
  # example way to embed an ssh pubkey into the tar
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbvcYjxKkFjfC058N0OgLM+ZHrvlJ9lf99ObauLCGlE air@wind" ];
}
