import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// "182G free" for one mount point (default "/"), refreshed every minute.
// The label turns the theme's urgent (red) colour when free space drops
// below lowPercent of the drive. Click to refresh, right click opens btop.
BarWidget {
  id: root
  moduleName: "parker.disk-free"

  readonly property string mountPath: String(setting("path", "/"))
  readonly property int intervalSeconds: Math.max(5, Number(setting("interval", 60)) || 60)
  readonly property real lowPercent: Number(setting("lowPercent", 10))

  property real totalBytes: 0
  property real freeBytes: 0
  property bool hasReading: false

  readonly property real freePercent: totalBytes > 0 ? (freeBytes / totalBytes) * 100 : 100
  readonly property bool low: hasReading && freePercent < lowPercent

  function humanSize(bytes) {
    var units = ["B", "K", "M", "G", "T", "P"]
    var value = bytes
    var i = 0
    while (value >= 1024 && i < units.length - 1) {
      value /= 1024
      i++
    }
    // One decimal for small numbers (e.g. 9.4G), whole numbers otherwise.
    var shown = value < 10 && i > 0 ? value.toFixed(1) : Math.round(value).toString()
    return shown + units[i]
  }

  function refresh() {
    if (!dfProc.running) dfProc.running = true
  }

  function parse(output) {
    // df -B1 --output=size,avail <path>: header line, then "<size> <avail>".
    var lines = String(output).trim().split("\n")
    if (lines.length < 2) return
    var fields = lines[lines.length - 1].trim().split(/\s+/)
    var size = Number(fields[0])
    var avail = Number(fields[1])
    if (!isFinite(size) || !isFinite(avail) || size <= 0) return
    totalBytes = size
    freeBytes = avail
    hasReading = true
  }

  onMountPathChanged: refresh()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: dfProc
    command: ["df", "-B1", "--output=size,avail", root.mountPath]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parse(text)
    }
  }

  Timer {
    interval: root.intervalSeconds * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.hasReading ? root.humanSize(root.freeBytes) + " free" : "… free"
    fontSize: Style.font.caption
    horizontalMargin: 6
    // active + activeColor paints the label in the theme's urgent colour.
    active: root.low
    tooltipText: root.hasReading
      ? root.mountPath + ": " + root.humanSize(root.freeBytes) + " of "
        + root.humanSize(root.totalBytes) + " free (" + root.freePercent.toFixed(1) + "%)"
      : root.mountPath
    onPressed: function() { root.refresh() }
  }
}
