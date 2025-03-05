import os
import subprocess
import sys
import shutil
import yaml
import json
import logging

# Determine the user's home directory and config directory
HOME_DIR = os.path.expanduser("~")
CONFIG_DIR = os.path.join(HOME_DIR, ".EZVenv")
if not os.path.exists(CONFIG_DIR):
    os.makedirs(CONFIG_DIR, exist_ok=True)

# Set up logging: Log file is placed inside the config directory for persistence.
_LOG_FILE_ = os.path.join(CONFIG_DIR, "ezvenv.log")
logging.basicConfig(
    filename=_LOG_FILE_,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


class EZVenv:
    def __init__(self, config_file=None, env_name=None, env_dir=None, python_ver=None,
                 save_defaults=False, auto_activate=True):
        """
        Initialize the EZVenv instance.

        Parameters:
            config_file (str): Path to the configuration file.
              Defaults to "$HOME/.EZVenv/ezvenv.yaml".
            env_name (str): The name of the virtual environment.
              Defaults to value from config or ".venv".
            env_dir (str): The directory where the virtual environment is located.
              Defaults to current working directory.
            python_ver (str): Python interpreter to use.
              Defaults to value from config or the current interpreter.
            save_defaults (bool): Whether to save provided parameters as defaults.
            auto_activate (bool): If True, the script will automatically re-exec
              itself with the environment's Python interpreter if not already activated.
        """
        # Set default config file path if not provided.
        self.configFile = config_file or os.path.join(CONFIG_DIR, "ezvenv.yaml")
        self.config = self.load_config()

        # Set environment name from provided parameter, config file, or default.
        self.envName = env_name or self.config.get("envName", ".venv")
        # Use the specified directory or default to the current working directory.
        self.envDir = os.path.abspath(env_dir or os.getcwd())
        # Set python version/interpreter: provided parameter, from config, or current.
        self.pythonVer = python_ver or self.config.get("pythonVer", sys.executable)
        # Full path to the virtual environment directory.
        self.envPath = os.path.join(self.envDir, self.envName)

        # Detect package manager from config or by auto-detecting available tools.
        self.pkgManager = self.detect_pkg_manager()
        self.autoInstall = self.config.get("autoInstall", True)
        self.autoUpdate = self.config.get("autoUpdate", True)
        self.autoActivate = auto_activate

        if save_defaults:
            self.save_config()

    def load_config(self):
        """
        Load configuration from the YAML (or JSON) file.

        Returns:
            dict: Configuration settings.
        """
        if os.path.exists(self.configFile):
            try:
                with open(self.configFile, "r") as file:
                    if self.configFile.endswith(".json"):
                        config = json.load(file)
                    elif self.configFile.endswith(".yaml") or self.configFile.endswith(".yml"):
                        config = yaml.safe_load(file)
                    else:
                        config = {}
                    logging.info("Configuration loaded from %s", self.configFile)
                    return config or {}
            except Exception as e:
                logging.error("Error loading config file: %s", str(e))
                print("⚠️ Error reading config file. Using default settings.")
                return {}
        else:
            logging.info("No config file found at %s. Using default settings.", self.configFile)
        return {}

    def save_config(self):
        """
        Save the current configuration to the YAML file.
        """
        config_data = {
            "envName": self.envName,
            "envDir": self.envDir,
            "pythonVer": self.pythonVer,
            "autoInstall": self.autoInstall,
            "autoUpdate": self.autoUpdate,
            "pkgManager": self.pkgManager
        }
        try:
            with open(self.configFile, "w") as file:
                yaml.dump(config_data, file, default_flow_style=False)
            logging.info("Configuration saved to %s", self.configFile)
        except Exception as e:
            logging.error("Failed to save configuration: %s", str(e))
            print("❌ Failed to save configuration.")

    def detect_pkg_manager(self):
        """
        Detect which package manager to use.

        Returns:
            str: Package manager name ("poetry", "pipenv", or "pip").
        """
        manager = self.config.get("pkgManager", "auto")
        if manager != "auto":
            return manager
        # Auto-detect available package managers in order of preference.
        if shutil.which("poetry"):
            return "poetry"
        if shutil.which("pipenv"):
            return "pipenv"
        return "pip"

    def _get_executable_path(self, executable):
        """
        Helper to get the path to an executable inside the virtual environment,
        taking into account differences between Unix and Windows.

        Parameters:
            executable (str): The name of the executable (e.g., "pip", "python").

        Returns:
            str: The full path to the executable within the virtual environment.
        """
        if os.name == "nt":
            # On Windows, executables are located in the Scripts directory.
            return os.path.join(self.envPath, "Scripts", f"{executable}.exe")
        else:
            # On Unix-like systems, executables are located in the bin directory.
            return os.path.join(self.envPath, "bin", executable)

    def create_env(self):
        """
        Create the virtual environment if it does not exist.
        If the environment exists, log the occurrence and proceed gracefully.
        """
        if os.path.exists(self.envPath):
            logging.info("Virtual environment already exists at %s", self.envPath)
            print(f"✅ Virtual environment already exists at {self.envPath}.")
        else:
            try:
                logging.info("Creating virtual environment at %s using Python %s.", self.envPath, self.pythonVer)
                print(f"🔧 Creating virtual environment at {self.envPath} using Python {self.pythonVer}...")
                subprocess.run([self.pythonVer, "-m", "venv", self.envPath], check=True)
            except subprocess.CalledProcessError as e:
                logging.error("Failed to create virtual environment: %s", str(e))
                print("❌ Failed to create virtual environment.")
                sys.exit(1)
        print(f"🟢 Virtual environment is ready: {self.envPath}")
        # After ensuring the environment exists, update core components.
        self.update_core_components()

    def update_core_components(self):
        """
        Update core packages (pip, setuptools, etc.) within the virtual environment.
        This ensures that the environment is up-to-date.
        """
        core_packages = ["pip", "setuptools", "pyyaml"]
        print("🔄 Updating core components...")
        pip_executable = self._get_executable_path("pip")
        for package in core_packages:
            try:
                subprocess.run([pip_executable, "install", "--upgrade", package], check=True)
            except subprocess.CalledProcessError as e:
                logging.error("Failed to update package %s: %s", package, str(e))
                print(f"❌ Failed to update {package}.")
        print("✅ Core components updated.")

    def install_deps(self):
        """
        Install dependencies listed in the requirements.txt file, if it exists.
        """
        reqPath = os.path.join(self.envDir, "requirements.txt")
        pip_executable = self._get_executable_path("pip")
        if os.path.exists(reqPath):
            print(f"📦 Installing dependencies from {reqPath}...")
            try:
                subprocess.run([pip_executable, "install", "-r", reqPath], check=True)
                logging.info("Dependencies installed successfully.")
            except subprocess.CalledProcessError as e:
                logging.error("Failed to install dependencies: %s", str(e))
                print("❌ Failed to install dependencies.")
        else:
            print("⚠️ No requirements.txt found in the project directory. Skipping dependency installation.")

    def update_deps(self):
        """
        Update project dependencies using the requirements.txt file if it exists.

        This method:
          - Constructs the absolute path to requirements.txt based on the project directory.
          - Checks if the file exists. If not, it prints a warning and skips the update.
          - If the file exists, it uses the pip executable from the virtual environment to update dependencies.
          - Handles errors gracefully, logging them and informing the user.
        """
        # Construct the absolute path to the requirements.txt file in the project directory.
        reqPath = os.path.join(self.envDir, "requirements.txt")

        # Obtain the correct pip executable from the project's virtual environment.
        pip_executable = self._get_executable_path("pip")

        # Check if the requirements file exists before attempting to update dependencies.
        if not os.path.exists(reqPath):
            print("⚠️ No requirements.txt found. Skipping update.")
            logging.info("No requirements.txt found at %s. Skipping dependency update.", reqPath)
            return

        # If the file exists, proceed to update dependencies.
        print("🔄 Updating dependencies...")
        try:
            subprocess.run([pip_executable, "install", "--upgrade", "-r", reqPath], check=True)
            logging.info("Dependencies updated successfully using %s", reqPath)
        except subprocess.CalledProcessError as e:
            logging.error("Failed to update dependencies: %s", str(e))
            print("❌ Failed to update dependencies.")

    def activate_env(self):
        """
        Programmatically activate the new virtual environment by either:
          1) Deactivating the master environment and launching a new shell with the new environment activated,
          2) Re-executing the current script with the new environment's Python (layering it on top of the master environment), or
          3) Aborting activation.

        The user is prompted if the current interpreter belongs to the master environment.
        """
        import subprocess

        # Determine the full path to the target (new) environment's Python interpreter.
        env_python = self._get_executable_path("python")
        current_executable = os.path.abspath(sys.executable)
        master_env = os.path.join(os.path.expanduser("~"), ".EZVenv", "EZVenv-Master")

        # Check if the current Python executable is from the master environment.
        if master_env in current_executable:
            print("It is detected you are currently in the master EZVenv environment.")
            print(f"New environment to be activated: {self.envPath}")
            print("Choose an option:")
            print("  1) Deactivate the master environment and then activate the new environment.")
            print("  2) Activate the new environment on top of the master environment.")
            print("  3) Do nothing (abort activation).")
            choice = input("Enter 1, 2, or 3: ").strip()
            if choice == "3":
                print("No changes made. Exiting activation.")
                sys.exit(0)
            elif choice == "1":
                # Option 1: Deactivate master environment and launch a new shell with the new environment activated.
                print("Deactivating master environment and starting new shell with the new environment...")
                new_activate_script = os.path.join(self.envPath, "bin", "activate")
                # Set a flag to indicate activation has been attempted to avoid looping.
                os.environ["EZVENV_ALREADY_ACTIVATED"] = "1"
                # Launch a new interactive bash shell that sources the new environment.
                os.execv("/bin/bash", ["/bin/bash", "-c", f"source {new_activate_script} && exec bash"])
            elif choice == "2":
                print("Proceeding to activate the new environment on top of the master environment...")
                # Continue to re-execute with the new environment's Python.
                os.environ["EZVENV_ALREADY_ACTIVATED"] = "1"
                try:
                    os.execv(env_python, [env_python] + sys.argv)
                except Exception as e:
                    print(f"❌ Failed to activate virtual environment: {e}")
                    sys.exit(1)
            else:
                print("Invalid choice. Exiting.")
                sys.exit(0)

        # If we're not in the master environment, or if we already re-executed:
        if os.path.abspath(sys.executable) != os.path.abspath(env_python):
            # Check if EZVenv is importable in the new environment.
            try:
                subprocess.run(
                    [env_python, "-c", "import ezvenv"],
                    check=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE
                )
            except subprocess.CalledProcessError:
                print("🔄 Adding master environment's site-packages to PYTHONPATH for auto-activation...")
                python_version = f"python{sys.version_info.major}.{sys.version_info.minor}"
                master_site_packages = os.path.join(master_env, "lib", python_version, "site-packages")
                if os.path.exists(master_site_packages):
                    current_pythonpath = os.environ.get("PYTHONPATH", "")
                    os.environ["PYTHONPATH"] = master_site_packages + (
                        os.pathsep + current_pythonpath if current_pythonpath else "")
                else:
                    print(
                        "❌ Master environment site-packages not found. Please ensure EZVenv is installed in the master environment.")
                    sys.exit(1)
            print(f"🔄 Activating virtual environment using {env_python} ...")
            os.environ["EZVENV_ALREADY_ACTIVATED"] = "1"
            try:
                os.execv(env_python, [env_python] + sys.argv)
            except Exception as e:
                print(f"❌ Failed to activate virtual environment: {e}")
                sys.exit(1)
        else:
            # We are now running with the new environment's Python.
            print(f"✅ New environment activated: {self.envPath}")

    def setup_env(self):
        """
        High-level method to create, configure, and optionally activate the virtual environment.
        It:
            1. Creates the environment if it doesn't exist.
            2. Updates core components.
            3. Installs and updates project dependencies.
            4. Optionally, re-launches the script with the virtual environment's Python.
        """
        self.create_env()
        print(f"🔗 Preparing to activate environment: {self.envPath}")

        # Install dependencies and update them
        self.install_deps()
        self.update_deps()

        logging.info("Environment setup completed successfully.")
        # If auto-activation is enabled, attempt to re-launch the process with the env's Python.
        if self.autoActivate:
            self.activate_env()
        else:
            print("ℹ️ Auto-activation is disabled. Please activate the virtual environment manually if needed.")


def init_env(env_name=None, env_dir=None, python_ver=None, config_file=None, save_defaults=False, auto_activate=True):
    """
    Initialize and set up the virtual environment (v0.5.0).

    New features:
      - Accepts an optional directory to initialize.
      - If a directory is provided:
          • If it does not exist, it is created and the script moves into it.
          • If it exists and is not empty, a prompt asks for confirmation.
      - The configuration file (default: ezvenv.yaml) is generated in the target directory.
        If it already exists, a prompt asks for confirmation before overwriting.
      - After initialization, the new virtual environment is activated
        by re-launching the process with the new environment's Python interpreter.

    Parameters:
      env_name (str): Name of the virtual environment.
      env_dir (str): Directory to initialize (if provided, otherwise the current directory).
      python_ver (str): Python interpreter to use.
      config_file (str): Path to the configuration file.
      save_defaults (bool): Whether to save settings as defaults.
      auto_activate (bool): If True, re-launch the process with the new environment's Python.

    Returns:
      str: The path to the virtual environment.
    """
    # If the environment was already activated, skip re-initialization.
    if os.environ.get("EZVENV_ALREADY_ACTIVATED") == "1":
        print("Environment already activated, skipping re-initialization.")
        return os.getcwd()

    # --- Directory preparation ---
    if env_dir:
        if not os.path.exists(env_dir):
            print(f"Directory '{env_dir}' does not exist. Creating it...")
            os.makedirs(env_dir, exist_ok=True)
        else:
            if os.listdir(env_dir):
                answer = input(f"Directory '{env_dir}' is not empty. Are you sure you want to initialize it? (Y/n): ")
                if answer.lower() not in ["y", "yes", ""]:
                    print("Initialization aborted.")
                    sys.exit(0)
        os.chdir(env_dir)
        if not config_file:
            config_file = os.path.join(os.getcwd(), "ezvenv.yaml")
        else:
            if os.path.exists(config_file):
                answer = input(f"Configuration file '{config_file}' already exists. Overwrite? (Y/n): ")
                if answer.lower() not in ["y", "yes", ""]:
                    print("Initialization aborted due to existing configuration.")
                    sys.exit(0)
    else:
        env_dir = os.getcwd()
        if not config_file:
            config_file = os.path.join(env_dir, "ezvenv.yaml")
        else:
            if os.path.exists(config_file):
                answer = input(f"Configuration file '{config_file}' already exists. Overwrite? (Y/n): ")
                if answer.lower() not in ["y", "yes", ""]:
                    print("Initialization aborted due to existing configuration.")
                    sys.exit(0)

    # --- Environment Setup ---
    env = EZVenv(
        config_file=config_file,
        env_name=env_name,
        env_dir=env_dir,
        python_ver=python_ver,
        save_defaults=save_defaults,
        auto_activate=auto_activate
    )
    env.setup_env()
    return env.envPath
