import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.blackscaletech.portal-prompt"

  property string connectivity: "unknown"
  readonly property bool needsAttention: connectivity === "portal" || connectivity === "limited"

  readonly property string loginUrl: {
    var candidate = String(setting("loginUrl", "http://example.com/")).trim()
    return /^http:\/\/\S{1,2048}$/i.test(candidate) ? candidate : "http://example.com/"
  }

  readonly property string statusText: connectivity === "portal"
    ? "Wi-Fi sign-in required"
    : "Internet connectivity is limited"

  function applyStatus(output) {
    var value = String(output || "").trim().toLowerCase()
    connectivity = /^(none|portal|limited|full|unknown)$/.test(value) ? value : "unknown"
  }

  function refresh(forceCheck) {
    if (connectivityProbe.running) return

    connectivityProbe.command = forceCheck
      ? ["env", "LC_ALL=C", "nmcli", "networking", "connectivity", "check"]
      : ["env", "LC_ALL=C", "nmcli", "-t", "-f", "CONNECTIVITY", "general"]
    connectivityProbe.running = true
  }

  function openLoginPage() { Util.execArgv(["xdg-open", loginUrl]) }

  visible: needsAttention
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  Component.onCompleted: refresh(true)

  Process {
    id: connectivityProbe

    stdout: StdioCollector {
      id: connectivityOutput
      waitForEnd: true
    }

    onExited: function(exitCode) {
      if (exitCode === 0) root.applyStatus(connectivityOutput.text)
      else root.connectivity = "unknown"
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: root.refresh(false)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf071"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    active: true
    tooltipText: root.statusText + "\nLeft-click: open login page\nRight-click: recheck"

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.refresh(true)
      else if (buttonCode === Qt.LeftButton) root.openLoginPage()
    }
  }
}
