# Notas para agentes — Perfil Archiso "Core" (ArchLatam)

Documento de traspaso. Última actualización: 2026-11-05.

## Contexto

- Perfil archiso (`profiledef.sh`, `iso_name="Core"`), KDE Plasma 6, usuario `liveuser`.
- El home del liveuser se genera desde `airootfs/etc/skel` durante la compilación (confirmado: `/home/liveuser` de la ISO es una copia de skel).
- Directorio de trabajo de esta sesión: `/home/m4teo/Proyectos/archiso`.
- Copias de referencia (más antiguas, no tocar salvo indicación):
  - `/home/m4teo/Proyectos/archiso_a`
  - `/home/m4teo/Proyectos/ArchLatam-Iso`
- Repo git destino: `/home/m4teo/Proyectos/ArchLatam-Iso`
  - Remoto: `https://github.com/archlatam/ArchLatam-profile.git`
  - Rama: `main`
- La carpeta `/home/m4teo/Proyectos/archiso` NO es un repo git.

## Cambios hechos (2026-11-05)

### 1. Favoritos de Kickoff

Archivo: `airootfs/etc/xdg/kicker-extra-favoritesrc`

Contenido actual:

```ini
[General]
Prepend=applications:org.kde.konsole.desktop;applications:org.kde.dolphin.desktop;applications:brave-origin.desktop;applications:archlatam-welcome.desktop;applications:systemsettings.desktop;applications:gparted.desktop
IgnoreDefaults=true
```

Motivo:

- KDE lee este archivo con `KConfigGroup::readXdgListEntry()`: separador `;`, escape `\`.
- Antes estaba separado por comas, por lo que todo el `Prepend` era un único ítem inválido.
- Al guardar el `ordering`, KConfig escapaba las comas como `\,` → aparecían barras invertidas en `kactivitymanagerd-statsrc` y los favoritos no se creaban.
- El `:` no es separador entre aplicaciones: forma parte del id de recurso `applications:<archivo>.desktop`.

### 2. Eliminado `airootfs/etc/skel/.config/kactivitymanagerd-statsrc`

Motivo:

- Era redundante y frágil: estaba atado a `instance-3` y al UUID de actividad `07206855-a7ab-4524-bdc2-2aaf6c8e6851`.
- Ahora Kickoff genera el orden en el primer arranque con `portOldFavorites()` a partir de `kicker-extra-favoritesrc`.

Reglas asociadas:

- NO definir `favoritesPortedToKAstats` en `plasma-org.kde.plasma.desktop-appletsrc` (debe quedar ausente o en `false`).
- Si alguna vez se copia el home de una sesión en vivo, no poner `favoritesPortedToKAstats=true` sin incluir también la base de KActivities (`~/.local/share/kactivitymanagerd/resources/`) y el estado (`~/.local/state/kactivitymanagerdstaterc`).
- `airootfs/etc/skel/.config/kactivitymanagerdrc` se dejó: solo define la actividad por defecto, no interfiere.

### 3. Botones de ventana a la izquierda

Archivo: `airootfs/etc/skel/.config/kwinrc`

Se agregó:

```ini
[org.kde.kdecoration2]
ButtonsOnLeft=MXIA
ButtonsOnRight=
```

Resultado: `[menú] [cerrar] [minimizar] [maximizar]` a la izquierda, sin botones a la derecha.

Códigos de botón (KWin):

- `M` menú de ventana
- `X` cerrar
- `I` minimizar
- `A` maximizar
- `S` en todos los escritorios
- `H` ayuda
- `F`/`B` mantener arriba/abajo
- `E` excluir de capturas
- El orden de la cadena es el orden en pantalla de izquierda a derecha.

Importante:

- `ButtonsOnRight=` debe quedar explícito y vacío. Si se omite, KWin usa el default `HIAX` y los botones aparecen también a la derecha.
- La configuración efectiva va en `kwinrc`. `kdedefaults/kwinrc` solo define el tema/plugin de Breeze.

## Verificación ya realizada sobre la ISO anterior

ISO analizada: `/home/m4teo/Proyectos/iso/Core-2026.11.05-x86_64.iso`

- Confirmado el bug: `Prepend` con comas, sin base de KActivities en `/home/liveuser`, sin `favoritesPortedToKAstats`.
- Confirmado que los 6 `.desktop` del `Prepend` existen en `/usr/share/applications` de la ISO.
- Validado con un parser equivalente a `readXdgListEntry()`: el nuevo `Prepend` produce exactamente 6 ítems válidos.
- Captura de una sesión en vivo: `/home/m4teo/Proyectos/skel.new4.zip` (contiene home, base de KActivities, stats, etc.).

## Pendiente

1. Recompilar la ISO.
2. Arranque limpio en VM:
   - Kickoff → Favoritos: Konsole, Dolphin, Brave, ArchLatam Welcome, System Settings, GParted, en ese orden.
   - Barra de título: `[menú] [cerrar] [minimizar] [maximizar]` a la izquierda, nada a la derecha.
3. Repetir un segundo arranque limpio para confirmar consistencia.
4. Opcional: en la sesión en vivo revisar que `~/.config/kactivitymanagerd-statsrc` tenga `ordering=applications:...` separado por comas (sin `\,`).
5. Si funciona, replicar los cambios en el repo git.

## Merge al repo git (solo cuando la ISO funcione)

Repo: `/home/m4teo/Proyectos/ArchLatam-Iso`

Estado actual del repo (sucio/desactualizado respecto a `archiso`):

- Tiene `favoritesPortedToKAstats=true` en el `appletsrc` del repo: hay que quitarlo o el arreglo de favoritos no funciona.
- Tiene un `kicker-extra-favoritesrc` distinto (con `;` pero sin prefijos `applications:` y sin `systemsettings`).
- Tiene borrados y modificaciones sin commitear (`kactivitymanagerd-statsrc`, `kactivitymanagerdrc`, menús, appletsrc).
- El `kicker-extra-favoritesrc` figura como archivo sin trackear.

Pasos sugeridos:

1. Copiar `airootfs/etc/xdg/kicker-extra-favoritesrc` y `airootfs/etc/skel/.config/kwinrc` desde `archiso` al repo.
2. Eliminar `archiso/airootfs/etc/skel/.config/kactivitymanagerd-statsrc` en el repo.
3. Quitar `favoritesPortedToKAstats=true` de `archiso/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` en el repo.
4. Revisar el resto de diferencias del perfil y decidir si se sincroniza todo `archiso` o solo este arreglo.
5. Commit y push a `main`.

## Separadores de listas en KDE (para no repetir el error)

| Archivo / clave | Separador de lista | Ejemplo de ítem |
|---|---|---|
| `kicker-extra-favoritesrc` → `Prepend` | `;` (XDG, escape `\`) | `applications:org.kde.konsole.desktop` |
| `kactivitymanagerd-statsrc` → `ordering` | `,` (KConfig, escape `\,`) | `applications:org.kde.konsole.desktop` |
| `plasma-org.kde.plasma.desktop-appletsrc` → `launchers` | `,` (KConfig) | `applications:org.kde.konsole.desktop` |
| `plasma-org.kde.plasma.desktop-appletsrc` → `favorites` (legacy) | `,` (KConfig) | `applications:org.kde.konsole.desktop` |

- El `\` nunca es separador: es carácter de escape.
- El `:` pertenece al id `applications:<archivo>.desktop`, no separa aplicaciones.

## Datos útiles

- Applet de Kickoff en `plasma-org.kde.plasma.desktop-appletsrc`: id `3`.
- `clientId` que usa Kickoff: `org.kde.plasma.kickoff.favorites.instance-3`.
- Secciones en `kactivitymanagerd-statsrc`: `Favorites-<clientId>-<uuid-actividad>` y `Favorites-<clientId>-global`.
- Código de referencia de KDE: `plasma-workspace/applets/kicker/kastatsfavoritesmodel.cpp` (`portOldFavorites`, `saveOrdering`).
- Compilar (usar el comando habitual del proyecto; ejemplo estándar):
  `sudo mkarchiso -v -w /tmp/archiso-work -o /home/m4teo/Proyectos/iso /home/m4teo/Proyectos/archiso`

## Rollback

- Favoritos: reponer `kactivitymanagerd-statsrc` desde `skel.new4.zip` y volver al `Prepend` anterior. No recomendado: el `Prepend` con comas es inválido.
- Botones: quitar la sección `[org.kde.kdecoration2]` de `kwinrc` (vuelve al default `MSE` / `HIAX`).

## Fondos de pantalla (Helix Linux) — HECHO

Los wallpapers ya están integrados en el perfil (verificado con Noctalia v4):

- Assets en `airootfs/usr/share/helix/wallpapers/` (9 imágenes; `dino.jpg` 3000x1688 es el fondo por defecto).
- `airootfs/etc/skel/.config/noctalia/settings.json`: `wallpaper.directory = "/usr/share/helix/wallpapers"`, `enabled: true`, `fillMode: crop`, `useSolidColor: false`.
- `airootfs/etc/skel/.cache/noctalia/wallpapers.json`: `defaultWallpaper = "/usr/share/helix/wallpapers/dino.jpg"` (excepción en `.gitignore` para que se versione).
- niri no dibuja fondos: Noctalia es el proveedor vía layer-shell; no agregar `swaybg` (se superpondría).

Verificación en el live: `qs -c noctalia-shell ipc call wallpaper get` debe devolver esa ruta; `journalctl --user -b | grep -i wallpaper`.

## Calamares: branding Helix — HECHO

Assets propios en `airootfs/etc/calamares/branding/default/`, todos con `.license`
`SPDX-FileCopyrightText: 2026 Helix Linux` + `SPDX-License-Identifier: CC0-1.0`:

| Archivo | Uso | Detalle |
|---|---|---|
| `logo.png` | `productIcon`, `productLogo` (y slide 1 de `show.qml`) | Logo Helix; originalmente 344×406, se rellenó con `#1e1e2e` hasta 406×406 para que sea cuadrado (Calamares recomienda cuadrado para iconos de 16×16 y 80×80). |
| `welcome.png` | `productWelcome` | Nube de idiomas en paleta Catppuccin sobre `#1e1e2e`, 640×300 (2× el recomendado 320×150, porque `welcomeExpandingLogo: true` escala la imagen). Generada con SVG + `rsvg-convert` y fuentes Noto. |
| `buttons.png` | slideshow (`show.qml`) | 3840×2160, 6 bloques pastel sobre `#1e1e2e`; se muestra en el slide de copia. |

- `branding.desc`: `productIcon`/`productLogo` → `logo.png`, `productWelcome` → `welcome.png`. No se tocó `slideshow: "show.qml"` ni `slideshowAPI: 2`.
- `show.qml` (API 2): `onActivate()` pone `presentation.currentSlide = 2` para mostrar la imagen desde el inicio; no hay `Timer`. El slide de copia usa `Image { source: "buttons.png"; anchors.fill: parent; fillMode: Image.PreserveAspectCrop }` y el texto abajo (`anchors.bottom`, `bottomMargin: 28`) para no tapar los botones. Las rutas de imagen son relativas al directorio del branding (no absolutas).
- `squid.png`, `languages.png`, `banner.png` y sus `.license` (GPL-3.0, KDE) se dejaron intactos, ahora sin uso.
- Tras editar hay que **reconstruir la ISO**: el QML se compila al iniciar Calamares.

## Menú de arranque: opciones NVIDIA / gráficos seguros — HECHO

El live es Wayland puro: SDDM hace autologin a `niri.desktop` (`airootfs/etc/sddm.conf.d/10-helix-live.conf`). No hay sesión X11 de respaldo en el perfil. Por eso:

- `nouveau.modeset=1` fuerza el driver libre y **conserva** el escritorio.
- `nomodeset` desactiva KMS: niri no puede iniciarse y solo se obtiene una consola/framebuffer básico. Es opción de diagnóstico/rescate, **no** una sesión gráfica funcional.
- El driver propietario **no está en el live**. NVIDIA se instala después en el sistema instalado mediante el módulo `netinstall@nvidia` (`airootfs/etc/calamares/modules/netinstall-nvidia.yaml`). En el live, `nvidia_drm.modeset=1` no tiene efecto (el módulo no existe) y `modprobe.blacklist=nouveau` dejaría al equipo sin ningún driver.

Entradas añadidas: `helix-nouveau` (hotkey `n`, `nouveau.modeset=1`) y `helix-safe` (hotkey `g`, `nomodeset`).

- `grub/grub.cfg` (UEFI): en `helix-safe`, `if [ "${grub_platform}" == "pc" ]` → `set gfxpayload=1024x768x32,1024x768,auto`; en EFI, `keep`. Así se consigue framebuffer VESA en BIOS aun con `nomodeset`.
- `grub/loopback.cfg`: mismas entradas con `img_dev=UUID=${archiso_img_dev_uuid} img_loop="${iso_path}"` y `cow_spacesize=4G copytoram=n`.
- `syslinux/archiso_sys-linux.cfg` (BIOS): `LABEL helixnouveau` y `LABEL helixsafe` (esta con `vga=791`, equivalente BIOS del `gfxpayload`).
- `efiboot/loader/entries/*` no se tocó: `profiledef.sh` usa `bootmodes=('bios.syslinux' 'uefi.grub')`, no systemd-boot.

## Paquetes gráficos — HECHO

`packages.x86_64`: `mesa` (ya estaba) más `vulkan-intel`, `vulkan-radeon`, `vulkan-nouveau` e `intel-media-driver`, para aceleración Vulkan/VA-API en Intel, AMD y NVIDIA (driver libre).

## Brave desde `core_repo` — HECHO

- `packages.x86_64`: `brave-origin-bin` → `core_repo/brave-origin-bin` (en `core_repo` está la versión `1:1.100.58-1`; en el repo local `[archlatam]` está la `1:1.98.63-1`).
- Motivo: `pacman.conf` declara `[archlatam]` antes que `[core_repo]` y pacman resuelve por orden de repositorio, no por versión, así que siempre ganaba el paquete local. El prefijo `core_repo/` fuerza ese repo solo para Brave sin afectar al resto (`calamares-core`, `archlatam-welcome`, `noctalia`, etc.).
- Verificar en el build: `pacstrap` debe descargar `brave-origin-bin-1:1.100.58-1-x86_64.pkg.tar.zst`.
