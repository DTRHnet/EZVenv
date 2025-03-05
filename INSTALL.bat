@echo off
:: --------------------[ Constants ]--------------------
set SCRIPT_NAME=install.bat
set VERSION=0.3.0
set INSTALL_DIR=%USERPROFILE%\.EZVenv
set MASTER_ENV=%INSTALL_DIR%\EZVenv-Master
set LOG_FILE=%INSTALL_DIR%\ezvenv-install.log
set PATH_UPDATE_CMD=setx PATH "%INSTALL_DIR%\bin;%PATH%"

echo [INFO] Detecting system information...

:: --------------------[ OS Detection ]--------------------
:: Windows-specific check
ver | findstr /i "Windows" > nul
if %errorlevel% neq 0 (
    echo [ERROR] Unsupported OS detected. This script is for Windows only.
    exit /b 1
)

echo [OK] OS detected: Windows

:: --------------------[ Python Check ]--------------------
where python > nul 2> nul
if %errorlevel% neq 0 (
    echo [ERROR] Python 3 is required but not found. Install Python and try again.
    exit /b 1
)

:: --------------------[ Install EZVenv ]--------------------
echo [INFO] Installing EZVenv...

:: Create the installation directory if it doesn't exist
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Check if the master virtual environment exists
if exist "%MASTER_ENV%" (
    echo [WARNING] Existing EZVenv-Master detected. Reinstalling...
    rmdir /s /q "%MASTER_ENV%"
)

:: Create a new virtual environment
python -m venv "%MASTER_ENV%"

:: Activate the master virtual environment and install EZVenv
call "%MASTER_ENV%\Scripts\activate.bat"
"%MASTER_ENV%\Scripts\pip" install --upgrade pip
"%MASTER_ENV%\Scripts\pip" install ezvenv

:: --------------------[ PATH Configuration ]--------------------
echo [INFO] Adding EZVenv to the system PATH...

:: Add EZVenv bin directory to the system PATH
%PATH_UPDATE_CMD%

:: --------------------[ Final Message ]--------------------
echo [SUCCESS] EZVenv installed successfully!
echo [ACTION] Restart your terminal or open a new Command Prompt to start using EZVenv.
echo [ACTION] To initialize a virtual environment, run: ezvenv init
