# EZVenv

**Version: 0.5.0**

EZVenv is a system-wide Python virtual environment manager designed to simplify virtual environment creation and dependency management. It automates most tasks—allowing you to initialize, install, update, and even programmatically activate environments without needing to manage them manually.

## 🚀 Features

- **Master Virtual Environment:**  
  A master environment (stored in ```$HOME/.EZVenv/EZVenv-Master```) is used to manage installations and package dependencies.

- **Multi-Platform Support:**  
  Works on Linux, macOS, and Windows (with separate installers).

- **Easy Initialization:**  
  Use ```ezvenv init [dir]``` to initialize a virtual environment:
  - **Optional Target Directory:**  
    If a directory is specified and does not exist, it will be created automatically.  
    If it exists and is non‑empty, you’ll be prompted to confirm before continuing.
  - **Configuration File:**  
    A configuration file (```ezvenv.yaml```) is generated in the target directory. If a configuration file already exists, you’ll be asked if you want to overwrite it.

- **Enhanced Auto‑Activation:**  
  When a new environment is created:
  - It deactivates the master environment (if desired) and activates the new one.
  - If the new environment is activated on top of the master, you are informed and given choices:
    1. Deactivate the master environment and then activate the new environment.
    2. Activate the new environment over the master environment.
    3. Abort activation.
  - This interactive choice prevents false positives and ensures clarity when switching environments.

- **Dependency Management:**  
  Automatically updates core components (pip, setuptools, pyyaml) and installs or updates project dependencies from a ```requirements.txt``` file if present.

- **Programmatic Control:**  
  EZVenv can be imported as a module in Python scripts, letting you programmatically set parameters (Python version, virtual environment name, directory, etc.) and auto‑activate the environment for seamless execution.

## 📦 Installation

For Linux/macOS:
```bash
bash install.sh
```

For Windows, run the provided ```install.bat``` script.

> **Note:** EZVenv installs a master environment in your home directory at ```$HOME/.EZVenv/EZVenv-Master```.

## ⚙️ Usage

### CLI
- **Initialize an Environment:**
  ```bash
  ezvenv init           # Initializes the current directory
  ezvenv init [dir]      # Initializes the specified directory
  ```
  If the target directory is non‑empty, you will be prompted to confirm the initialization.
  
- **Install Dependencies:**
  ```bash
  ezvenv install
  ```

- **Update Dependencies:**
  ```bash
  ezvenv update
  ```

### Programmatic Use
```python
from ezvenv import init_env

env_path = init_env(
    env_name="myEnv",
    env_dir="/path/to/project",
    python_ver="python3.9",
    save_defaults=True
)
print(f"Virtual environment set up at: {env_path}")
```

## 🔄 Reloading EZVenv
To reload EZVenv with the latest changes, use:
```bash
./reload.sh
```

## 🔧 Development
EZVenv is built using Python and leverages virtual environments to isolate dependencies. Contributions are welcome!

## 📜 License
This project is licensed under the MIT License. See ```LICENSE.md``` for details.
