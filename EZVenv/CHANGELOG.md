# Changelog

## **v0.5.0** - Released: 2025-03-03

### 🚀 New Features
- Optional directory initialization: ~~~ezvenv init [dir]~~~ now accepts a target directory.
  - If the directory does not exist, it is automatically created.
  - If the directory exists and is non‑empty, a confirmation prompt is displayed.
- Generation of a configuration file (~~~ezvenv.yaml~~~) in the initialized directory.
  - If the configuration file already exists, the user is prompted before overwriting.
- Enhanced environment activation:
  - When activating a new environment from the master environment (~~~EZVenv-Master~~~), the user is prompted with three options:
    1. Deactivate the master environment and then activate the new one.
    2. Activate the new environment on top of the master environment.
    3. Do nothing (abort activation).
- Robust activation logic to prevent infinite re‑initialization loops and false positives.

### Improvements
- Detailed and verbose output during initialization and environment switching.
- Enhanced flag management to clearly distinguish between the master and project environments.

## **v0.4.0** - Released: 2025-03-02

### 🎉 Features Added
- Auto‑activation improvements:
  - If the new environment lacks the EZVenv module, the master environment’s site‑packages are appended to ~~~PYTHONPATH~~~.
- Updated ~~~reload.sh~~~ to force reload the package with the latest changes.
- Fixes for ModuleNotFoundError when switching from the master to a project environment.
- More thorough checks to avoid re‑initialization when a virtual environment is already active.

## **v0.3.0** - Released: 2025-03-02

### 🎉 Features Added
- Master Virtual Environment (~~~EZVenv-Master~~~) for managing all environments.
- macOS Support – Now works on macOS alongside Linux.
- Uninstall Script – Allows clean removal of EZVenv.
- Improved Logging & Error Handling.

## **v0.2.0**
- System‑wide installation via ~~~.sh~~~ script.
- Debian package support (~~~.deb~~~).
