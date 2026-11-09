# h0 building Disk Free

Rendered from the session's recorded trace (`trace.jsonl`), not from a screen capture. Workspace paths are shown as `~`; tool output is cut to its first 40 lines.

Model `claude-opus-5-5` · fitting `omarchy-v4` · tools read, edit, write, grep, glob, bash, check

---

### › You

```text
Build me an Omarchy shell plugin that shows how much free space is left on my main drive in the top bar, like "182G free". Have it update every minute or so, and turn the text red when less than 10% is left.
```

**⏺ bash** `cat /usr/share/omarchy/default/agents/skills/omarchy/plugins.md; ls .config/omarchy/plugins 2>/dev/null; ls $OMARCHY_PATH/shell/plugins/ /usr/share/omarchy/shell/plugins/; cat .config/omarchy/shell.json`

✓ 48 ms

```text
[exit 0, 43 ms]
# Omarchy Shell: Bar, Plugins, and Idle

Read this before changing the status bar, notifications, shell plugins,
widgets, or idle/lock behavior.

The bar, notification daemon, settings panel, and assorted overlays all run
inside a single long-running Quickshell process (`omarchy-shell`).

```
~/.config/omarchy/shell.json             # User overrides: bar, plugins, idle
~/.config/omarchy/plugins/<plugin-id>/   # User-owned shell plugins
$OMARCHY_PATH/config/omarchy/shell.json  # Canonical defaults
```

The shell hot-reloads `shell.json` on save — no restart needed for layout
changes. `idle.screensaver` and `idle.lock` are seconds since user idle began.

**Commands:** `omarchy restart shell`, `omarchy refresh shell`

## Bar Layout

Use the `omarchy bar` group to move and manage widgets:

```bash
omarchy bar move omarchy.clock --section right
```

For layout edits beyond what the commands cover, edit the bar configuration
in `~/.config/omarchy/shell.json`; it hot-reloads on save.

## Customizing Built-In Plugins and Widgets

To customize a built-in bar widget, never edit `$OMARCHY_PATH/shell/plugins/`.
Clone it into the user plugin directory instead:

```bash
omarchy plugin clone omarchy.workspaces
# Edit ~/.config/omarchy/plugins/<username>.workspaces/; saved changes reload automatically.
```
…
```

**⏺ bash** `cd /usr/share/omarchy/shell/plugins; cat README.md; ls bar bar/*; `

✓ 70 ms

```text
[exit 0, 64 ms]
# First-party plugins

These plugins ship with Omarchy and are discovered by the shell at startup.
They use the same `manifest.json` contract as third-party plugins; the
only difference is that the shell flags them with `__isFirstParty: true`.
First-party non-bar plugins are enabled unless listed in `disabledPlugins[]`;
`omarchy.bar` is the default bar option and becomes inactive only while another
`kind: "bar"` plugin is selected. Services and keep-loaded panels are mounted
at startup; other panels, overlays, and menus are loaded on demand.

User-installed plugins live alongside these conceptually but on disk under
`~/.config/omarchy/plugins/<plugin-id>/` rather than in this directory.

| Plugin        | id                        | kinds                   | entry point                           |
|---------------|---------------------------|-------------------------|---------------------------------------|
| Bar           | `omarchy.bar`             | `bar`                   | `bar/Bar.qml`                         |
| Image picker  | `omarchy.image-picker`    | `overlay`               | `image-picker/ImagePicker.qml`        |
| Emojis        | `omarchy.emojis`          | `overlay`               | `emojis/Emojis.qml`                   |
| Clipboard mgr | `omarchy.clipboard`       | `overlay`               | `clipboard/Clipboard.qml`             |
| Reminders     | `omarchy.reminders`       | `overlay`               | `reminders/ReminderFlow.qml`          |
| Omarchy menu  | `omarchy.menu`            | `menu`, `bar-widget`    | `menu/Menu.qml`, `menu/BarWidget.qml` |
| Notifications | `omarchy.notifications`   | `service`               | `notifications/Service.qml`           |
| Audio         | `omarchy.audio`           | `bar-widget`            | `panels/audio/Panel.qml`              |
| Bluetooth     | `omarchy.bluetooth`       | `bar-widget`            | `panels/bluetooth/Panel.qml`          |
| Clock         | `omarchy.clock`           | `bar-widget`            | `panels/clock/BarWidget.qml`          |
| Monitor       | `omarchy.monitor`         | `bar-widget`            | `panels/monitor/Panel.qml`            |
| Network       | `omarchy.network`         | `bar-widget`            | `panels/network/Panel.qml`            |
| Power         | `omarchy.power`           | `bar-widget`            | `panels/power/Panel.qml`              |
| Tailscale     | `omarchy.tailscale`       | `bar-widget`            | `panels/tailscale/Panel.qml`          |
| Agents   | `omarchy.agents`     | `bar-widget`            | `agents/Panel.qml`               |
| Weather       | `omarchy.weather`         | `bar-widget`            | `panels/weather/BarWidget.qml`        |
| Media         | `omarchy.media`           | `service`, `bar-widget` | `services/media/Service.qml`, `services/media/BarWidget.qml` |
| Battery       | `omarchy.battery`         | `service`               | `services/battery/Service.qml`        |
| Idle          | `omarchy.idle`            | `service`               | `services/idle/Service.qml`           |
| Night light   | `omarchy.nightlight`      | `service`               | `services/nightlight/Service.qml`     |
| Lock screen   | `omarchy.lock`            | `service`               | `lock/Service.qml`                    |
| OSD           | `omarchy.osd`             | `panel`                 | `osd/Osd.qml`                         |
| Polkit agent  | `omarchy.polkit`          | `service`               | `polkit/PolkitAgent.qml`              |

…
```

**⏺ bash** `cd /usr/share/omarchy/shell/plugins; cat bar/README.md; cat bar/widgets/SystemUpdate.manifest.json bar/widgets/SystemUpdate.qml`

✓ 49 ms

```text
[exit 0, 43 ms]
# Omarchy bar

This is the Quickshell implementation of the Omarchy status bar. It is
shipped as a first-party plugin of [`omarchy-shell`](../../README.md), the
long-running shell host. The bar is mounted at startup and lives inside
the shell for its whole session.

- `manifest.json` declares the plugin (`id: omarchy.bar`, `kind: bar`) and points at `Bar.qml` as the entry point.
- `Bar.qml` is Omarchy-owned bar engine code, loaded by the omarchy-shell host. Users should not edit it directly.
- `widgets/` holds simple first-party bar widgets with sibling manifests.
- Feature plugins such as `../panels/audio/`, `../panels/network/`, `../panels/power/`, and `../agents/` provide richer popup bar plugins.
- The bar receives its config from the host shell as a `barConfig` property; the host loads it from `~/.config/omarchy/shell.json` (or `config/omarchy/shell.json` when the user has no file).
- `omarchy bar position` updates only the user shell.json file.

## Customizing

The bar config lives under the `bar:` key of [`~/.config/omarchy/shell.json`](../../README.md#shelljson-shape). Out of the box the shell uses [`config/omarchy/shell.json`](../../../config/omarchy/shell.json). Once you customize anything via the bar gestures, `omarchy bar ...`, or by editing shell.json directly, your file is canonical — there is no deep-merge.

The bar is configured directly on the bar itself: drag empty bar space (or click-and-hold) to move the bar to another screen edge, double-left-click empty center-bar space to toggle transparency, and drag widgets to reorder them. The `omarchy bar position`, `omarchy bar transparent`, `omarchy bar move`, and `omarchy bar set` commands do the same from scripts. Enable or disable widgets with `omarchy plugin enable` and `omarchy plugin disable` (widget ids come from `omarchy plugin list`).

Example `shell.json` (bar subtree only shown):

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "transparent": false,
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [
        { "id": "omarchy.menu" },
        { "id": "omarchy.spacer", "size": 12 },
        { "id": "omarchy.workspaces" }
      ],
      "center": [
        { "id": "omarchy.media" },
        { "id": "omarchy.clock", "format": "HH:mm" }
      ],
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; ls; sed -n 1,400p README.md | grep -n -i -A3 "manifest\|barWidget\|settings\|BarText\|BarLabel" | head -150`

✓ 49 ms

```text
[exit 0, 44 ms]
Commons
README.md
Ui
plugins
services
shell.qml
23:    BarWidgetRegistry.qml unified registry for bar widgets (1p + 3p)
24-  plugins/
25-    bar/                 first-party plugins (see plugins/README.md)
26-    image-picker/
--
46:## Plugin manifest
47-
48:Every plugin ships a `manifest.json` describing what it is and how the
49-shell should load it. Minimal example:
50-
51-```json
--
60:  "entryPoints": { "barWidget": "Widget.qml" },
61:  "barWidget": {
62-    "displayName": "Cool clock",
63-    "category": "Time",
64-    "allowMultiple": false,
--
96:Entry points may declare `omarchyPath`, `shell`, `manifest`, `pluginRegistry`, and `barWidgetRegistry` properties for host injection. Built-in plugins receive the trusted host objects. Third-party plugins receive capability-scoped facades: ordinary plugins can look up and control only their own service and lifecycle, built-in clones retain narrow source-specific configuration and UI compatibility, menu plugins receive an application-library facade, and plugins can read detached scalar bar state. A full-bar plugin additionally receives detached bar configuration and widget-catalog snapshots, narrow proxies for the non-authentication services used by built-in bar widgets, and lifecycle control over configured non-authentication UI plugins. Authentication capabilities are stamped from trusted first-party manifests, authentication services are retained outside the host's public service map and QML object tree, and changing a third-party registry or configuration snapshot cannot mutate host state. Facades do not isolate visual widgets from the parent hierarchy of the shared QML scene, so sensitive state must remain outside that reachable graph.
97-
98:Widgets rendered by a third-party replacement bar receive a service-less entry facade with target-scoped lifecycle and settings operations. Their live service objects are available only when the trusted built-in bar hosts them; otherwise the replacement bar could request and retain any configured widget's service.
99-
100-The full schema lives in `services/PluginRegistry.qml`.
101-
--
104:A plugin is a **git repo** with a `manifest.json` at its root. Adding one
105-clones it straight into `~/.config/omarchy/plugins/<id>/` (named by the
106:manifest id); updating is a fast-forward pull of that checkout.
107-
108-```bash
109-omarchy plugin add https://github.com/acme/omarchy-weather.git
--
127:files, validates the manifest, and toggles enabled state over shell IPC. Since
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat plugins/panels/clock/BarWidget.qml | head -120; ls Ui Commons 2>/dev/null`

✓ 47 ms

```text
[exit 0, 43 ms]
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Date/time label for the bar, and the host for the calendar popup.
//
// Left click reveals the calendar — asking "what is the date?" is what a
// click on a clock means — right click walks the common label formats, and
// middle click opens the timezone picker.
BarWidget {
  id: root
  moduleName: "omarchy.clock"

  property date displayDate: clock.date

  readonly property string configuredFormat: vertical
    ? setting("verticalFormat", "HH\n—\nmm")
    : setting("format", "dddd HH:mm")
  readonly property string configuredAltFormat: vertical
    ? setting("verticalFormatAlt", "dd\nMMM\n'W'ww\n''yy")
    : setting("formatAlt", "d MMMM 'W'ww yyyy")

  readonly property var formatRing: Model.clockFormatRing(configuredFormat, configuredAltFormat, Model.clockFormats(vertical))

  // What the bar shows is what shell.json stores, so a cycled format is the
  // format from then on rather than something that reverts on restart.
  readonly property string activeFormat: configuredFormat
  readonly property string displayText: formatted(displayDate)
  readonly property var verticalLines: displayText.split("\n")

  function refresh() {
    displayDate = new Date()
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function cycleFormat() {
…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 46,100p README.md; cat Ui/BarWidget.qml Ui/BarIconButton.qml; grep -n "urgent\|statusSlot\|caption" Commons/Style.qml Commons/Color.qml | head -30`

✓ 50 ms

```text
[exit 0, 44 ms]
## Plugin manifest

Every plugin ships a `manifest.json` describing what it is and how the
shell should load it. Minimal example:

```json
{
  "schemaVersion": 1,
  "id": "my.org.cool-clock",
  "name": "Cool clock",
  "version": "1.0.0",
  "author": "You",
  "description": "A clock that does cool things",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "Cool clock",
    "category": "Time",
    "allowMultiple": false,
    "defaultSection": "left",
    "defaults": { "format": "HH:mm" },
    "schema": [
      { "key": "format", "type": "string", "label": "Format" }
    ]
  }
}
```

Supported `kinds`:

| Kind         | What it is                                                   |
|--------------|--------------------------------------------------------------|
| `bar-widget` | A component that the active bar can drop into a section      |
| `panel`      | A persistent or summoned floating window (e.g. OSD)          |
| `overlay`    | A fullscreen overlay (e.g. background switcher)              |
| `menu`       | A summoned menu surface                                      |
| `service`    | A headless singleton, no UI                                  |
| `bar`        | A full bar option that can replace the built-in `omarchy.bar` |

…
```

**⏺ bash** `cd /usr/share/omarchy/shell; cat plugins/bar/widgets/KeyboardLayout.qml | head -80; grep -n "property" Ui/WidgetButton.qml | head -60`

✓ 48 ms

```text
[exit 0, 43 ms]
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui
import qs.Commons
import "KeyboardLayoutModel.js" as KeyboardLayoutModel

BarWidget {
  id: root
  moduleName: "omarchy.keyboard-layout"


  property string layoutFull: ""
  // The keyboard the last reading spoke for, which is the one a click switches,
  // and separately the one activelayout named as being typed on. A reading
  // confirms the first is really there, so the click has a keyboard to reach
  // from the first reading onwards rather than only after a switch, and stops
  // naming one that has been unplugged.
  property string keyboardName: ""
  property string typedKeyboardName: ""
  // Keyboards on the seat, buttons and virtual ones excluded, and whether the
  // last reading left that shape in doubt.
  property int keyboardCount: 0
  property bool keyboardUnresolved: false
  // Nothing to read or switch on the single-layout install most people run, so
  // the widget ships on the bar and stays out of the way until there are two.
  // An older Hyprland that doesn't report the list keeps showing the label.
  property bool multipleLayouts: true
  // Short language code per layout description ("English (US)": "en"), read from
  // xkb's own table rather than maintained by hand.
  property var layoutBriefs: ({})
  readonly property string layoutLabel: KeyboardLayoutModel.shortLabel(layoutFull, layoutBriefs)

  // A query already in flight was started before this event, so it may read the
  // layout the switch replaced. Remember the request and re-run once it lands
  // rather than dropping it; nothing else would correct the label afterwards.
  property bool refreshPending: false

…
```

**⏺ bash** `cd /usr/share/omarchy/shell; sed -n 80,400p plugins/bar/widgets/KeyboardLayout.qml | grep -n -B3 -A25 "WidgetButton {"; whoami; grep -n "barWidget\|defaultSection\|schema\|\"id\"\|idPattern\|RegExp\|test(" services/PluginRegistry.qml | head -60`

✓ 47 ms

```text
[exit 0, 43 ms]
126-  implicitWidth: button.implicitWidth
127-  implicitHeight: button.implicitHeight
128-
129:  WidgetButton {
130-    id: button
131-    anchors.fill: parent
132-    bar: root.bar
133-    text: root.layoutLabel
134-    fontSize: Style.font.caption
135-    horizontalMargin: 6
136-    tooltipText: root.layoutFull
137-    onPressed: function() { root.cycleLayout() }
138-  }
139-}
parker
48:    if (manifest.schemaVersion !== 1) {
49:      console.warn("PluginRegistry: unsupported schemaVersion at " + sourcePath)
52:    var required = ["id", "name", "version", "kinds", "entryPoints"]
72:    if (manifest.barWidget !== undefined && Util.isPlainObject(manifest.barWidget)
73:        && manifest.barWidget.defaultSection !== undefined) {
74:      var defaultSection = String(manifest.barWidget.defaultSection)
75:      if (["left", "center", "right"].indexOf(defaultSection) === -1) {
76:        console.warn("PluginRegistry: invalid barWidget.defaultSection at " + sourcePath)
195:    var metadata = manifest && Util.isPlainObject(manifest.barWidget) ? manifest.barWidget : null
196:    var section = metadata ? String(metadata.defaultSection || "") : ""
```

**⏺ bash** `cd /usr/share/omarchy/shell; grep -rn -A4 "StdioCollector" plugins | head -20; ls /usr/share/omarchy/shell/plugins/bar/widgets/ ; grep -rln "qs.Ui" ~/.config 2>/dev/null; ls -a .config 2>/dev/null; ls ~/.config/omarchy`

✓ 48 ms

```text
[exit 0, 44 ms]
plugins/agents/Main.qml:29:    stdout: StdioCollector {
plugins/agents/Main.qml-30-      waitForEnd: true
plugins/agents/Main.qml-31-      onStreamFinished: root.applyAgentListing(text)
plugins/agents/Main.qml-32-    }
plugins/agents/Main.qml-33-  }
--
plugins/agents/Main.qml:140:    stderr: StdioCollector {
plugins/agents/Main.qml-141-      waitForEnd: true
plugins/agents/Main.qml-142-      onStreamFinished: if (text.trim() !== "") console.warn("agents", text.trim())
plugins/agents/Main.qml-143-    }
plugins/agents/Main.qml-144-  }
--
plugins/agents/Main.qml:337:    stdout: StdioCollector {
plugins/agents/Main.qml-338-      waitForEnd: true
plugins/agents/Main.qml-339-      onStreamFinished: root.parseSyncScanOutput(text)
plugins/agents/Main.qml-340-    }
plugins/agents/Main.qml-341-
plugins/agents/Main.qml:342:    stderr: StdioCollector {
plugins/agents/Main.qml-343-      waitForEnd: true
plugins/agents/Main.qml-344-      onStreamFinished: if (text.trim() !== "") console.warn("agents/sync", text.trim())
ActiveWindow.manifest.json
ActiveWindow.qml
Indicators.manifest.json
Indicators.qml
KeyboardLayout.manifest.json
KeyboardLayout.qml
KeyboardLayoutModel.js
Microphone.manifest.json
Microphone.qml
Spacer.manifest.json
Spacer.qml
SystemUpdate.manifest.json
SystemUpdate.qml
Tray.manifest.json
Tray.qml
TrayModel.js
Workspaces.manifest.json
Workspaces.qml
extensions
…
```

Now writing the plugin.

**⏺ write** `.config/omarchy/plugins/parker.disk-free/manifest.json`

```
{
  "schemaVersion": 1,
  "id": "parker.disk-free",
  "name": "Disk free",
  "version": "1.0.0",
  "author": "parker",
  "description": "Shows free space on a drive, red when it runs low",
  "kinds": [
    "bar-widget"
  ],
  "entryPoints": {
    "barWidget": "DiskFree.qml"
  },
  "barWidget": {
    "displayName": "Disk free",
    "description": "Free space on a drive, e.g. \"182G free\"",
    "category": "System",
    "allowMultiple": true,
    "defaultSection": "right",
    "defaults": {
      "path": "/",
      "interval": 60,
      "lowPercent": 10
    },
    "schema": [
      { "key": "path", "type": "string", "label": "Mount point" },
      { "key": "interval", "type": "number", "label": "Refresh interval (seconds)" },
      { "key": "lowPercent", "type": "number", "label": "Turn red below (% free)" }
    ]
  }
}
```

✓ 1 ms

```text
wrote 831 bytes to .config/omarchy/plugins/parker.disk-free/manifest.json
```

**⏺ write** `.config/omarchy/plugins/parker.disk-free/DiskFree.qml`

```
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
… (32 more lines in the repository)
```

✓ 0 ms

```text
wrote 2815 bytes to .config/omarchy/plugins/parker.disk-free/DiskFree.qml
```

**⏺ bash** `cd .config/omarchy && cp shell.json shell.json.bak.$(date +%s) && python3 - <<'E'
import json
p='shell.json'; d=json.load(open(p))
r=d['bar']['layout']['right']
r.insert(r.index(next(x for x in r if x['id']=='omarchy.tray'))+1, {"id":"parker.disk-free","path":"/","interval":60,"lowPercent":10})
json`

✓ 68 ms

```text
[exit 0, 64 ms]
diff --git a/shell.json.bak.1794262769 b/shell.json
index e6202da..9b17ea3 100644
--- a/shell.json.bak.1794262769
+++ b/shell.json
@@ -41,6 +41,12 @@
         {
           "id": "omarchy.tray"
         },
+        {
+          "id": "parker.disk-free",
+          "path": "/",
+          "interval": 60,
+          "lowPercent": 10
+        },
         {
           "id": "omarchy.agents"
         },
    1B-blocks        Avail
1022042832896 131443007488
```

**⏺ check** `build`

✓ 2920 ms

```text
[exit 0, 2917 ms]
plugin parker.disk-free  (~/.config/omarchy/plugins/parker.disk-free)
  barWidget: DiskFree.qml: loaded; drew: 122G free
    picture: ~/.h0-preview/parker.disk-free-barWidget.png
PREVIEW: ok
```

The widget renders "122G free" (131443007488 B ÷ 1024³ ≈ 122.4G, matching `df`). Let me also confirm the red state by temporarily raising the threshold.

**⏺ bash** `cd .config/omarchy && sed -i 's/"lowPercent": 10$/"lowPercent": 99/' shell.json && grep lowPercent shell.json; ls /usr/share/omarchy/ -d; ls .. >/dev/null; find ~ -name "preview.py" -maxdepth 4 2>/dev/null | head`

✓ 50 ms

```text
[exit 0, 44 ms]
          "lowPercent": 99
/usr/share/omarchy/
```

**⏺ check** `preview`

✓ 2828 ms

```text
[exit 0, 2824 ms]
plugin parker.disk-free  (~/.config/omarchy/plugins/parker.disk-free)
  barWidget: DiskFree.qml: loaded; drew: 122G free
    picture: ~/.h0-preview/parker.disk-free-barWidget.png
PREVIEW: ok
```

**⏺ bash** `python3 -c "
from PIL import Image
im=Image.open('.h0-preview/parker.disk-free-barWidget.png').convert('RGB')
from collections import Counter
print(im.size, Counter(im.getdata()).most_common(4))" 2>&1 | tail -3`

✓ 87 ms

```text
[exit 0, 83 ms]
  File "<string>", line 2, in <module>
    from PIL import Image
ModuleNotFoundError: No module named 'PIL'
```

I can't check pixel colours here because PIL isn't installed, and the preview may not read settings from shell.json anyway. Restoring the threshold to 10:

**⏺ bash** `cd .config/omarchy && sed -i 's/"lowPercent": 99$/"lowPercent": 10/' shell.json && grep lowPercent shell.json && python3 -m json.tool shell.json >/dev/null && echo ok`

✓ 200 ms

```text
[exit 0, 193 ms]
          "lowPercent": 10
ok
```

**⏺ check** `build`

✓ 3762 ms

```text
[exit 0, 3757 ms]
plugin parker.disk-free  (~/.config/omarchy/plugins/parker.disk-free)
  barWidget: DiskFree.qml: loaded; drew: 122G free
    picture: ~/.h0-preview/parker.disk-free-barWidget.png
PREVIEW: ok
```

**⏺ check** `validate`

✓ 173 ms

```text
[exit 0, 168 ms]
valid: .config/omarchy/plugins/parker.disk-free/
```

I built a top-bar plugin that shows free space on your main drive (`/`). In the offscreen preview it showed **"122G free"**, which matches what `df` reports for this machine. I haven't been able to confirm that the red colour actually appears.

**New plugin: `.config/omarchy/plugins/parker.disk-free/`**
- `manifest.json` describes it as a bar widget with three settings: `path` (`/`), `interval` (`60` seconds) and `lowPercent` (`10`).
- `DiskFree.qml` checks free space with `df` once a minute and shows it in the same units as `df -h` (e.g. `182G`, or `9.4G` with one decimal below 10).
  - It turns red when free space is below `lowPercent` of the drive's size. The red is your theme's "urgent" colour, the same one other widgets use for alerts, so the exact shade depends on your theme.
  - Hovering shows a tooltip like `/: 122G of 952G free (12.9%)`.
  - Clicking it refreshes right away.

**`.config/omarchy/shell.json`:** I added the widget to the right side of the bar, just after the tray, and saved a backup first (`shell.json.bak.<timestamp>`). To change the drive, threshold or refresh rate, edit that entry. To move it, run `omarchy bar move parker.disk-free --section left|center|right`.

**Checks**
- Omarchy's own plugin checker passes, and the shell.json syntax check passes.
- The full build check, which loads the widget offscreen, passes with no errors and draws "122G free".
- **Not confirmed:** I tried raising the threshold to 99% so the text would go red. I couldn't check the colour because the image library (PIL) isn't installed here, and I'm not sure the preview reads settings from shell.json at all. The threshold is back to 10.

**On your desktop:** the shell should pick up the new plugin by itself. If the widget doesn't appear, run `omarchy-shell shell rescanPlugins`, then `omarchy plugin enable parker.disk-free`. To see the red state without filling your disk, set `"lowPercent": 99` in the widget's shell.json entry for a moment, then set it back.

*harness: verify check `build` passed*

