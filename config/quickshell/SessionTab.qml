// Onglet Session : date et heure, avec le lecteur en cours s'il y en a un.
import QtQuick
import Quickshell

Item {
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Column {
    anchors.centerIn: parent
    spacing: 6

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(clock.date, "HH:mm")
      color: Theme.textColor
      font.family: Theme.font
      font.pixelSize: 56
      font.weight: Font.Light
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(clock.date, "dddd d MMMM yyyy")
      color: Theme.textColor
      opacity: 0.7
      font.family: Theme.font
      font.pixelSize: 14
    }
  }
}
