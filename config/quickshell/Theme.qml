// Couleurs et polices partagées. Catppuccin Mocha par défaut.
pragma Singleton
import QtQuick

QtObject {
  readonly property color surface: "#1e1e2e"
  readonly property color surfaceVariant: "#313244"
  readonly property color textColor: "#cdd6f4"
  readonly property color primary: "#f5e0dc"
  readonly property color primaryContent: "#1e1e2e"
  readonly property color tertiary: "#f9e2af"
  readonly property color error: "#f38ba8"

  readonly property string font: "JetBrainsMono Nerd Font"
  readonly property int barHeight: 32
}
