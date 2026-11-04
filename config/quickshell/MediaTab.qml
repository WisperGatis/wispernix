// Onglet Média : lecteur MPRIS (Spotify, YouTube dans le navigateur, etc.) et paroles synchronisées.
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io

Item {
  id: media

  // Premier lecteur en lecture, sinon le premier disponible.
  readonly property var player: {
    const all = Mpris.players.values
    for (let i = 0; i < all.length; i++) {
      if (all[i].playbackState === MprisPlaybackState.Playing) return all[i]
    }
    return all.length > 0 ? all[0] : null
  }

  // Lignes de paroles synchronisées : { t: secondes, text: "..." }.
  property var lyricLines: []
  property string lyricKey: ""

  function parseLrc(lrc) {
    const out = []
    const re = /\[(\d+):(\d+(?:\.\d+)?)\](.*)/
    lrc.split("\n").forEach(function (line) {
      const m = re.exec(line)
      if (m) out.push({ t: parseInt(m[1]) * 60 + parseFloat(m[2]), text: m[3].trim() })
    })
    return out
  }

  // Interroge LRCLIB pour la piste en cours, uniquement quand elle change.
  function loadLyrics() {
    if (!player) return
    const key = player.trackArtist + " - " + player.trackTitle
    if (key === lyricKey) return
    lyricKey = key
    lyricLines = []
    const url = "https://lrclib.net/api/get?artist_name=" + encodeURIComponent(player.trackArtist)
              + "&track_name=" + encodeURIComponent(player.trackTitle)
    lyricsProc.command = ["curl", "-s", "--max-time", "5", url]
    lyricsProc.running = true
  }

  Process {
    id: lyricsProc
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(text)
          media.lyricLines = media.parseLrc(data.syncedLyrics || "")
        } catch (e) {
          media.lyricLines = []
        }
      }
    }
  }

  // Ligne courante = dernière ligne dont l'horodatage est passé.
  readonly property int currentLine: {
    if (!player) return -1
    let idx = -1
    for (let i = 0; i < lyricLines.length; i++) {
      if (lyricLines[i].t <= player.position) idx = i
    }
    return idx
  }

  onPlayerChanged: loadLyrics()

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: media.loadLyrics()
  }

  Column {
    anchors.centerIn: parent
    width: parent.width
    spacing: 10

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: media.player ? media.player.trackTitle : "Aucune lecture"
      color: Theme.textColor
      font.family: Theme.font
      font.pixelSize: 18
      font.weight: Font.Medium
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: media.player ? media.player.trackArtist : ""
      color: Theme.textColor
      opacity: 0.7
      font.family: Theme.font
      font.pixelSize: 13
    }

    // Paroles : ligne courante en avant-plan.
    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
      text: media.currentLine >= 0 ? media.lyricLines[media.currentLine].text : ""
      color: Theme.primary
      font.family: Theme.font
      font.pixelSize: 16
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 24

      Text {
        text: ""
        color: Theme.textColor
        font.family: Theme.font
        font.pixelSize: 18
        MouseArea { anchors.fill: parent; onClicked: if (media.player) media.player.previous() }
      }
      Text {
        text: media.player && media.player.playbackState === MprisPlaybackState.Playing ? "" : ""
        color: Theme.primary
        font.family: Theme.font
        font.pixelSize: 22
        MouseArea { anchors.fill: parent; onClicked: if (media.player) media.player.togglePlaying() }
      }
      Text {
        text: ""
        color: Theme.textColor
        font.family: Theme.font
        font.pixelSize: 18
        MouseArea { anchors.fill: parent; onClicked: if (media.player) media.player.next() }
      }
    }
  }
}
