# sysconf

<div align="center">

![sysconf screenshot](setup/screenshots/overview.png)

My NixOS configuration — system settings, packages, and dotfiles

</div>

## Structure

```
sysconf/
├── flake.nix          # entry point, defines every host
├── core.nix            # settings shared by every machine
├── modules/            # optional feature sets a host can opt into
│   ├── gaming.nix
│   ├── virtualisation.nix
│   └── creative.nix
├── hosts/
│   └── <hostname>/
│       ├── configuration.nix   # hostname, bootloader, LUKS, user account
│       └── hardware.nix        # auto-generated, don't touch by hand
└── dotfiles/            # home-manager config: nvim, niri, noctalia, ghostty, etc.
```

## How it's organized

`core.nix` covers whatever every machine needs — the desktop is niri + Noctalia.

`modules/` is the opt-in layer above that. Things like gaming, virtualisation, or creative tools live there, and a host only picks them up if it lists them in `flake.nix`.

`hosts/<name>/` holds only what's actually specific to that one machine — hostname, disk encryption, bootloader. Adding a new machine means a new folder under `hosts/` and one entry in `flake.nix`.

## Installing on a new machine

1. Install NixOS — partition, encrypt the disk if you want, create a temporary user, reboot into the fresh system.
2. Clone the repo:
   ```bash
   nix-shell -p git --run "git clone https://github.com/ERVELYUS/sysconf.git ~/sysconf"
   ```
3. Add a host entry in `flake.nix` (see below) and a hardware config, then build:
   ```bash
   sudo nixos-rebuild switch --flake ~/sysconf#<hostname>
   ```
4. Reboot. Everything's live — packages, niri, noctalia, dotfiles, theming.

## Aliases

| Alias | What it does |
|---|---|
| `os-switch` | rebuild and switch (`nh os switch`) |
| `os-update` | update all flake inputs, then rebuild and switch |
| `os-clean` | clean old generations, keep the last 4 |

## Adding a host

```bash
mkdir ~/sysconf/hosts/<newhost>
cp /etc/nixos/hardware-configuration.nix ~/sysconf/hosts/<newhost>/hardware.nix
# write configuration.nix following the existing host as a template
```

then add it to `flake.nix`:

```nix
<newhost> = mkHost {
  hostname = "<newhost>";
  username = "<user>";
  modules = [ "gaming" ];  # or [ ] for none
};
```

```bash
sudo nixos-rebuild switch --flake ~/sysconf#<newhost>
```
