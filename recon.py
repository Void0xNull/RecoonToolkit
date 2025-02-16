import os
import subprocess
import argparse
import time
import threading
import shutil
import re
import sys

# Define correct directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # Path of the current script
MODULES_DIR = os.path.join(BASE_DIR, "modules")  # Modules directory
RESULTS_DIR = os.path.join(MODULES_DIR, "results")  # Correct results directory

# Create necessary folders if they do not exist
os.makedirs(RESULTS_DIR, exist_ok=True)

# Terminal colors
GREEN = "\033[0;32m"
RED = "\033[0;31m"
BLUE = "\033[0;34m"
YELLOW = "\033[0;33m"
RESET = "\033[0m"

# Animated spinner to show progress
spinner_active = False

def spinner():
    global spinner_active
    symbols = ["⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    idx = 0
    while spinner_active:
        print(f"\r{BLUE} Running... {symbols[idx]}{RESET}", end="", flush=True)
        idx = (idx + 1) % len(symbols)
        time.sleep(0.1)
    print("\r", end="", flush=True)

# Execute a Bash module and save the output in `modules/results/`
def run_module(module_name, target):
    script_path = os.path.join(MODULES_DIR, f"{module_name}.sh")
    output_file = os.path.join(RESULTS_DIR, f"{module_name}_{target}.txt")

    if not os.path.exists(script_path):
        print(f"{RED} Module {module_name} not found.{RESET}")
        return None, False

    # Start animation
    global spinner_active
    spinner_active = True
    spinner_thread = threading.Thread(target=spinner)
    spinner_thread.start()

    result = subprocess.run([script_path, target], capture_output=True, text=True)

    # Stop animation
    spinner_active = False
    spinner_thread.join()

    if result.returncode == 0:
        with open(output_file, "w") as f:
            f.write(result.stdout)

        # Clean output to display only relevant information
        clean_output = process_output(module_name, result.stdout)
        print(f"{GREEN} {module_name} completed.{RESET}")
        print(f"{YELLOW} Saved at:{RESET} {output_file}")
        print(f"{BLUE} Result:{RESET}\n{clean_output}\n")
        return output_file, True
    else:
        print(f"{RED} Error in {module_name}.{RESET}")
        return None, False

# Function to clean module output and filter relevant information
def process_output(module, output):
    lines = output.split("\n")
    clean_lines = []

    if module == "connectivity":
        for line in lines:
            if "Connectivity established" in line or "Estimated operating system" in line:
                clean_lines.append(line.strip())
            elif "No response from target" in line:
                print(f"{RED} No response from target. It may be offline or blocking ICMP.{RESET}")
                sys.exit(1)  # Immediately stop the program

    elif module == "ports":
        # extract open ports and display them as "Port: X, X, X"
        ports = re.findall(r"(\d{1,5})/tcp", "\n".join(lines))
        if ports:
            clean_lines.append(f"{YELLOW} Port: {', '.join(sorted(set(ports)))}")
        else:
            clean_lines.append(f"{RED} No open ports found.")

    elif module == "subdomains":
        # Display exactly the contents of `dirs_<target>.txt`
        dirs_file = os.path.join(RESULTS_DIR, f"dirs_{target}.txt")
        if os.path.exists(dirs_file):
            with open(dirs_file, "r") as f_dirs:
                return f"{YELLOW}{f_dirs.read().strip()}{RESET}"

    elif module == "whois":
        keywords = ["Owner:", "Creation Date:", "Expiration Date:", "DNS Servers:", "Emails found:", "Phone numbers found:"]
        for line in lines:
            if any(keyword in line for keyword in keywords):
                clean_lines.append(line)

    elif module == "techscan":
        for line in lines:
            if "[" in line and "]" in line:  # Filter lines with detected technologies
                clean_lines.append(f"{YELLOW}{line}{RESET}")

    return "\n".join(clean_lines) if clean_lines else f"{RED} No relevant data found."

# Move generated files out of `modules/results/`
def fix_file_locations(target):
    root_results_dir = os.path.join(BASE_DIR, "results")  # Incorrect folder
    if os.path.exists(root_results_dir):
        for file in os.listdir(root_results_dir):
            if file.startswith(("connectivity_", "dirs_", "ports_", "subdomains_", "techscan_", "whois_")):
                src = os.path.join(root_results_dir, file)
                dest = os.path.join(RESULTS_DIR, file)
                shutil.move(src, dest)
        shutil.rmtree(root_results_dir)  # Remove duplicate folder

# Parse CLI arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Red Teaming Recon Toolkit")
    parser.add_argument("--target", required=True, help="Target domain or IP")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    target = args.target

    print(f"\n{YELLOW} Target: {target}{RESET}\n")

    # Run `connectivity` first and stop if it fails
    _, success = run_module("connectivity", target)
    if not success:
        print(f"{RED} No response from target ({target}). It may be offline or blocking ICMP.{RESET}")
        sys.exit(1)

    # If connectivity was successful, run the remaining modules
    modules = ["ports", "subdomains", "whois", "techscan"]

    for module in modules:
        run_module(module, target)

    fix_file_locations(target)

    print(f"{GREEN} Recon completed. All results are in {RESULTS_DIR}.{RESET}")
