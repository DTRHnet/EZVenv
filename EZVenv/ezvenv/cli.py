
import argparse
from .core import EZVenv, init_env

def main():
    parser = argparse.ArgumentParser(description="EZVenv - Python Virtual Environment Manager")
    # The 'command' is required and must be one of init, install, update.
    parser.add_argument("command", choices=["init", "install", "update"], help="Command to run")
    # Optional directory argument for 'init'
    parser.add_argument("dir", nargs="?", help="Directory to initialize (if omitted, current directory is used)")
    args = parser.parse_args()

    if args.command == "init":
        # Pass the optional directory to init_env; interactive checks occur there.
        init_env(env_dir=args.dir)
    else:
        # For install and update, use the current directory settings.
        ezvenv = EZVenv()
        if args.command == "install":
            ezvenv.install_deps()
        elif args.command == "update":
            ezvenv.update_deps()

if __name__ == "__main__":
    main()
