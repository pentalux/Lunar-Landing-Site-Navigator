# Scientific data — restored 0.10

Active height sources: NASA SVS [Moon Kit](https://svs.gsfc.nasa.gov/4720/) LOLA LDEM 64 ppd, approximately 474 m spacing at the equator, and NASA Goddard [south-polar LOLA](https://pgda.gsfc.nasa.gov/products/90) 80 m adjusted data. Binary tiles store half-metre uint16 heights, with at most 96 cached tiles. Preset elevations and skyline masks have been restored to these sources.

Appearance uses the NASA LROC Moon Kit albedo. The overview globe and regional terrain retain stereographic polar textures. The local mesh has 75 m cells near the lander; tessellation does not add measured detail beyond the DEM. This version uses the previous overview/detail transition, not an adaptive planetary quadtree.

JPL NAIF SPICE DE421 vectors and lunar orientation cover 2026–2027, in MOON_ME with east-positive longitude. Viewer axes remain fixed while the lunar body rotates. Earth/Sun display distances are compressed. Fill lighting and decorative regolith grain do not affect analytical visibility.

Visibility compares body-center elevation against the sampled terrain horizon. Favorable Window intersects sunlight and Earth visibility. Horizontal-panel power omits batteries and losses. Footpad support uses the rendered triangles; rigid unrigged feet may retain small gaps. Descent is a simplified vertical controller. Data does not certify landing safety.

The experimental regional data is archived outside the active project and is not loaded or packaged.
