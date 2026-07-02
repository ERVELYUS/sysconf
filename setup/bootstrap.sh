#!/usr/bin/env bash
# setup/bootstrap.sh — sysconf installer
# Run this after a fresh NixOS install and cloning the repo.
# Works with or without disk encryption.
set -euo pipefail

# ── Resolve repo root (script lives in setup/, repo is one level up) ─────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info() { echo -e "${BLUE}[·]${NC} $*"; }
ok()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
die()  { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }
ask()  { echo -e "\n${BOLD}$*${NC}"; }

# ── Preflight ─────────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && die "Run as your normal user, not root. sudo will be used where needed."
command -v nixos-rebuild &>/dev/null || die "nixos-rebuild not found — are you on NixOS?"
[[ -f "$REPO_DIR/flake.nix" ]]            || die "flake.nix not found at $REPO_DIR — wrong repo structure."
[[ -f "$REPO_DIR/base/common/core.nix" ]] || die "base/common/core.nix not found — wrong repo structure."
[[ -d "$REPO_DIR/base" ]]                 || die "base/ not found — wrong repo structure."

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       sysconf — bootstrap installer          ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"

# ── LUKS detection ────────────────────────────────────────────────────────────
LUKS_ENCRYPTED=false
LUKS_NAMES=()
LUKS_UUIDS=()
LUKS_DEVS=()

mapfile -t _CRYPT < <(dmsetup ls --target crypt 2>/dev/null | awk '{print $1}' || true)

if [[ ${#_CRYPT[@]} -gt 0 && -n "${_CRYPT[0]}" ]]; then
  LUKS_ENCRYPTED=true
  echo ""
  info "Encrypted drive(s) detected:"

  for name in "${_CRYPT[@]}"; do
    DEP=$(dmsetup deps -o devname "$name" 2>/dev/null \
          | grep -oP '\(\K[^)]+' | head -1 || true)
    [[ -z "$DEP" ]] && warn "  Could not resolve underlying device for '$name', skipping." && continue

    UUID=$(sudo blkid -s UUID -o value "/dev/$DEP" 2>/dev/null || true)
    [[ -z "$UUID" ]] && warn "  Could not read UUID for /dev/$DEP, skipping." && continue

    LUKS_NAMES+=("$name")
    LUKS_DEVS+=("/dev/$DEP")
    LUKS_UUIDS+=("$UUID")
    ok "  /dev/$DEP  mapped as '${name}'  (UUID: $UUID)"
  done
else
  echo ""
  info "No encrypted drives detected — disk encryption setup will be skipped."
fi

# ── Hostname ──────────────────────────────────────────────────────────────────
ask "Hostname for this machine:"
read -rp "  → " INPUT_HOST
[[ -z "$INPUT_HOST" ]] && die "Hostname cannot be empty."
[[ "$INPUT_HOST" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Hostname must be alphanumeric (dashes/underscores OK)."

if grep -qE "^\s*${INPUT_HOST}\s*=\s*mkHost" "$REPO_DIR/flake.nix" 2>/dev/null; then
  die "Host '${INPUT_HOST}' already exists in flake.nix."
fi

# ── Username ──────────────────────────────────────────────────────────────────
ask "Username:"
read -rp "  → " INPUT_USER
[[ -z "$INPUT_USER" ]] && die "Username cannot be empty."
[[ "$INPUT_USER" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "Username must be a valid Linux username (lowercase, start with letter/underscore)."

# ── User password ─────────────────────────────────────────────────────────────
while true; do
  ask "User password:"
  read -rsp "  → " USER_PASS; echo
  ask "Confirm user password:"
  read -rsp "  → " USER_PASS2; echo
  [[ "$USER_PASS" == "$USER_PASS2" ]] && break
  warn "Passwords don't match — try again."
done
unset USER_PASS2

# ── LUKS password change (optional) ──────────────────────────────────────────
CHANGE_LUKS=false
NEW_LUKS_PASS=""
CURRENT_LUKS_PASS=""

if [[ "$LUKS_ENCRYPTED" == true && ${#LUKS_NAMES[@]} -gt 0 ]]; then
  ask "Change encryption password (leave blank if no change is required):"
  read -rsp "  → " NEW_LUKS_PASS; echo

  if [[ -n "$NEW_LUKS_PASS" ]]; then
    while true; do
      ask "Confirm new encryption password:"
      read -rsp "  → " NEW_LUKS_PASS2; echo
      [[ "$NEW_LUKS_PASS" == "$NEW_LUKS_PASS2" ]] && break
      warn "Passwords don't match — try again."
    done
    unset NEW_LUKS_PASS2

    ask "Current encryption password (required to authorise the change):"
    read -rsp "  → " CURRENT_LUKS_PASS; echo
    CHANGE_LUKS=true
  fi
fi

# ── Base selection (single select) ────────────────────────────────────────────
BASE_DIR="$REPO_DIR/base"
SELECTED_BASE=""

mapfile -t AVAILABLE_BASES < <(find "$BASE_DIR" -maxdepth 1 -name "*.nix" \
                                 -exec basename {} .nix \; | sort)

if [[ ${#AVAILABLE_BASES[@]} -eq 0 ]]; then
  die "No bases found in base/ — repo structure is broken."
fi

echo ""
info "Select a base for this machine (pick one):"
for i in "${!AVAILABLE_BASES[@]}"; do
  echo "  $((i+1))) ${AVAILABLE_BASES[$i]}"
done

while true; do
  ask "Enter number:"
  read -rp "  → " BASE_CHOICE
  if [[ "$BASE_CHOICE" =~ ^[0-9]+$ ]] \
      && (( BASE_CHOICE >= 1 && BASE_CHOICE <= ${#AVAILABLE_BASES[@]} )); then
    SELECTED_BASE="${AVAILABLE_BASES[$((BASE_CHOICE-1))]}"
    ok "Selected base: ${SELECTED_BASE}"
    break
  fi
  warn "Invalid choice — enter a number between 1 and ${#AVAILABLE_BASES[@]}."
done

# ── Module selection (multi-select) ───────────────────────────────────────────
MODULES_DIR="$REPO_DIR/modules"
SELECTED_MODULES=()

if [[ -d "$MODULES_DIR" ]]; then
  mapfile -t AVAILABLE_MODULES < <(find "$MODULES_DIR" -maxdepth 1 -name "*.nix" \
                                     -exec basename {} .nix \; | sort)

  if [[ ${#AVAILABLE_MODULES[@]} -gt 0 ]]; then
    echo ""
    info "Select modules to include on this machine:"
    for module in "${AVAILABLE_MODULES[@]}"; do
      ask "  Include '${module}'? [y/N]:"
      read -rp "  → " ans
      [[ "${ans,,}" == "y" ]] && SELECTED_MODULES+=("$module")
    done
  else
    info "No modules found in modules/ — skipping."
  fi
fi

# ── Create host directory ─────────────────────────────────────────────────────
HOST_DIR="$REPO_DIR/hosts/$INPUT_HOST"

if [[ -d "$HOST_DIR" ]]; then
  warn "hosts/$INPUT_HOST/ already exists."
  ask "Overwrite? [y/N]:"
  read -rp "  → " OW
  [[ "${OW,,}" == "y" ]] || die "Aborted."
  rm -rf "$HOST_DIR"
fi
mkdir -p "$HOST_DIR"
ok "Created hosts/$INPUT_HOST/"

# ── hardware.nix ─────────────────────────────────────────────────────────────
if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
  cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware.nix"
  ok "Copied /etc/nixos/hardware-configuration.nix → hardware.nix"
else
  info "hardware-configuration.nix not found — generating it now..."
  sudo nixos-generate-config --show-hardware-config > "$HOST_DIR/hardware.nix"
  ok "Generated hardware.nix"
fi

# ── Assemble hosts/<name>/configuration.nix ──────────────────────────────────
# base and modules are injected via flake.nix mkHost, not via imports here.
# configuration.nix is intentionally minimal: identity + hardware only.
STATE_VER=$(nixos-version 2>/dev/null | grep -oP '^\d+\.\d+' || echo "25.05")

LUKS_BLOCK=""
for i in "${!LUKS_NAMES[@]}"; do
  LUKS_BLOCK+="  boot.initrd.luks.devices.\"${LUKS_NAMES[$i]}\".device =\n"
  LUKS_BLOCK+="    \"/dev/disk/by-uuid/${LUKS_UUIDS[$i]}\";\n"
done

{
cat << NIXEOF
{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  imports = [
    ./hardware.nix
  ];

  # --- IDENTITY
  networking.hostName = "${INPUT_HOST}";

  # --- BOOTLOADER
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

NIXEOF

if [[ -n "$LUKS_BLOCK" ]]; then
cat << NIXEOF
  # --- DISK ENCRYPTION
$(echo -e "$LUKS_BLOCK")
NIXEOF
fi

cat << NIXEOF
  # --- USER ACCOUNT
  users.users.\${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "${STATE_VER}";
}
NIXEOF
} > "$HOST_DIR/configuration.nix"

ok "Written hosts/$INPUT_HOST/configuration.nix"
cd "$REPO_DIR"
git add hosts/"$INPUT_HOST"/
git add flake.nix
info "Staged new host files for Nix."

# ── Inject host into flake.nix ────────────────────────────────────────────────
FLAKE="$REPO_DIR/flake.nix"
MARKER="# BOOTSTRAP_HOSTS"

# Build the Nix modules list literal
if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then
  MODULES_NIX="[ ]"
else
  MODULES_NIX="[\n"
  for m in "${SELECTED_MODULES[@]}"; do
    MODULES_NIX+="            \"${m}\"\n"
  done
  MODULES_NIX+="          ]"
fi

if grep -q "$MARKER" "$FLAKE"; then
  NEW_BLOCK="        ${INPUT_HOST} = mkHost {\n"
  NEW_BLOCK+="          hostname = \"${INPUT_HOST}\";\n"
  NEW_BLOCK+="          username = \"${INPUT_USER}\";\n"
  NEW_BLOCK+="          base = \"${SELECTED_BASE}\";\n"
  NEW_BLOCK+="          modules = ${MODULES_NIX};\n"
  NEW_BLOCK+="        };\n\n"
  NEW_BLOCK+="        ${MARKER}"
  sed -i "s|${MARKER}|${NEW_BLOCK}|" "$FLAKE"
  ok "Added '${INPUT_HOST}' to flake.nix"
else
  warn "Marker '${MARKER}' not found in flake.nix."
  warn "Add the entry manually before running nixos-rebuild:"
  echo ""
  echo "        ${INPUT_HOST} = mkHost {"
  echo "          hostname = \"${INPUT_HOST}\";"
  echo "          username = \"${INPUT_USER}\";"
  echo "          base = \"${SELECTED_BASE}\";"
  echo "          modules = ${MODULES_NIX};"
  echo "        };"
  echo ""
fi

# ── Update hardcoded /home/<user> paths in dotfiles ───────────────────────────
DOTFILES_DIR="$REPO_DIR/dotfiles"
if [[ "$INPUT_USER" != "nick" && -d "$DOTFILES_DIR" ]]; then
  echo ""
  info "Checking for hardcoded '/home/nick' paths in dotfiles/ that need updating..."
  mapfile -t MATCHES < <(grep -rl "/home/nick" "$DOTFILES_DIR" 2>/dev/null || true)

  if [[ ${#MATCHES[@]} -gt 0 ]]; then
    for f in "${MATCHES[@]}"; do
      sed -i "s#/home/nick#/home/${INPUT_USER}#g" "$f"
      ok "  Updated: ${f#$REPO_DIR/}"
    done
  else
    info "  None found."
  fi
fi

# ── Change LUKS password ──────────────────────────────────────────────────────
if [[ "$CHANGE_LUKS" == true ]]; then
  echo ""
  info "Changing LUKS password on ${#LUKS_DEVS[@]} device(s)..."

  for i in "${!LUKS_DEVS[@]}"; do
    dev="${LUKS_DEVS[$i]}"
    printf '%s\n%s\n' "$CURRENT_LUKS_PASS" "$NEW_LUKS_PASS" \
      | sudo cryptsetup luksChangeKey "$dev" - \
      && ok "Changed LUKS password on $dev" \
      || warn "Failed on $dev — change manually: sudo cryptsetup luksChangeKey $dev"
  done

  unset CURRENT_LUKS_PASS NEW_LUKS_PASS
fi

# ── nixos-rebuild ─────────────────────────────────────────────────────────────
echo ""
info "Running: sudo nixos-rebuild switch --flake ${REPO_DIR}#${INPUT_HOST}"
info "This may take a while on first run..."
echo ""

cd "$REPO_DIR"
sudo nixos-rebuild switch --flake ".#${INPUT_HOST}" \
  || die "nixos-rebuild failed — see output above. Your flake.nix and hosts/${INPUT_HOST}/ changes are still in place; fix and re-run nixos-rebuild manually."

# ── Set user password ─────────────────────────────────────────────────────────
echo ""
if id "$INPUT_USER" &>/dev/null; then
  echo "${INPUT_USER}:${USER_PASS}" | sudo chpasswd \
    && ok "Password set for '${INPUT_USER}'" \
    || warn "chpasswd failed — set manually: sudo passwd ${INPUT_USER}"
else
  warn "User '${INPUT_USER}' not found post-rebuild — set password manually: sudo passwd ${INPUT_USER}"
fi
unset USER_PASS

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}All done!${NC}"
echo ""
echo -e "  Repo path   : $REPO_DIR"
echo -e "  Host config : hosts/${INPUT_HOST}/"
echo -e "  Username    : ${INPUT_USER}"
echo -e "  Base        : ${SELECTED_BASE}"
[[ ${#SELECTED_MODULES[@]} -gt 0 ]] \
  && echo -e "  Modules     : ${SELECTED_MODULES[*]}" \
  || echo -e "  Modules     : none"
echo ""
echo -e "  To rebuild this machine at any time:"
echo -e "  ${BOLD}os-switch${NC}   (alias for: nh os switch)"
echo -e "  or manually:"
echo -e "  ${BOLD}sudo nixos-rebuild switch --flake ${REPO_DIR}#${INPUT_HOST}${NC}"
echo ""
echo "Reboot to make sure everything comes up cleanly."
echo ""
