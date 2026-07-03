#!/usr/bin/env bash
# setup/cleanup.sh — post-bootstrap cleanup
# Run this ONCE after rebooting into your new user account.
# Migrates files from the old user's home and removes the old user.
set -euo pipefail

CURRENT_USER="$(whoami)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info() { echo -e "${BLUE}[·]${NC} $*"; }
ok()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
die()  { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] && die "Run as your normal user, not root. sudo will be used where needed."

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║      sysconf — post-bootstrap cleanup        ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ─── Find old user ────────────────────────────────────────────────────────────
OLD_USER=""
OLD_HOME=""

while IFS=: read -r name _ uid _ _ home _; do
  if (( uid >= 1000 && uid < 60000 )) && [[ "$name" != "$CURRENT_USER" ]]; then
    OLD_USER="$name"
    OLD_HOME="$home"
    break
  fi
done < /etc/passwd

if [[ -z "$OLD_USER" ]]; then
  ok "No leftover users found — nothing to do here."
  echo ""
  exit 0
fi

info "Found old user: '${OLD_USER}' (home: ${OLD_HOME})"
echo ""
echo -e "  This script will:"
echo -e "  1. Migrate files from ${OLD_HOME}/ into your home"
echo -e "  2. Remove user '${OLD_USER}'"
echo -e "  3. Delete ${OLD_HOME}/"
echo ""
read -rp "  Continue? [y/N]: " CONFIRM
[[ "${CONFIRM,,}" == "y" ]] || { info "Cancelled."; echo ""; exit 0; }

# ─── Migrate home directory ───────────────────────────────────────────────────
CURRENT_HOME="/home/${CURRENT_USER}"
BACKUP_DIR="${CURRENT_HOME}/.migration-backup"

echo ""
info "Migrating files from ${OLD_HOME}/ → ${CURRENT_HOME}/..."

shopt -s dotglob  # include hidden files
for item in "$OLD_HOME"/*; do
  [[ -e "$item" || -L "$item" ]] || continue  # skip if glob found nothing
  name="$(basename "$item")"
  dest="${CURRENT_HOME}/${name}"

  # Rule 1: Symlink at destination (managed by home-manager) -> skip
  if [[ -L "$dest" ]]; then
    info "  Skipping '${name}' — managed by home-manager (symlink)"
    continue
  fi

  # Rule 2/3: If file/dir exists at destination -> backup to .migration-backup
  if [[ -e "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    sudo mv "$dest" "${BACKUP_DIR}/${name}"
    warn "  Backed up existing '${name}' to .migration-backup/"
  fi

  # Move over
  sudo mv "$item" "$dest"
  sudo chown -R "${CURRENT_USER}:users" "$dest"
  ok "  Moved '${name}'"
done
shopt -u dotglob

if [[ -d "$BACKUP_DIR" ]]; then
  echo ""
  warn "Some files were backed up to ~/.migration-backup/ due to conflicts."
  warn "Review them and delete once you're satisfied nothing was lost."
fi

# ─── Remove old user and their now-empty home ─────────────────────────────────
echo ""
info "Removing user '${OLD_USER}'..."
sudo userdel "$OLD_USER" \
  && ok "User '${OLD_USER}' removed." \
  || warn "userdel failed — remove manually: sudo userdel ${OLD_USER}"

if [[ -d "$OLD_HOME" ]]; then
  sudo rm -rf "$OLD_HOME" \
    && ok "Removed ${OLD_HOME}/" \
    || warn "Could not remove ${OLD_HOME} — remove manually: sudo rm -rf ${OLD_HOME}"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
ok "Cleanup complete. You are now the only user on this system."
echo ""
