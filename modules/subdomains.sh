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

# Check if an IP or domain is provided
if [ -z "$1" ]; then
    echo -e "${redColour} Incorrect usage:${endColour} $0 <IP/Domain>"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"

DIR_WORDLIST="/usr/share/wordlists/dirb/common.txt"

if [ ! -f "$DIR_WORDLIST" ]; then
    echo -e "${redColour} Wordlist not found: ${DIR_WORDLIST}${endColour}"
    exit 1
fi

echo -e "${blueColour} Scanning directories on $TARGET...${endColour}"

# Run optimized Gobuster
gobuster dir -u "http://$TARGET" -w "$DIR_WORDLIST" -q -o "$OUTPUT_DIR/dirs_$TARGET.txt" --threads 50 --timeout 5s -e

echo -e "${greenColour} Scan completed. Results saved in:${endColour} ${blueColour}$OUTPUT_DIR/dirs_$TARGET.txt${endColour}"
