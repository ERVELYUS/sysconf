# sysconf

<div align="center">

![sysconf screenshot](setup/screenshots/overview.png)

My personal NixOS configuration — system settings, packages, and dotfiles

</div>

## Structure

```
sysconf/
├── flake.nix          # entry point, defines every host
├── core.nix           # settings shared by every machine
├── hosts/
│   └── <hostname>/
│       ├── configuration.nix   # hostname, bootloader, LUKS, user account
│       └── hardware.nix        # auto-generated, don't touch by hand
├── profiles/          # optional feature sets a host can opt into
├── dotfiles/          # home-manager config: nvim, niri, ghostty, etc.
└── setup/
    └── bootstrap.sh   # installer for new machines
```

## How it's organized

`core.nix` - the bedrock of every machine

`profiles/` sits above that as an opt-in layer. Things like virtualisation or gaming tools live there, and a host only picks them up if its `configuration.nix` imports that specific profile

`hosts/<name>/` holds only what's actually specific to that one machine — hostname, disk encryption, bootloader. Adding a new machine means a new folder under `hosts/` and one entry in `flake.nix`

## Installing on a new machine

1. Install NixOS as usual — partition, encrypt the disk if you want, create a temporary user, reboot into the fresh system.
2. Clone the repo:
   ```bash
   nix-shell -p git --run "git clone https://github.com/ERVELYUS/sysconf.git ~/sysconf"
   ```
3. Run the installer:
   ```bash
   bash ~/sysconf/setup/bootstrap.sh
   ```
   It'll ask for a hostname, username, password, and which profiles you want. It detects disk encryption on its own and offers to change the LUKS password if needed. From there it builds a new `hosts/<hostname>/` directory, wires it into the flake, and runs the first switch.
4. Reboot. Everything's live — packages, niri, dotfiles, theming.

## Aliases

| Alias | What it does |
|---|---|
| `os-switch` | rebuild and switch (`nh os switch`) |
| `os-update` | update all flake inputs, then rebuild and switch |
| `os-clean` | clean old generations, keep the last 4 |

## Adding a host by hand

If you don't want to run the installer:

```bash
mkdir ~/sysconf/hosts/<newhost>
cp /etc/nixos/hardware-configuration.nix ~/sysconf/hosts/<newhost>/hardware.nix
# write configuration.nix following one of the existing hosts as a template
```

then add it to `flake.nix`:

```nix
<newhost> = mkHost {
  hostname = "<newhost>";
  username = "<user>";
};
```

```bash
sudo nixos-rebuild switch --flake ~/sysconf#<newhost>
```
