# Lunar Landing Site Navigator

A 3D mission planning tool for rapid evaluation of lunar landing site options across different dates and mission windows.

This project addresses the NASA Space Apps Challenge objective of assessing lunar landing site feasibility by visualizing Sun and Earth positions relative to the local horizon, calculating sunlight and direct-to-Earth communication windows, and comparing multiple candidate sites side-by-side.

## Core Features

The program is designed to:

- Select landing sites from curated mission presets (Artemis South Pole targets, Apollo, CLPS) or input custom lunar coordinates.
- Compute solar and Earth elevation/azimuth trajectories using NASA NAIF SPICE (`DE421`) ephemerides and optical libration models.
- Reconstruct 360° local horizon profiles from NASA LOLA Digital Elevation Models (DEM) without atmospheric refraction.
- Calculate live countdown timers to sunset and Earthset, sunlight availability percentages, longest continuous darkness periods, and horizontal solar panel output.
- Visualize global orbital geometry, 3D local terrain with slope overlays, and side-by-side multi-site comparisons across customizable mission timelines.

%%%%%%%%%%%

## Project Objective

This simulation demonstrates how real lunar topography data, planetary ephemerides, and 3D terrain ray-casting can be combined to evaluate landing site viability, power survival, and communication constraints prior to mission deployment.

%%%%%%%%%%%

## How It Works

The simulation pipeline integrates three core layers:

- **Ephemeris & Geometry Engine:** Computes topocentric Sun and Earth vectors relative to the lunar surface for any chosen UTC window.
- **LOLA Horizon Ray-Casting:** Evaluates 360° terrain obstruction angles around the landing mast to determine true geometric line-of-sight.
- **Interactive 3D & Timeline Workspace:** Renders a seamless transition from the global Moon view to local LOLA terrain with dynamic shadows, a 3D lander touchdown animation, and a multi-track Gantt timeline.

%%%%%%%%%%%

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
