#!/bin/bash
# reload.sh - Reload EZVenv with the latest changes (v0.5.0)
#
# NOTE : This belongs in project root
#        It is found in 'scripts/' for repo archiving simplicity
#
# This script performs the following steps:
#   1. Activates the master environment.
#   2. Force reinstalls EZVenv from the local repository.
#   3. Deactivates the master environment.
#   4. Re-activates the environment briefly to verify that the new version is loaded.
#
# Usage:
#   ./reload.sh

echo "🔄 Reloading EZVenv with latest changes..."

# Remove cache
rm -rf EZVenv/EZVenv.egg-info EZVenv/build
# Activate the master environment.
source ~/.EZVenv/EZVenv-Master/bin/activate

# Force reinstall EZVenv from the local repository.
# --upgrade: upgrades if necessary.
# --force-reinstall: reinstalls even if the package is already installed.
# --no-cache-dir: avoids using the cache to ensure the new changes are picked up.
pip install --upgrade --force-reinstall --no-cache-dir /home/dtrh/Documents/github/EZVenv/EZVenv/

# Deactivate the master environment.
deactivate

# Optionally verify that the new version is installed.
# This assumes that EZVenv exposes a version flag (e.g., 'ezvenv --version').
# If not available, you can alternatively run a Python snippet to print the version.
echo "🔍 Verifying EZVenv version..."
source ~/.EZVenv/EZVenv-Master/bin/activate
if command -v ezvenv >/dev/null 2>&1; then
    ezvenv --version || python -c "import ezvenv; print('EZVenv version:', getattr(ezvenv, '__version__', 'unknown'))"
else
    echo "⚠️  'ezvenv' command not found. Ensure the package was installed correctly."
fi
deactivate

echo "✅ EZVenv reloaded successfully!"
