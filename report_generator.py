import os
import jinja2
import re

# Define directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RESULTS_DIR = os.path.join(BASE_DIR, "modules/results")
TEMPLATE_DIR = os.path.join(BASE_DIR, "templates")
OUTPUT_FILE = os.path.join(RESULTS_DIR, "report.html")

# Create the output directory if it does not exist
os.makedirs(RESULTS_DIR, exist_ok=True)

# Function to automatically detect generated files
def find_latest_file(prefix):
    for file in os.listdir(RESULTS_DIR):
        if file.startswith(prefix):
            return file
    return None  # Returns None if no file is found

# Function to clean ANSI escape sequences and improve presentation
def clean_data(content):
    if content == "Not available":
        return content
    # Remove ANSI sequences
    content = re.sub(r"\x1B\[[0-9;]*[mK]", "", content)
    # Remove additional empty lines
    content = "\n".join([line.strip() for line in content.split("\n") if line.strip()])
    return content

# Load data from result files and clean them
def load_data(filename):
    file_path = os.path.join(RESULTS_DIR, filename)
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            return clean_data(f.read())  # Clean before returning
    return "Not available"

# Dynamically detect generated files
connectivity_file = find_latest_file("connectivity_")
ports_file = find_latest_file("ports_")
subdomains_file = find_latest_file("subdomains_")
whois_file = find_latest_file("whois_")
techscan_file = find_latest_file("techscan_")

# Filter data to display only relevant information in "Connectivity"
def filter_connectivity(data):
    lines = data.split("\n")
    filtered_lines = [
        line for line in lines if "Connectivity established" in line or "Estimated operating system" in line
    ]
    return "\n".join(filtered_lines) if filtered_lines else "Not available"

# Add both port scanning commands
def format_ports(data):
    return (
        "### Port Discovery Scan ###\n"
        "$ nmap -p- -sS -Pn -n -v --open --min-rate 5000 <target>\n\n"
        "### Detailed Scan of Open Ports ###\n"
        "$ nmap -pX,X,X -sCV -Pn -n -v <target>\n\n"
        + data
    )

# Load obtained data with proper formatting and cleaning
report_data = {
    "connectivity": filter_connectivity(load_data(connectivity_file)) if connectivity_file else "Not available",
    "ports": format_ports(load_data(ports_file)) if ports_file else "Not available",
    "subdomains": load_data(subdomains_file) if subdomains_file else "Not available",
    "whois": load_data(whois_file) if whois_file else "Not available",
    "techscan": load_data(techscan_file) if techscan_file else "Not available"
}

# Load the HTML template with Jinja2
env = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATE_DIR))
template = env.get_template("report_template.html")

# Render the report
html_content = template.render(report_data)

# Save the report to a file
with open(OUTPUT_FILE, "w") as f:
    f.write(html_content)

print(f" Report generated: {OUTPUT_FILE}")
