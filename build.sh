#!/usr/bin/env bash
# Build del ISO Helix Linux. Requiere: archiso, y el repo local (scripts/build-local-repo.sh).
set -euo pipefail
cd "$(dirname "$0")"

RELENG=/usr/share/archiso/configs/releng

# Archivos de arranque: se toman de releng (archiso) si todavía no están en el perfil.
for d in syslinux efiboot grub; do
    if [[ ! -d "$d" ]]; then
        cp -r "$RELENG/$d" "$d"
        echo "Copiado $d desde releng — reemplazá 'Arch Linux' por 'Helix Linux' en esos archivos."
    fi
done

[[ -f /opt/helix-repo/helix-local.db ]] || { echo "Falta /opt/helix-repo: corré scripts/build-local-repo.sh"; exit 1; }

sudo rm -rf work
sudo mkarchiso -v -w work -o out .
ls -lh out/
