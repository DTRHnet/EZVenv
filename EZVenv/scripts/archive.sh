#!/bin/bash
# archive.sh - Archive EZVenv Project for EZVenv-v0.4.0
#
# NOTE : BELONGS IN PROJECT ROOT
#        For archiving simplicity of repo, it is found in 'scripts/'
#
# This script is intended to be run from the project root.
# It performs the following steps:
#   1. Reads the version number from the first line of the VERSION file.
#   2. Constructs an archive name in the format EZVenv-{VERSION}.zip.
#   3. Checks the Archives folder to ensure that an archive with the same name doesn't already exist.
#      If it does, appends a numeric suffix to create a unique archive name.
#   4. Creates a zip archive of the project, excluding the Archives folder to avoid recursion.
#
# Usage:
#   ./archive.sh

set -e  # Exit immediately if a command exits with a non-zero status.

# Check for the VERSION file in the current directory.
if [ ! -f "VERSION" ]; then
    echo "❌ VERSION file not found in the current directory. Aborting."
    exit 1
fi

# Read the first line from the VERSION file, stripping any extra whitespace.
version=$(head -n 1 VERSION | tr -d '[:space:]')
if [ -z "$version" ]; then
    echo "❌ Version not found in VERSION file. Aborting."
    exit 1
fi

# Define the target Archives directory and the base archive name.
archive_dir="Archives"
base_archive_name="EZVenv-${version}.zip"
archive_path="${archive_dir}/${base_archive_name}"

# Create the Archives directory if it doesn't exist.
if [ ! -d "$archive_dir" ]; then
    mkdir -p "$archive_dir"
fi

# Check if an archive with the base name already exists.
# If so, append a number (e.g., -2, -3, etc.) until a unique name is found.
if [ -f "$archive_path" ]; then
    counter=2
    while [ -f "${archive_dir}/EZVenv-${version}-${counter}.zip" ]; do
        counter=$((counter + 1))
    done
    archive_path="${archive_dir}/EZVenv-${version}-${counter}.zip"
fi

# Create the zip archive.
# The archive includes all files and directories in the project root, except the Archives directory.
echo "🔧 Creating archive: ${archive_path}"
zip -r "$archive_path" . -x "${archive_dir}/*"

echo "✅ Archive created successfully: ${archive_path}"
