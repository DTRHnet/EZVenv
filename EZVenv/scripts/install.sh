#!/bin/bash

# --------------------[ Colors & Constants ]--------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

SCRIPT_NAME="install.sh"
VERSION="0.3.0"
INSTALL_DIR="$HOME/.EZVenv"
MASTER_ENV="$INSTALL_DIR/EZVenv-Master"
BIN_PATH="$MASTER_ENV/bin"
ACTIVATE_SCRIPT="$BIN_PATH/activate"
LOG_FILE="/var/log/ezvenv-install.log"

echo -e "${CYAN}[INFO]${RESET} Detecting system information..."

# --------------------[ OS & Shell Detection ]--------------------
OS_TYPE="$(uname -s 2>/dev/null || true)"
case "$OS_TYPE" in
    Linux*) OS="Linux" ;;
    Darwin*) OS="macOS" ;;
    *) OS="Unknown"; echo -e "${RED}[ERROR]${RESET} Unsupported OS detected. Exiting."; exit 1 ;;
esac
echo -e "${GREEN}[OK]${RESET} OS detected: ${OS}"

CURRENT_SHELL="$(basename "$SHELL" 2>/dev/null || echo "bash")"
echo -e "${GREEN}[OK]${RESET} Detected shell: ${CURRENT_SHELL}"

# --------------------[ Preliminary Checks ]--------------------
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}[ERROR]${RESET} Python 3 is required but not found. Install Python and try again."
    exit 1
fi

# Check if Python has venv installed
if ! python3 -c "import venv" 2>/dev/null; then
    echo -e "${RED}[ERROR]${RESET} Python 'venv' module is missing. Install it using your system's package manager."
    echo -e "${YELLOW}[ACTION]${RESET} Try running: ${CYAN}sudo apt install python3-venv${RESET} (Debian/Ubuntu)"
    echo -e "${YELLOW}[ACTION]${RESET} Try running: ${CYAN}brew install python${RESET} (macOS)"
    exit 1
fi

# --------------------[ Install EZVenv ]--------------------
echo -e "${CYAN}[INFO]${RESET} Installing EZVenv..."

mkdir -p "$INSTALL_DIR"

# Check if the master virtual environment exists
if [[ -d "$MASTER_ENV" ]]; then
    echo -e "${YELLOW}[WARNING]${RESET} EZVenv-Master already exists. Skipping recreation."
else
    echo -e "${CYAN}[INFO]${RESET} Creating EZVenv-Master..."
    python3 -m venv "$MASTER_ENV"
fi

# Ensure correct permissions for activation script
chmod +x "$ACTIVATE_SCRIPT" 2>/dev/null || true

# Upgrade essential tools in the environment
echo -e "${CYAN}[INFO]${RESET} Upgrading pip, setuptools, disttools, pyyaml, wheel..."
"$BIN_PATH/pip" install --upgrade pip setuptools disttools pyyaml wheel || {
    echo -e "${RED}[ERROR]${RESET} Failed to upgrade pip, setuptools, and wheel."
    exit 1
}

# --------------------[ Activate & Install EZVenv ]--------------------
echo -e "${CYAN}[INFO]${RESET} Activating EZVenv-Master..."
source "$ACTIVATE_SCRIPT" || {
    echo -e "${RED}[ERROR]${RESET} Failed to activate EZVenv-Master. Ensure correct permissions with:"
    echo -e "${YELLOW}[ACTION]${RESET} chmod +x $ACTIVATE_SCRIPT"
    exit 1
}

echo -e "${CYAN}[INFO]${RESET} Installing EZVenv in Master Environment..."
"$BIN_PATH/pip" install --upgrade . || {
    echo -e "${RED}[ERROR]${RESET} Failed to install EZVenv. Retrying with direct package reference..."
    # TODO "$BIN_PATH/pip" install --no-cache-dir --upgrade git+https://github.com/DTRHnet/EZVenv.git
    echo -e "${RED}[ERROR]${RESET} EZVenv installation failed. Repository install is not implemented yet.."
    exit 1
}


# --------------------[ PATH Configuration ]--------------------
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    PROFILE_FILE="$HOME/.bashrc"
else
    PROFILE_FILE="$HOME/.profile"
fi

# Check if PATH is already set in rc file
if grep -q "$BIN_PATH" "$PROFILE_FILE"; then
    echo -e "${YELLOW}[WARNING]${RESET} EZVenv is already in your PATH. Skipping modification."
else
    echo "export PATH=\"$BIN_PATH:\$PATH\"" >> "$PROFILE_FILE"
    echo -e "${GREEN}[OK]${RESET} EZVenv has been added to your system PATH in ${PROFILE_FILE}."
fi

# --------------------[ Final Message ]--------------------
echo -e "${GREEN}[SUCCESS]${RESET} EZVenv installed successfully!"
# echo -e "${YELLOW}[ACTION]${RESET} Restart your terminal or run 'source $PROFILE_FILE' to start using EZVenv."
# echo -e "${YELLOW}[ACTION]${RESET} To initialize a virtual environment, run: ${CYAN}ezvenv init${RESET}"

# --------------[ Remain in environment ]--------------
# If we did environment steps or the user was already in environment,
# we keep them in a new shell
# (except if user was only archiving or only help? The user might want to remain anyway).
# We'll keep the new shell logic unconditionally, so user can remain in env if they're in it.

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
  echo -e "${GREEN}[OK]${RESET} Launching zsh so user remains in env..."
  exec zsh
else
  echo -e "${GREEN}[OK]${RESET} Launching bash so user remains in env..."
  exec bash
fi
