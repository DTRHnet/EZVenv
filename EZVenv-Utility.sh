#!/usr/bin/env bash
#     ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::       .<- 100    +   120 ->
#     ::                                                                                  ::       .
#     ::      _____     ______   ______     __  __     __   __     ______     ______      ::       .
#     ::     /\  __-.  /\__  _\ /\  == \   /\ \_\ \   /\ "-.\ \   /\  ___\   /\__  _\     ::       .
#     ::     \ \ \/\ \ \/_/\ \/ \ \  __<   \ \  __ \  \ \ \-.  \  \ \  __\   \/_/\ \/     ::       .
#     ::      \ \____-    \ \_\  \ \_\ \_\  \ \_\ \_\  \ \_\\"\_\  \ \_____\    \ \_\     ::       .
#     ::       \/____/     \/_/   \/_/ /_/   \/_/\/_/   \/_/ \/_/   \/_____/     \/_/     ::       .
#     ::                                                                                  ::       .
#     :::::::::::::::::::::::::::::::: [ HTTPS://DTRH.NET ] ::::::::::::::::::::::::::::::::       .
#                                                                                                  .
#          :: PROJECT: . . . . . . . . . . . . . . . . . . . . . . . . . . EZVenv                  .
#          :: VERSION: . . . . . . . . . . . . . . . . . . . . . . . . . . 0.6.0                   .
#          :: AUTHOR:  . . . . . . . . . . . . . . . . . . . . . . . . . . KBS                     .
#          :: CREATED: . . . . . . . . . . . . . . . . . . . . . . . . . . 2025-03-03              .
#          :: LAST MODIFIED: . . . . . . . . . . . . . . . . . . . . . . . 2025-03-03              .
#                                                                                                  .
# :: FILE: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  EZVenv-Utility.sh        .
#                                                                                                  .
# :: DESCRIPTION: Utility script for EZVenv project.                                               .
#              :: This script provides archiving and reloading functionalities for EZVenv.         .
#              :: OS & Shell Support: Linux, macOS, Android; sh, bash, zsh (with placeholders      .
#              :: for future specific adaptations).                                                .
#                                                                                                  .
# :: USAGE:                                                                                        .
# ::          -h, --help       Display help message.                                               .
# ::          -r, --reload     Reload the EZVenv environment (functionality not yet implemented).  .
# ::          -a, --archive    Archive the EZVenv project.                                         .
# ::          -v, --verbose    Enable verbose output.                                              .
# ::          -V, --version    Display script version.                                             .
#                                                                                                  .
# :: OPTIONS:                                                                                      .
#           :: MANDATORY:                                                                          .
#                       :: -r || --reload                                                          .
#                       :: -a || --archive                                                         .
#                                                                                                  .
# ::              ** SEE EZVenv/DOCS/EZVenv-Utility.md FOR FULL MORE INFORMATION **                .
#                                                                                                  .
#!/usr/bin/env bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 1.0 - SHELL ENV DIRECTIVES
# :: This section sets the shell directives and ensures the script exits on any command error.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set -e  # Exit immediately if any command exits with a non-zero status.

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 2.0 - GLOBAL VARIABLE DECLARATIONS AND INITIALIZATION
# :: The following variables are used throughout the script for configuration, logging, and state.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

VERBOSE=0                     # VERBOSE flag: if set to 1, enables detailed verbose output.
SCRIPT_VERSION="0.1.0"        # SCRIPT_VERSION holds the version number of this utility script.
PROJECT_VERSION=""            # PROJECT_VERSION represents the current project version (read from VERSION file).
OS_TYPE=""                    # OS_TYPE will store the detected operating system (e.g., Linux, macOS, Android).
SHELL_TYPE=""                 # SHELL_TYPE will store the current shell type (e.g., bash, zsh, sh, unknown).
LOG_FILE=""                   # LOG_FILE holds the log file path if logging is enabled (set via -l/--log-file option).

ARCHIVE_FLAG=0                # ARCHIVE_FLAG: set to 1 if archiving is requested.
RELOAD_FLAG=0                 # RELOAD_FLAG: set to 1 if reload is requested.
CHECK_FLAG=0                  # CHECK_FLAG: set to 1 if check is requested.
CHECK_DIR=""                  # CHECK_DIR holds the directory to check; defaults to current directory.

# Define color codes for output: green for YES, red for NO, and NC to reset color.
GREEN="\033[0;32m"            # Green color code.
RED="\033[0;31m"              # Red color code.
NC="\033[0m"                  # No Color, resets to default.

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 3.0 - LOGGER MODULE
# :: This module provides basic logging functionality.
# :: It ensures that log files are appended to and stored in a designated folder.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# [ 3.1 ]--------------------------------------------------------------------------------------------------------
# Function: logger_init
# Purpose : Initialize the logger by setting the default log file if none is specified and ensuring the
#           directory for the log file exists.
logger_init() {
  if [ -z "$LOG_FILE" ]; then
      LOG_FILE="log/EZVenv.log"   # Set default log file if none provided.
  fi
  local log_dir
  log_dir=$(dirname "$LOG_FILE")  # Extract directory part of the log file.
  if [ ! -d "$log_dir" ]; then
      mkdir -p "$log_dir"         # Create the log directory if it doesn't exist.
  fi
  [ "$VERBOSE" -eq 1 ] && echo "Logger initialized. Log file: ${LOG_FILE}"
}

# [ 3.2 ]--------------------------------------------------------------------------------------------------------

# Function: logger_log
# Purpose : Append a message to the log file with a timestamp.
# Input   : A string message passed as the first argument.
logger_log() {
  local message="$1"                      # Message to be logged.
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")  # Generate a timestamp in YYYY-MM-DD HH:MM:SS format.
  echo "${timestamp} ${message}" >> "$LOG_FILE"  # Append timestamped message to the log file.
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 4.0 - BANNER AND ENVIRONMENT CHECK FUNCTIONS
# :: These functions display the script banner and perform OS and shell detection.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# [ 4.1 ]--------------------------------------------------------------------------------------------------------
# Function: banner
# Purpose : Display a banner at the beginning of script execution.
banner() {
  echo "================================================================================"
  echo "                                EZVenv Utility Script                           "
  echo "                                   Version ${SCRIPT_VERSION}                        "
  echo "================================================================================"
}

# [ 4.2 ]--------------------------------------------------------------------------------------------------------
# Function: check_os
# Purpose : Detect the operating system (Linux, macOS, Android, etc.) and assign it to OS_TYPE.
check_os() {
  local unameOut
  unameOut=$(uname -s)  # Retrieve the OS name.
  case "${unameOut}" in
      Linux*)   OS_TYPE="Linux" ;;    # Set OS_TYPE to Linux if detected.
      Darwin*)  OS_TYPE="macOS" ;;    # Set OS_TYPE to macOS if detected.
      Android*) OS_TYPE="Android" ;;  # Set OS_TYPE to Android if detected.
      *)        OS_TYPE="UNKNOWN" ;;  # Otherwise, mark as UNKNOWN.
  esac
  [ "$VERBOSE" -eq 1 ] && echo "Operating System detected: ${OS_TYPE}"
}

# [ 4.3 ]--------------------------------------------------------------------------------------------------------
# Function: check_shell
# Purpose : Detect the current shell (bash, zsh, sh, etc.) and assign it to SHELL_TYPE.
check_shell() {
  local shell_name
  shell_name=$(basename "$SHELL")   # Extract shell name from $SHELL environment variable.
  case "${shell_name}" in
      bash) SHELL_TYPE="bash" ;;    # Set SHELL_TYPE to bash.
      zsh)  SHELL_TYPE="zsh" ;;     # Set SHELL_TYPE to zsh.
      sh)   SHELL_TYPE="sh" ;;      # Set SHELL_TYPE to sh.
      *)    SHELL_TYPE="unknown" ;; # Otherwise, mark as unknown.
  esac
  [ "$VERBOSE" -eq 1 ] && echo "Shell detected: ${SHELL_TYPE}"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 5.0 - HELP AND VERSION DISPLAY FUNCTIONS
# :: These functions display the script usage information and version details.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# [ 5.1 ]--------------------------------------------------------------------------------------------------------
# Function: display_help
# Purpose : Print the usage help message for the script.
display_help() {
  cat << EOF
Usage: $0 [options]

Options:
  -h, --help             Display this help message.
  -r, --reload           Reload the EZVenv environment.
  -a, --archive          Archive the EZVenv project.
  -c, --check [dir]      Check the EZVenv initialization status in [dir]. If not provided, uses current directory.
  -v, --verbose          Enable verbose output.
  -V, --version          Display the script version.
  -l, --log-file [file]  Log script actions to [file]. If [file] is omitted, defaults to "log/EZVenv.log".

Note: At least one of --reload, --archive, or --check options must be specified.
EOF
}

# [ 5.2 ]--------------------------------------------------------------------------------------------------------
# Function: display_version
# Purpose : Print the current version of the utility script.
display_version() {
  echo "${SCRIPT_VERSION}"
}


# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 6.0 - PROJECT ROOT VERIFICATION FUNCTION
# :: Ensure the script is run from the root project directory by checking for the existence of the VERSION file
# :: and the EZVenv/ folder. If both exist, set PRJ_ROOT to the full path of the current directory,
# :: define APP_ROOT as "EZVenv", and specify directories to ignore while archiving.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

check_project_root() {
    # Verify that the VERSION file exists.
    if [ ! -f "VERSION" ]; then
        echo "❌ VERSION file not found. Please run this script from the project root directory."
        exit 1
    fi

    # Verify that the EZVenv/ folder exists.
    if [ ! -d "EZVenv" ]; then
        echo "❌ EZVenv/ folder not found. Please run this script from the project root directory."
        exit 1
    fi

    # Set PRJ_ROOT as the full path of the current directory.
    PRJ_ROOT="$(pwd)"

    # Define APP_ROOT as "EZVenv".
    APP_ROOT="EZVenv"

    # Define an array of directories (full paths) to ignore during archiving.
    IGNORE_DIRS=(
        "Archives/"
        "test/"
        "EZVenv/build/"
        "EZVenv/EZVenv-egg.info/"
    )

    # If verbose output is enabled, display the verified project root.
    [ "$VERBOSE" -eq 1 ] && echo "Project root verified: ${PRJ_ROOT}"
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 7.0 - CORE FUNCTIONALITY: ARCHIVING, RELOADING, AND CHECKING
# :: These functions implement archiving the project, reloading the environment, and checking environment status.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 7.1 - Function: do_archive
# :: This function will create the zip archive by including only the files not ignored by .gitignore and specific exclusions.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

do_archive() {
  [ "$VERBOSE" -eq 1 ] && echo "Starting archiving process..."
  [ -n "$LOG_FILE" ] && logger_log "Starting archiving process..."

  # Ensure the script is being run from the project root.
  check_project_root

  # Read the project version from the VERSION file.
  PROJECT_VERSION=$(head -n 1 VERSION | tr -d '[:space:]')
  if [ -z "$PROJECT_VERSION" ]; then
      echo "❌ Project version not found in VERSION file. Aborting."
      [ -n "$LOG_FILE" ] && logger_log "Project version missing in VERSION file. Aborting."
      exit 1
  fi

  # Define the archive directory and file name.
  local archive_dir="Archives"
  local base_archive_name="EZVenv-${PROJECT_VERSION}.zip"
  local archive_path="${archive_dir}/${base_archive_name}"

  # Create the archive directory if it does not exist.
  if [ ! -d "$archive_dir" ]; then
      mkdir -p "$archive_dir"
      [ "$VERBOSE" -eq 1 ] && echo "Created archive directory: ${archive_dir}"
      [ -n "$LOG_FILE" ] && logger_log "Created archive directory: ${archive_dir}"
  fi

  # If an archive already exists, append a numeric suffix to avoid overwriting.
  if [ -f "$archive_path" ]; then
      local counter=2
      while [ -f "${archive_dir}/EZVenv-${PROJECT_VERSION}-${counter}.zip" ]; do
          counter=$((counter + 1))  # Increment counter until a unique name is found.
      done
      archive_path="${archive_dir}/EZVenv-${PROJECT_VERSION}-${counter}.zip"
  fi

  # Get the current directory path.
  dir_path="$(pwd)"

  # Create the zip archive while excluding specific directories.
  [ "$VERBOSE" -eq 1 ] && echo "Creating archive: ${archive_path}"
  [ -n "$LOG_FILE" ] && logger_log "Creating archive: ${archive_path}"

  # Archive the project while excluding the specified directories.
  zip -r "$archive_path" "$dir_path" -x "$dir_path/Archives/*" -x "$dir_path/test/*" -x "$dir_path/EZVenv/build/*" -x "$dir_path/EZVenv/EZVenv.egg-info/*" -x "$dir_path/.git/*"

  echo "✅ Archive created successfully: ${archive_path}"
  [ "$VERBOSE" -eq 1 ] && echo "Archive process completed successfully."
  [ -n "$LOG_FILE" ] && logger_log "Archive created successfully: ${archive_path}"
}

# [ 7.2 ]--------------------------------------------------------------------------------------------------------
# Function: do_reload
# Purpose : Reload the EZVenv environment by clearing caches, activating the master environment,
#           reinstalling the EZVenv package from the local repository, and verifying the installation.
do_reload() {
  [ "$VERBOSE" -eq 1 ] && echo "🔄 Reloading EZVenv with latest changes..."
  [ -n "$LOG_FILE" ] && logger_log "Reloading EZVenv with latest changes..."

  # Remove cached build directories and egg-info to ensure fresh installation.
  #
  rm -rf EZVenv/EZVenv.egg-info EZVenv/build
  [ "$VERBOSE" -eq 1 ] && echo "Removed cache directories: EZVenv/EZVenv.egg-info, EZVenv/build"
  [ -n "$LOG_FILE" ] && logger_log "Removed cache directories: EZVenv/EZVenv.egg-info, EZVenv/build"

  # Activate the master environment.
  #
  source ~/.EZVenv/EZVenv-Master/bin/activate
  [ "$VERBOSE" -eq 1 ] && echo "Activated master environment at ~/.EZVenv/EZVenv-Master/bin/activate"
  [ -n "$LOG_FILE" ] && logger_log "Activated master environment."

  # Force reinstall EZVenv from the local repository.
  # --upgrade: Upgrade if necessary.
  # --force-reinstall: Reinstall even if the package is already installed.
  # --no-cache-dir: Avoid cache to pick up new changes.
  #
  pip install --upgrade --force-reinstall --no-cache-dir /home/dtrh/Documents/github/EZVenv/EZVenv/
  [ "$VERBOSE" -eq 1 ] && echo "Executed pip install with upgrade, force-reinstall and no-cache-dir options."
  [ -n "$LOG_FILE" ] && logger_log "Executed pip install for EZVenv reinstallation."

  # Deactivate the master environment after installation.
  #
  deactivate
  [ "$VERBOSE" -eq 1 ] && echo "Deactivated master environment after installation."
  [ -n "$LOG_FILE" ] && logger_log "Deactivated master environment."

  # Verify the installation by checking the EZVenv version.
  #
  echo "🔍 Verifying EZVenv version..."
  [ -n "$LOG_FILE" ] && logger_log "Verifying EZVenv version..."
  source ~/.EZVenv/EZVenv-Master/bin/activate
  if command -v ezvenv >/dev/null 2>&1; then
      ezvenv --version || python -c "import ezvenv; print('EZVenv version:', getattr(ezvenv, '__version__', 'unknown'))"
      [ "$VERBOSE" -eq 1 ] && echo "EZVenv version verified via ezvenv --version."
      [ -n "$LOG_FILE" ] && logger_log "EZVenv version verified via ezvenv --version."
  else
      echo "⚠️  'ezvenv' command not found. Ensure the package was installed correctly."
      [ -n "$LOG_FILE" ] && logger_log "'ezvenv' command not found. Package installation may have failed."
  fi
  deactivate
  [ "$VERBOSE" -eq 1 ] && echo "Deactivated master environment after verification."
  [ -n "$LOG_FILE" ] && logger_log "Deactivated master environment after verification."

  echo "✅ EZVenv reloaded successfully!"
  [ "$VERBOSE" -eq 1 ] && echo "Reload process completed successfully."
  [ -n "$LOG_FILE" ] && logger_log "EZVenv reloaded successfully."
}

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 7.3 - Function: do_check
# :: Purpose : Check the project environment.
# ::   1. Validate the provided directory parameter (-c /path/to/dir); if not given, use the current directory.
# ::   2. Verify if the Master environment exists at $HOME/.EZVenv/EZVenv-Master.
# ::   3. Check if the directory is initialized (i.e., contains ezvenv.conf).
# ::   4. Report the active virtual environment (if any).
# ::   5. Determine the Python version via "python -V".
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

do_check() {
    # Determine the directory to check. If a parameter is given, validate it.
    local check_dir
    if [ -z "$1" ]; then
        check_dir="$(pwd)"
    else
        check_dir="$1"
    fi

    # Error check: Ensure the provided directory exists and is a directory.
    if [ ! -d "$check_dir" ]; then
        echo "❌ The provided directory ($check_dir) does not exist or is not a directory. Aborting."
        exit 1
    fi

    # Check if the Master environment exists at $HOME/.EZVenv/EZVenv-Master.
    if [ -d "$HOME/.EZVenv/EZVenv-Master" ]; then
        master_status="${GREEN}YES${NC}"
    else
        master_status="${RED}NO${NC}"
    fi

    # Check if the directory is initialized by looking for the ezvenv.conf file.
    if [ -f "$check_dir/ezvenv.conf" ]; then
        init_status="${GREEN}YES${NC}"
    else
        init_status="${RED}NO${NC}"
    fi

    # Check if a virtual environment is currently activated.
    if [ -n "$VIRTUAL_ENV" ]; then
        activated_status="${GREEN}YES${NC}"
        venv_name=$(basename "$VIRTUAL_ENV")
    else
        activated_status="${RED}NO${NC}"
        venv_name="None"
    fi

    # Determine the Python version using "python -V".
    # Redirect stderr to stdout since "python -V" writes to stderr.
    python_version=$(python -V 2>&1 | awk '{print $2}')

    # Check for the presence of a requirements file.
    if [ -f "$check_dir/requirements.txt" ]; then
        project_reqs="requirements.txt"
    else
        project_reqs="${RED}Not Found${NC}"
    fi

    # Output a summary table using colors and tab-spaced formatting.
    echo -e "\nChecking EZVenv at ${check_dir}:\n"
    printf "%-25s [ %s ]\n" "Master Environment" "${master_status}"
    printf "%-25s [ %s ]\n" "Initialized" "${init_status}"
    printf "%-25s [ %s ]\n" "Virtualenv Enabled" "${activated_status}"
    printf "%-25s [ %s ]\n" "Virtualenv Name" "${venv_name}"
    printf "%-25s [ %s ]\n" "Python Version" "${python_version}"
    printf "%-25s [ %s ]\n" "Project Requirements" "${project_reqs}"
}



# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# :: 8.0 - MAIN SCRIPT EXECUTION: ARGUMENT PARSING AND FUNCTION DISPATCH
# :: This section processes command-line arguments, initializes modules, and calls appropriate functions.
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# If no arguments are provided, display the help message and exit.
#
if [ "$#" -eq 0 ]; then
  display_help
  exit 1
fi

# Parse command-line arguments using getopt.
# Options: h (help), r (reload), a (archive), c (check, with an optional [dir]), v (verbose),
#          V (version), l (log-file, with an optional file argument).
#
TEMP=$(getopt -o hravVl::c::V -l help,reload,archive,verbose,log-file::,check::,version -- "$@")
if [ $? != 0 ]; then
    echo "Error parsing options." >&2
    exit 1
fi
eval set -- "$TEMP"

# Process each parsed option.
#
while true; do
  case "$1" in
    -h|--help)
      display_help         # Display help message.
      exit 0
      ;;
    -r|--reload)
      RELOAD_FLAG=1        # Set flag to execute reload functionality.
      shift
      ;;
    -a|--archive)
      ARCHIVE_FLAG=1       # Set flag to execute archive functionality.
      shift
      ;;
    -v|--verbose)
      VERBOSE=1            # Enable verbose output.
      shift
      ;;
    -V|--version)
      display_version      # Display the script version.
      exit 0
      ;;
    -l|--log-file)
      # If an argument is provided and doesn't start with '-', use it; otherwise, default.
      if [ -n "$2" ] && [[ "$2" != -* ]]; then
          LOG_FILE="$2"
          shift
      else
          LOG_FILE="log/EZVenv.log"
      fi
      shift
      ;;
    -c|--check)
      # If an argument is provided and doesn't start with '-', use it; otherwise default to current directory.
      if [ -n "$2" ] && [[ "$2" != -* ]]; then
          CHECK_DIR="$2"
          shift
      else
          CHECK_DIR="$(pwd)"
      fi
      CHECK_FLAG=1         # Set flag to execute check functionality.
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1"
      exit 1
      ;;
  esac
done

# Ensure that at least one functionality option is specified.
#
if [ "$ARCHIVE_FLAG" -eq 0 ] && [ "$RELOAD_FLAG" -eq 0 ] && [ "$CHECK_FLAG" -eq 0 ]; then
  echo "❌ Error: At least one of --reload, --archive, or --check options must be specified."
  display_help
  exit 1
fi

# Initialize logger if logging is enabled.
#
if [ -n "$LOG_FILE" ]; then
  logger_init
fi

# Display the script banner.
#
banner

# Perform OS and shell detection.
#
check_os
check_shell

# Execute functionalities based on specified flags.
#
if [ "$CHECK_FLAG" -eq 1 ]; then
  do_check
fi

if [ "$ARCHIVE_FLAG" -eq 1 ]; then
  do_archive
fi

if [ "$RELOAD_FLAG" -eq 1 ]; then
  do_reload
fi
