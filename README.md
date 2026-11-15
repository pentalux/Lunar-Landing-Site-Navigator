https://github.com/user-attachments/assets/b8442792-b32a-458a-a96d-48774992c3b4



# Lunar Landing Site Navigator

A computational model and 3D visualization tool for evaluating lunar landing-site lighting and Earth visibility.

The project combines NASA lunar terrain data with SPICE-derived Sun and Earth positions to explore conditions across different locations and mission windows. It estimates sunlight availability, terrain obstruction, direct-to-Earth visibility, and horizontal solar-panel output.

## Core Features

The program is designed to:

- Select reference landing sites or choose custom lunar coordinates.
- Visualize the lunar globe, local terrain, and a 3D lander.
- Calculate Sun and Earth elevation and azimuth relative to the selected site.
- Reconstruct a 360° local terrain horizon.
- Estimate sunlight availability, Earth visibility, and the longest darkness interval.
- Calculate horizontal solar-panel power and estimated energy generation.
- Display an interactive timeline highlighting simultaneous sunlight and Earth visibility.
- Save mission configurations and restore them from history.
- Compare saved missions and reference sites.

## Project Objective

This simulation demonstrates how planetary ephemerides, lunar elevation models, and geometric visibility calculations can support preliminary landing-site assessment.

The application helps users investigate how location, mission dates, and observer height affect lighting, power-generation opportunities, and communication visibility.

<img width="1602" height="862" alt="Screenshot 2026-11-15 193716" src="https://github.com/user-attachments/assets/00c98ab4-e570-4b18-b248-531523dd1a21" />


## How It Works

The computational model consists of three main components:

- **Orbital Geometry:** Precomputed NASA/JPL SPICE vectors and lunar orientation data are interpolated to determine Sun and Earth directions relative to the selected observer.
- **Terrain Horizon:** NASA LOLA elevation profiles are sampled around the site to calculate terrain obstruction angles, accounting for observer height and lunar curvature.
- **Mission Analysis:** Hourly midpoint samples estimate sunlight availability, Earth visibility, favorable periods, darkness duration, and solar-panel output.

The Sun is considered visible when its center is above the terrain horizon. Earth visibility additionally requires the user-defined angular clearance margin.

Horizontal-panel power is calculated as:

$$
\Large P(t) = V_{\mathrm{Sun}}(t) \cdot P_{\mathrm{rated}} \cdot \max\left(0, \sin\alpha_{\mathrm{Sun}}(t)\right)
$$

where $V_{\mathrm{Sun}}$ equals 1 when the Sun is visible and 0 when blocked by terrain.

The **Favorable Window** track identifies periods when sunlight and Earth visibility overlap. Users can move the timeline cursor to inspect conditions at a selected simulation time.

Bundled data covers **2026–2027**, with mission durations of **28, 45, 60, or 90 days**.

<img width="1917" height="1077" alt="Screenshot 2026-11-15 192941" src="https://github.com/user-attachments/assets/3d1a3295-8397-4a86-a9e8-5c727f64c582" />

## Site Comparison

The **Compare sites** button opens a detailed comparison of saved mission configurations and reference locations.

The comparison includes:

- Sunlight availability.
- Earth-visibility availability.
- Total favorable hours and their percentage of the mission window.
- Longest darkness interval.
- Mean solar power and estimated energy generation.
- Coordinates, mission dates, and observer settings.

**Save** stores the current configuration and adds it to the comparison. **Restore** opens a history of up to 20 saved configurations.

Saved missions retain their own dates and hardware settings, while reference presets use the current settings. Equivalent dates and parameters should be used when comparing locations under the same conditions.

<img width="1917" height="1081" alt="Screenshot 2026-11-15 193240" src="https://github.com/user-attachments/assets/60be8807-2bf7-41af-afab-757f42e185b5" />


## Technology and NASA Data

- **Application:** Qt 6, QML, JavaScript, Qt Quick 3D, and a C++ launcher.
- **Data Preparation:** Python and SpiceyPy.
- **3D Modeling:** Blender.
- **Lunar Terrain and Appearance:** [NASA CGI Moon Kit](https://svs.gsfc.nasa.gov/4720/) and [south-polar LOLA elevation data](https://pgda.gsfc.nasa.gov/products/90).
- **Ephemerides and Reference Frames:** [NASA/JPL NAIF SPICE](https://naif.jpl.nasa.gov/naif/data_generic.html), including DE421.
- **Earth Appearance:** NASA Blue Marble Next Generation.

## Model Limitations

The computational model supports preliminary exploration rather than mission certification.

Global terrain spacing is approximately 474 m at the equator, with 80 m data in the bundled south-polar coverage. Small rocks and footpad-scale hazards remain unresolved.

Visibility uses body-center geometry without eclipse or radio-link modeling. Solar-power estimates exclude batteries, thermal effects, and electrical losses. Availability statistics use hourly samples, and the lander animation uses a simplified vertical controller.

---

*Created by P.A. Galochkin (@pentalux) and D.A. Golomako (@Lokgout) for the 2026 NASA International Space Apps Challenge.*
Team "The Great Duo of Pentalux and Lokgout"

<img width="500" height="500" alt="5463380335786664176-removebg-preview" src="https://github.com/user-attachments/assets/32a98bd1-9286-4175-81b7-2d7d5844ba16" />


