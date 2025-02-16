#!/bin/bash

# Define colors
greenColour="\e[0;32m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
endColour="\033[0m\e[0m"

# Handle Ctrl+C
function ctrl_c() {
    echo -e "\n${yellowColour}[*]${endColour}${redColour} Exiting...${endColour}"
    tput cnorm
    exit 1
}

trap ctrl_c INT

# Check if an IP is provided
if [ -z "$1" ]; then
    echo -e "${redColour} Incorrect usage:${endColour} $0 <IP>"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"

echo -e "${blueColour} Starting port scan on $TARGET...${endColour}"

# Phase 1: Quick scan of all ports
echo -e "${yellowColour} Running quick port scan...${endColour}"
open_ports=$(nmap -p- -sS -Pn -n -v --open --min-rate 5000 "$TARGET" 2>/dev/null | grep "Discovered open port" | awk '{print $4}' | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$open_ports" ]; then
    echo -e "${redColour} No open ports found.${endColour}"
    exit 1
else
    echo -e "${greenColour} Open ports detected: ${endColour}${yellowColour}$open_ports${endColour}"
fi

# Phase 2: Detailed analysis of open ports
echo -e "${blueColour} Analyzing services and versions...${endColour}"
nmap -p"$open_ports" -sCV -Pn -n -v "$TARGET" -oN "$OUTPUT_DIR/ports_$TARGET.txt" 2>/dev/null

echo -e "${greenColour} Scan completed. Results saved in:${endColour} ${blueColour}$OUTPUT_DIR/ports_$TARGET.txt${endColour}"
