set -g fish_greeting

if status is-interactive
    # La sesión gráfica la inicia SDDM (autologin en el live); no se lanza niri desde tty.
    alias ll 'ls -lah'
end
