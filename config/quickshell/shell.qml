// Quickshell : point d'entrée. Une barre par écran.
import Quickshell
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Bar {
      required property var modelData
      screen: modelData
    }
  }
}
