# Version 0.10 Windows release verification — 2026-11-15

The stable 0.10 overview/local-terrain renderer was rebuilt from a fresh CMake Release directory using Qt 6.12.0 / MinGW 13.1. The experimental quadtree and fine regional DEM data are not included. No scene or camera behavior was changed for packaging.

18 Node scientific/geometry checks passed. A separate configure from the repository copy passed without local Python libraries or download caches. Preparation tools passed Python/Node syntax checks and use paths relative to their own project location.

The portable payload was deployed using the matching windeployqt, including compiler runtime DLLs and QML plugins, with a relative qt.conf. Native --smoke-test passed with exit code 0 from a separate working directory after removing Qt/MinGW from PATH and clearing Qt/QML plugin import environment variables. This checks executable startup and loading of the lander, lunar globe and embedded scientific assets without an installed SDK.

Every ZIP entry passed CRC verification. The executable streamed from the installer matches the SHA-256 of the verified portable executable. The installer was compiled without warnings. It installs per user and its uninstaller removes only files shipped in the payload; unrelated files are preserved. No installer was executed to modify the user's system during validation.

GitHub source assets use Git LFS. Build folders, Python environments, raw download caches, diagnostic screenshots and the cancelled 0.11 experiment are excluded. Windows artifacts and SHA256SUMS.txt are distributed separately in the GitHub release.
