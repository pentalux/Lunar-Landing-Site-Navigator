# Lunar Landing Site Navigator — 0.10

Offline lunar landing-site planning application built with Qt Quick / Qt Quick 3D and Qt Design Studio. All application text is English.

## Windows download

Use **LunarNavigator-0.10-Setup.exe** from the [GitHub release](https://github.com/pentalux/Lunar-Landing-Site-Navigator/releases/tag/v0.10.0). The installer includes Qt, QML plugins and the MinGW runtime, installs for the current user, and creates a Start menu shortcut. No Qt or Python installation is needed to run it.

Alternatively, extract **LunarNavigator-0.10-Windows-x64.zip** completely and run `LunarNavigator.exe` inside the extracted folder. Keep its DLLs, `platforms` and `qml` directories together. Copying only the application EXE is not a portable deployment.

This release uses the 0.10 overview globe and regional terrain renderer. It does not include the cancelled experimental planetary quadtree or extra regional DEM datasets.

## Features

- Geographic lunar globe with stereographic polar appearance maps and measured LOLA terrain.
- One animated selection pin, placed by globe click, preset or custom coordinates.
- Regional terrain and a supplied lander model with rigid footpad contact.
- Sun/Earth geometry, local horizon, illumination, Earth visibility and favorable-window timeline.
- Fixed orbital camera reference while the lunar body rotates; approach, descent and return views.
- Offline ephemerides and lunar orientation covering 2026–2027 UTC.

Drag to orbit and use the mouse wheel to zoom. **Lander** frames the module, **Region** frames its surroundings, **Orbit view** returns to planetary context, and **Calculate simulation** starts the simplified descent. **Slope overlay** shows the existing slope classification.

## Clone and open in Qt Design Studio

Large runtime assets use Git LFS. Install Git LFS before cloning:

```powershell
git lfs install
git clone https://github.com/pentalux/Lunar-Landing-Site-Navigator.git
cd Lunar-Landing-Site-Navigator
git lfs pull
```

Open `Hackathon.qmlproject` in Qt Design Studio. Runtime assets are included in the repository; Python is only needed to regenerate scientific data.

## Build and package Windows x64

The release is built with Qt 6.12.0 / MinGW 13.1, CMake and Ninja. Required Qt modules include Core, Gui, Widgets, Qml, Quick, Quick3D, QuickTimeline and ShaderTools. The project requires Qt 6.8 or newer.

```powershell
powershell -ExecutionPolicy Bypass -File tools/Build-Windows.ps1
```

The script defaults to the standard `C:\Qt` SDK locations. Override `-QtRoot`, `-MinGWRoot`, `-CMake` and `-Ninja` for another installation. To also build the single-file installer, supply `-NsisCompiler` pointing to `makensis.exe` from NSIS 3:

```powershell
powershell -ExecutionPolicy Bypass -File tools/Build-Windows.ps1 -NsisCompiler C:\Tools\nsis\makensis.exe
```

Outputs are written to `releases/`: a complete portable folder, ZIP, optional installer and SHA-256 checksums. `windeployqt` from the matching SDK supplies runtime libraries and QML plugins. `qt.conf` selects the bundled directories.

Scientific assets are packaged once using compressed BIG_RESOURCES. `navigator-resources.cmake` handles Qt Design Studio regeneration and excludes local Python preparation dependencies from application resources.

## Data and scientific limits

The global LOLA source has approximately 474 m spacing at the equator; the south-polar base uses 80 m data. Fine display triangles do not create measurements beyond the source DEM. The lander has six rigid footpads; nonplanar ground can leave small gaps under some feet. Small rocks and landing hazards remain unresolved.

Visibility is geometric and power assumes horizontal panels. Descent is a simplified vertical controller. Earth/Sun display distances are compressed and fill lighting aids inspection. The application does not certify landing safety. See [data sources](docs/DATA_SOURCES.md) and [third-party notices](packaging/THIRD_PARTY_NOTICES.md).

## Development checks and data preparation

```powershell
node --test tests/mission.test.cjs tests/scene.test.cjs tests/terrain.test.cjs
```

Qt graphics scenarios are in `tests/tst_*.qml`; use the matching SDK's `qmltestrunner`. Tiled file reads require `QML_XHR_ALLOW_FILE_READ=1` and the 16K texture requires `QT_IMAGEIO_MAXALLOC=1024`; QDS and the native entry point set these options themselves.

`tools/prepare_science.py` and the preparation utilities document regeneration from NASA / NAIF sources. Python preparation requires numpy, rasterio, requests and spiceypy. Download caches and Python environments are excluded from Git. The packaged app works offline and does not use these tools at runtime.
