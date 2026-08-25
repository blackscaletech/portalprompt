import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.blackscale.portal-prompt"

  property string connectivity: "unknown"
  property bool initialCheckPending: true

  readonly property bool needsAttention:
    connectivity === "portal" || connectivity === "limited"

  readonly property string loginUrl: {
    var candidate = String(setting("loginUrl", "http://example.com/")).trim()
    return candidate.indexOf("http://") === 0
      ? candidate
      : "http://example.com/"
  }

  readonly property string statusText: connectivity === "portal"
    ? "Wi-Fi sign-in required"
    : "Internet connectivity is limited"

  function applyStatus(output) {
    var value = String(output || "").trim().toLowerCase()
    var known = ["none", "portal", "limited", "full", "unknown"]
    connectivity = known.indexOf(value) >= 0 ? value : "unknown"
  }

  function refresh(forceCheck) {
    if (connectivityProbe.running) return

    connectivityProbe.command = forceCheck
      ? ["env", "LC_ALL=C", "nmcli", "networking", "connectivity", "check"]
      : ["env", "LC_ALL=C", "nmcli", "-t", "-f", "CONNECTIVITY", "general"]
    connectivityProbe.running = true
  }

  function openLoginPage() {
    if (openPage.running) return
    openPage.command = ["xdg-open", loginUrl]
    openPage.running = true
  }

  visible: needsAttention
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

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

  Process {
    id: openPage
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.refresh(root.initialCheckPending)
      root.initialCheckPending = false
    }
  }

  IpcHandler {
    target: "io.github.blackscale.portal-prompt"

    function open(): void { root.openLoginPage() }
    function refresh(): void { root.refresh(true) }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf071"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: root.statusText + "\nLeft-click: open login page\nRight-click: recheck"

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.refresh(true)
      else if (buttonCode === Qt.LeftButton) root.openLoginPage()
    }
  }
}
