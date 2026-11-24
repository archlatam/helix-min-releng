/* Helix Linux — Calamares branding slideshow
 * API version 2: se carga al iniciar Calamares; sin Component.onCompleted,
 * sin Timer, sin nextSlide(). Se activa/desactiva con onActivate()/onLeave().
 */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    // Lo fija Calamares cuando la diapositiva entra/sale (API 2).
    property bool activatedInCalamares: false

    function onActivate() {
        activatedInCalamares = true;
        presentation.currentSlide = 0;
    }

    function onLeave() {
        activatedInCalamares = false;
    }

    // Paleta Catppuccin Mocha, coherente con niri/GTK/Qt del live.
    QtObject {
        id: c
        readonly property string base:     "#1e1e2e"
        readonly property string mantle:   "#181825"
        readonly property string text:     "#cdd6f4"
        readonly property string mauve:    "#cba6f7"
        readonly property string blue:     "#89b4fa"
        readonly property string green:    "#a6e3a1"
        readonly property string surface1: "#45475a"
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: c.base
        }
        Image {
            id: logo
            source: "squid.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            width: 96; height: 96
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 16
            text: "Helix Linux"
            color: c.mauve
            font.pixelSize: 28
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 56
            text: "Instalación del sistema  •  2026.1"
            color: c.text
            font.pixelSize: 14
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            text: "Wayland · niri · Noctalia · Catppuccin"
            color: c.green
            font.pixelSize: 12
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: c.mantle
        }
        Text {
            anchors.centerIn: parent
            text: "Preparando el sistema de archivos e initramfs…"
            color: c.blue
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 40
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: c.base
        }
        Text {
            anchors.centerIn: parent
            text: "Copiando la imagen live e instalando GRUB…"
            color: c.mauve
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 40
        }
    }
}
