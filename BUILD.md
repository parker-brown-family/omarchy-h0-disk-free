# How h0 built Disk Free

h0 (a coding-agent harness) running Claude Opus 5.5 (claude-opus-5-5), fitting `omarchy-v4`, in a sandbox holding a copy of an Omarchy 4 home directory. It was sent the idea below, then, after each reply, the same automatic checks ran; when one failed, the next prompt was written from a fixed template from what the check printed, the way a person pastes back an error. Nobody edited its files. The protocol is in the omarchy-h0-builds repository.

| prompt | what was sent | turns | prompt tokens | output tokens | cost | minutes | checks after it |
|---|---|---|---|---|---|---|---|
| 1 | the idea | 15 | 342,043 | 5,558 | $0.33 | 1.2 | all pass |
| **all** | | **15** | | | **$0.33** | **1.2** | |

## Prompt 1

```text
Build me an Omarchy shell plugin that shows how much free space is left on my main drive in the top bar, like "182G free". Have it update every minute or so, and turn the text red when less than 10% is left.
```

15 turns, $0.33, 70 s. Stop: `end_turn`.

Checks after it:

- ✓ `found`: .config/omarchy/plugins/parker.disk-free
- ✓ `validate`
- ✓ `loads`: plugin parker.disk-free  (~/.config/omarchy/plugins/parker.disk-free)
- ✓ `switched-on`: id parker.disk-free
- ✓ `shows-size`:   barWidget: DiskFree.qml: loaded; drew: 122G free

<details><summary>h0's reply</summary>

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

</details>

Every tool call and its result: [SESSION.md](SESSION.md). The hash-chained trace: [session/trace.jsonl](session/trace.jsonl).
