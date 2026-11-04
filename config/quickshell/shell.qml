// Quickshell : point d'entrée. Une barre et un panneau d'accueil par écran.
import Quickshell
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Scope {
      required property var modelData

      Bar {
        screen: modelData
      }

      HomePanel {
        screen: modelData
      }
    }
  }
}
