# Lunar Landing Site Navigator — 1.0

A 3D mission planning tool for rapid evaluation of lunar landing site options across different dates and mission windows.

This project addresses the NASA Space Apps Challenge objective of assessing lunar landing site feasibility by visualizing Sun and Earth positions relative to the local horizon, calculating sunlight and direct-to-Earth communication windows, and comparing multiple candidate sites side-by-side.

## Windows download


Use **LunarNavigator-1.0-Setup.exe** from the [GitHub release](https://github.com/pentalux/Lunar-Landing-Site-Navigator/releases/tag/v1.0.0). The installer includes Qt, QML plugins and the MinGW runtime, installs for the current user, and creates a Start menu shortcut. No Qt or Python installation is needed to run it.

Alternatively, extract **LunarNavigator-1.0-Windows-x64.zip** completely and run `LunarNavigator.exe` inside the extracted folder. Keep its DLLs, `platforms` and `qml` directories together. Copying only the application EXE is not a portable deployment.

The viewer combines an overview globe with regional terrain.


## Core Features

The program is designed to:

- Save up to 20 mission configurations, restore them from history, and compare saved custom locations with reference presets. Saved configurations retain their dates and hardware settings.

- Select landing sites from curated mission presets (Artemis South Pole targets, Apollo, CLPS) or input custom lunar coordinates.
- Compute solar and Earth elevation/azimuth trajectories using NASA NAIF SPICE (`DE421`) ephemerides and optical libration models.
- Reconstruct 360° local horizon profiles from NASA LOLA Digital Elevation Models (DEM) without atmospheric refraction.
- Calculate live countdown timers to sunset and Earthset, sunlight availability percentages, longest continuous darkness periods, and horizontal solar panel output.
- Visualize global orbital geometry, 3D local terrain with slope overlays, and side-by-side multi-site comparisons across customizable mission timelines.


## Project Objective

This simulation demonstrates how real lunar topography data, planetary ephemerides, and 3D terrain ray-casting can be combined to evaluate landing site viability, power survival, and communication constraints prior to mission deployment.


## How It Works

The simulation pipeline integrates three core layers:

- **Ephemeris & Geometry Engine:** Computes topocentric Sun and Earth vectors relative to the lunar surface for any chosen UTC window.
- **LOLA Horizon Ray-Casting:** Evaluates 360° terrain obstruction angles around the landing mast to determine true geometric line-of-sight.
- **Interactive 3D & Timeline Workspace:** Renders a seamless transition from the global Moon view to local LOLA terrain with dynamic shadows, a 3D lander touchdown animation, and a multi-track Gantt timeline.


## Computational Methods & Mathematical Model

1. **Topocentric Ephemerides & Libration (`SPICE DE421`):**
   - Planetary state vectors for the Sun and Earth relative to the Moon's center are queried in the `MOON_ME` (Mean Earth / Polar Axis) body-fixed reference frame using NASA NAIF SPICE kernels (`de421.bsp`).
   - Vectors are transformed from selenocentric to topocentric East-North-Up (ENU) local coordinates at the exact landing latitude, longitude, and LOLA surface elevation, inherently capturing lunar axial tilt ($1.54^\circ$), orbital eccentricity, and optical/physical libration.

2. **Airless Horizon & Terrain Ray-Casting (`LOLA DEM`):**
   - Because the Moon lacks an atmosphere, atmospheric refraction is set to zero ($0^\circ$). The visible horizon is governed purely by spherical curvature and local topography.
   - For each candidate site, the solver samples radial elevation profiles across $360^\circ$ of azimuth (out to $100\text{–}150\text{ km}$ from LOLA Digital Elevation Models) and computes the maximum terrain obstruction angle:
     $$\theta_{\text{horizon}}(\text{Az}) = \max_{r} \arctan\left(\frac{h(r) - (h_0 + h_{\text{mast}}) - \frac{r^2}{2 R_{\text{Moon}}}}{r}\right)$$
     accounting for mast height $h_{\text{mast}}$ and lunar curvature drop $\frac{r^2}{2 R_{\text{Moon}}}$.

3. **Line-of-Sight, Power & Countdown Windows:**
   - **Solar Illumination:** True when solar elevation $\alpha_{\text{Sun}}(t) > \theta_{\text{horizon}}(\text{Az}_{\text{Sun}})$. Instantaneous horizontal array power is modeled via cosine projection:
     $$P(t) = P_{\text{rated}} \cdot \max(0, \sin \alpha_{\text{Sun}}(t))$$
   - **Direct-to-Earth (DTE) Link:** Valid when Earth elevation exceeds the local horizon plus the user-defined clearance margin:
     $$\alpha_{\text{Earth}}(t) > \theta_{\text{horizon}}(\text{Az}_{\text{Earth}}) + \Delta\theta_{\text{margin}}$$
   - **Operational Countdowns:** The solver scans forward along the time series to determine exact remaining hours/minutes until the next horizon crossing (`Time to Sunset` and `Time to Earthset`) as well as the longest continuous darkness interval.

## Tech Stack & Data Sources

- **Frontend & 3D Rendering:** Qt 6, QML, Qt Quick 3D (`RuntimeLoader` for `.glb` spacecraft assets, PBR materials, dynamic directional shadows).
- **Backend & Astronomy Pipeline:** Python / C++ computational engine using NASA NAIF SPICE (`DE421` / `MOON_ME`).
- **3D Modeling:** Blender (custom octagonal lunar lander model exported to `.glb`).
- **NASA Datasets:**
  - **NASA Lunar Orbiter Laser Altimeter (LOLA) DEM:** Regional topography, slope angles, and 360° horizon obstruction profiles.
  - **NASA NAIF SPICE Toolkit (`de421.bsp`):** High-precision solar/Earth ephemerides and lunar libration.
  - **NASA CGI Moon Kit:** Global lunar surface albedo and elevation textures.

## AI / Synthetic Intelligence (SI) Disclosure

Large Language Models (LLM) were used during development to assist with QML UI layout structuring, boilerplate code generation, and documentation formatting. All astronomical calculations, NASA LOLA/SPICE data integration, 3D lander modeling, and engineering validation were implemented and verified by the team. No NASA logos, flags, or official emblems were generated or modified using AI.

---

*Created by P.A. Galochkin (@pentalux) and D.A. Golomako(@Lokgout) for the 2026 NASA International Space Apps Challenge*


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

