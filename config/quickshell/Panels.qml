// État partagé des panneaux : la barre et le panneau d'accueil se signalent le survol.
pragma Singleton
import QtQuick

QtObject {
  property bool homeOpen: false
  property bool hoverBar: false
  property bool hoverHome: false

  // Ferme le panneau un peu après que la souris l'a quitté, pour éviter le clignotement.
  readonly property Timer closeTimer: Timer {
    interval: 350
    onTriggered: if (!Panels.hoverBar && !Panels.hoverHome) Panels.homeOpen = false
  }

  function refresh() {
    if (hoverBar || hoverHome) {
      homeOpen = true
    } else {
      closeTimer.restart()
    }
  }
}
