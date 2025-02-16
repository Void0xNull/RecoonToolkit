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

# Check if a domain or IP is provided
if [ -z "$1" ]; then
    echo -e "${redColour} Incorrect usage:${endColour} $0 <domain/IP>"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"

echo -e "${blueColour} Scanning technologies on $TARGET...${endColour}"

# Run whatweb in aggressive mode to gather maximum information
TECHNOLOGIES=$(whatweb --color=never -a 3 "$TARGET")

# Save results to file
echo "$TECHNOLOGIES" | tee "$OUTPUT_DIR/techscan_$TARGET.txt"

echo -e "${greenColour} Technology scan completed. Results saved in:${endColour} ${blueColour}$OUTPUT_DIR/techscan_$TARGET.txt${endColour}"
