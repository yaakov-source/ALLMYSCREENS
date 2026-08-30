# ALLMYSCREENS

Portrait monitor zone manager — split each display into **Halves** or **Thirds** so apps snap into fixed containers instead of taking the full screen.

Fork of [MacsyZones](https://github.com/rohanrhu/MacsyZones) (GPL-3.0).

## Requirements

- macOS 13 Ventura or later
- **Full Xcode** (not Command Line Tools alone)
- Accessibility permission (System Settings → Privacy & Security → Accessibility)

# Download (no Xcode needed)

After pushing to GitHub, CI builds the app automatically. Download **ALLMYSCREENS.zip** from:

**GitHub → Actions → latest green run → Artifacts → ALLMYSCREENS-macOS**

Or from **Releases** once available.

Unzip, drag `ALLMYSCREENS.app` to Applications, grant Accessibility, launch.

## Build locally (optional)

Requires full Xcode (~12 GB):


Install the built app:

```bash
cp -R ALLMYSCREENS/build/Build/Products/Release/ALLMYSCREENS.app /Applications/
codesign --force --deep --sign - /Applications/ALLMYSCREENS.app
open /Applications/ALLMYSCREENS.app
```

## Usage

1. Grant **Accessibility** when prompted.
2. On first launch with two portrait monitors, pick **Halves** or **Thirds** for both screens.
3. Open the menu bar icon → **Quick Layouts** to change layout anytime:
   - **Halves** — 2 stacked zones per monitor (4 total)
   - **Thirds** — 3 stacked zones per monitor (6 total)
   - **Apply to** — Left / Right / Both
4. **Shift+drag** a window into a zone (or use Quick Snapper: Control+Shift+S).

## Repo layout

```
ALLMYSCREENS/
├── README.md           # this file
├── scripts/            # build, backup, upstream clone
├── upstream/           # pristine MacsyZones reference
└── ALLMYSCREENS/       # fork (Xcode project + customizations)
```

## Backups

Before changes:

```bash
./scripts/backup-tag.sh v1-presets
```

## Upstream sync

Refresh upstream reference (does not auto-merge):

```bash
./scripts/clone-upstream.sh
```

## License

GPL-3.0 — see [LICENSE](ALLMYSCREENS/LICENSE). Based on MacsyZones by Oğuzhan Eroğlu.
