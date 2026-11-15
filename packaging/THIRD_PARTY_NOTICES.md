# Third-party components and data

The Windows package includes Qt 6.12 shared libraries, Qt QML plugins, and the
MinGW compiler runtime deployed by the matching Qt `windeployqt` utility.
Qt source and licensing information: https://www.qt.io/licensing/ and
https://code.qt.io/cgit/qt/ . Upstream license texts are included in `licenses`.

Lunar height and appearance data: NASA LOLA and LROC, distributed by NASA SVS
(https://svs.gsfc.nasa.gov/4720/) and NASA Goddard PGDA
(https://pgda.gsfc.nasa.gov/products/90). NASA endorsement is not implied.
Earth imagery: NASA Earth Observatory Blue Marble Next Generation.
Ephemerides and lunar reference frames: JPL NAIF SPICE DE421 kernels.

Lander and selection-pin models were supplied by the project author.
The source repository includes application code and the runtime scientific
assets. See `docs/DATA_SOURCES.md` there for scientific limitations and sources.
