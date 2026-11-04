// Panneau d'accueil : s'ouvre au survol du centre de la barre.
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
  id: home

  anchors {
    top: true
  }
  margins.top: Theme.barHeight
  implicitWidth: 520
  implicitHeight: 380
  color: "transparent"
  visible: Panels.homeOpen
  exclusiveZone: 0

  property int currentTab: 0

  Rectangle {
    anchors.fill: parent
    radius: 0
    color: Theme.surface
    border.color: Theme.surfaceVariant
    border.width: 1

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: { Panels.hoverHome = true; Panels.refresh() }
      onExited: { Panels.hoverHome = false; Panels.refresh() }
    }

    // Onglets.
    Row {
      id: tabs
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 12
      spacing: 8

      Repeater {
        model: ["Session", "Média"]

        Rectangle {
          required property string modelData
          required property int index
          width: 96
          height: 28
          radius: 14
          color: home.currentTab === index ? Theme.primary : Theme.surfaceVariant

          Text {
            anchors.centerIn: parent
            text: parent.modelData
            color: home.currentTab === parent.index ? Theme.primaryContent : Theme.textColor
            font.family: Theme.font
            font.pixelSize: 12
          }

          MouseArea {
            anchors.fill: parent
            onClicked: home.currentTab = parent.index
          }
        }
      }
    }

    // Contenu de l'onglet courant.
    StackLayout {
      anchors.top: tabs.bottom
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 16
      currentIndex: home.currentTab

      SessionTab {}
      MediaTab {}
    }
  }
}
