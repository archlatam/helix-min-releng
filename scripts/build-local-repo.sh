#!/usr/bin/env bash
# Construye los paquetes AUR del perfil y los publica en /opt/helix-repo:
#   noctalia-qs-legacy-v4, noctalia-legacy-v4 (con dependencias)
#   catppuccin-gtk-theme-mocha, kvantum-theme-catppuccin-git (sin chequear deps:
#   sus dependencias ya están en packages.x86_64 del ISO).
# Ejecutar como usuario normal (no root) en un Arch con base-devel, git y devtools.
set -euo pipefail

REPO=/opt/helix-repo
WORK="$(mktemp -d)"
AUR_PKGS=(noctalia-qs-legacy-v4 noctalia-legacy-v4)
AUR_PKGS_SKIP_DEPS=(catppuccin-gtk-theme-mocha kvantum-theme-catppuccin-git)

sudo install -d -o "$USER" -g "$(id -gn)" "$REPO"

for pkg in "${AUR_PKGS[@]}"; do
    git clone "https://aur.archlinux.org/${pkg}.git" "$WORK/$pkg"
    echo ">>> Revisá $WORK/$pkg/PKGBUILD antes de continuar (Enter para compilar, Ctrl+C para abortar)"
    read -r _
    ( cd "$WORK/$pkg" && makepkg -srC --noconfirm --needed )
    cp "$WORK/$pkg"/*.pkg.tar.zst "$REPO/"
done

for pkg in "${AUR_PKGS_SKIP_DEPS[@]}"; do
    git clone "https://aur.archlinux.org/${pkg}.git" "$WORK/$pkg"
    echo ">>> Revisá $WORK/$pkg/PKGBUILD antes de continuar (Enter para compilar, Ctrl+C para abortar)"
    read -r _
    ( cd "$WORK/$pkg" && makepkg -fd --noconfirm )
    cp "$WORK/$pkg"/*.pkg.tar.zst "$REPO/"
done

repo-add "$REPO/helix-local.db.tar.zst" "$REPO"/*.pkg.tar.zst
ln -sf helix-local.db.tar.zst "$REPO/helix-local.db"
echo "Repo local listo en $REPO"
