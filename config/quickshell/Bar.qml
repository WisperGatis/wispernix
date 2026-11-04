// Barre supérieure : logo et espaces de travail à gauche, horloge au centre.
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

PanelWindow {
  id: bar

  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: Theme.barHeight
  color: Theme.surface
  // Réserve la place de la barre, comme Waybar.
  exclusiveZone: implicitHeight

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  // Gauche : logo NixOS puis espaces de travail Hyprland.
  Row {
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.verticalCenter: parent.verticalCenter
    spacing: 10

    Text {
      text: ""
      color: Theme.primary
      font.family: Theme.font
      font.pixelSize: 16
    }

    Repeater {
      model: Hyprland.workspaces

      Text {
        required property var modelData
        text: modelData.name
        color: modelData.active ? Theme.primary : Theme.textColor
        font.family: Theme.font
        font.pixelSize: 13
        font.bold: modelData.active

        MouseArea {
          anchors.fill: parent
          onClicked: modelData.activate()
        }
      }
    }
  }

  // Centre : horloge.
  Text {
    anchors.centerIn: parent
    text: Qt.formatDateTime(clock.date, "HH:mm")
    color: Theme.textColor
    font.family: Theme.font
    font.pixelSize: 13
  }
}
