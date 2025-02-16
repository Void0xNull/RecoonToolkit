# RecoonToolkit

RecoonToolkit is a **Red Team reconnaissance toolkit** designed for automated and structured information gathering. It integrates multiple reconnaissance techniques into a single workflow, providing filtered and well-organized results.

## Features

- **Automated reconnaissance workflow**
- **Connectivity check** with target OS inference
- **Port scanning** (full-range + service/version detection)
- **Subdomain enumeration**
- **WHOIS lookup**
- **Technology fingerprinting**
- **Organized output storage** in `modules/results/`
- **Progress indicator with animation**
- **HTML report generation** with structured results

## Installation

### Requirements
Ensure you have the following dependencies installed:

- **Python 3**
- **nmap**
- **whatweb**
- **gobuster**
- **whois**
- **curl**
- **lynx** *(optional, for extracting emails from web pages)*
- **wordlists** *(subdomains.sh uses:`/usr/share/wordlists/dirb/common.txt` for directory enumeration)*

To install missing dependencies on Debian-based systems:
```bash
sudo apt update && sudo apt install -y nmap whatweb gobuster whois curl lynx wordlists
```

Clone the repository:
```bash
git clone https://github.com/Void0xNull/RecoonToolkit_V1.git
cd RecoonToolkit_V1
```

## Usage

Run the toolkit by providing a target domain or IP:
```bash
python3 recon.py --target <target>
```

Example:
```bash
python3 recon.py --target 192.168.0.0
```
After running recon.py, execute report_generator.py:
```bash
python3 report_generator.py
```


### Workflow
RecoonToolkit follows this logical order for reconnaissance:

1. **Connectivity Check (`connectivity.sh`)**
   - Verifies if the target is online
   - Infers the OS based on TTL value

2. **Port Scanning (`ports.sh`)**
   - Phase 1: Fast scan of all ports (`nmap -p- -sS -Pn -n -v --open --min-rate 5000`)
   - Phase 2: Detailed scan of open ports (`nmap -p<open_ports> -sCV -Pn -n -v`)

3. **Subdomain Enumeration (`subdomains.sh`)**
   - Uses gobuster to actively enumerate subdomains (`gobuster dir -u "http://<TARGET> -w .../wordlists/dirb/common.txt -q -o <output.txt> --threads 50 --timeout 5s -e`)

4. **WHOIS Lookup (`whois.sh`)**
   - Does an scraping of the entire main domain

5. **Technology Detection (`techscan.sh`)**
   - Uses whatweb in a very agressive mode to gather the maximum information

6. **HTML Report Generation (`report_generator.py`)**
   - Generate an .html file in the results directory (/modules/results/report.html) with an exhaustive report of all the information obtained during the evaluation.

## Output Structure

All results are stored inside `modules/results/`:

```
RecoonToolkit/
├── recon.py
├── report_generator.py
├── README.md
│  
├── templates/
│   ├── report_style.css
│   ├── report_template.html
├── modules/
│   ├── results/
│   │   ├── connectivity_<target>.txt
│   │   ├── dirs_<target>.txt
│   │   ├── ports_<target>.txt
│   │   ├── subdomains_<target>.txt
│   │   ├── whois_<target>.txt
│   │   ├── techscan_<target>.txt
│   │   ├── report.html
│   |
│   ├── connectivity.sh
│   ├── ports.sh
│   ├── subdomains.sh
│   ├── techscan.sh
│   ├── whois.sh
```

## License

This project is released under the **MIT License**.

## Disclaimer

RecoonToolkit is intended exclusively for **educational purposes** and **ethical hacking**. It is designed to help cybersecurity professionals, researchers, and penetration testers understand and improve security practices. **This tool must never be used for malicious activities or unauthorized testing.**

Unauthorized scanning, reconnaissance, or any form of exploitation against systems, networks, or individuals without explicit permission from the owner is strictly prohibited. Using this tool without proper authorization may violate local, national, or international laws, and could result in severe legal consequences.

The developers and contributors of RecoonToolkit assume **no responsibility or liability** for any misuse, illegal activity, or damage caused by the improper or unlawful use of this tool. Users are solely responsible for ensuring that they comply with all applicable laws and obtain necessary permissions before conducting any tests.

By using RecoonToolkit, **you agree to use it responsibly and ethically**, following all legal and ethical guidelines related to cybersecurity and penetration testing.


