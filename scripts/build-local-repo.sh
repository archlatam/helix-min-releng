#!/usr/bin/env bash
# Construye los paquetes AUR (noctalia-qs-legacy-v4, noctalia-legacy-v4) y los publica en /opt/helix-repo.
# Ejecutar como usuario normal (no root) en un Arch con base-devel, git y devtools.
set -euo pipefail

REPO=/opt/helix-repo
WORK="$(mktemp -d)"
AUR_PKGS=(noctalia-qs-legacy-v4 noctalia-legacy-v4)

sudo install -d -o "$USER" -g "$(id -gn)" "$REPO"

for pkg in "${AUR_PKGS[@]}"; do
    git clone "https://aur.archlinux.org/${pkg}.git" "$WORK/$pkg"
    echo ">>> Revisá $WORK/$pkg/PKGBUILD antes de continuar (Enter para compilar, Ctrl+C para abortar)"
    read -r _
    ( cd "$WORK/$pkg" && makepkg -srC --noconfirm --needed )
    cp "$WORK/$pkg"/*.pkg.tar.zst "$REPO/"
done

repo-add "$REPO/helix-local.db.tar.zst" "$REPO"/*.pkg.tar.zst
ln -sf helix-local.db.tar.zst "$REPO/helix-local.db"
echo "Repo local listo en $REPO"
