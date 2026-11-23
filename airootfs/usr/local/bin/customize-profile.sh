#!/bin/bash
# Solo se ejecuta durante el build de mkarchiso (el marker del hook lo borra del live).
set -u
systemctl enable sddm.service
