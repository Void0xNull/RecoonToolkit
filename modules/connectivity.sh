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

echo -e "${blueColour} Checking connectivity with $TARGET...${endColour}"

# Send a single ICMP packet with ping and capture TTL
PING_OUTPUT=$(ping -c 1 $TARGET 2>/dev/null)

# Check if the host responds
if [[ $? -ne 0 ]]; then
    echo -e "${redColour} No response from target ($TARGET). It may be offline or blocking ICMP.${endColour}"
    exit 1
fi

# Extract TTL from ping output
TTL=$(echo "$PING_OUTPUT" | grep -oP 'ttl=\K[0-9]+')

# Determine the operating system based on TTL
if [[ $TTL -ge 0 && $TTL -le 64 ]]; then
    OS="${greenColour}Linux/Unix${endColour}"
elif [[ $TTL -ge 65 && $TTL -le 128 ]]; then
    OS="${purpleColour}Windows${endColour}"
elif [[ $TTL -ge 129 && $TTL -le 255 ]]; then
    OS="${turquoiseColour}BSD/macOS${endColour}"
else
    OS="${yellowColour}Unknown${endColour}"
fi

echo -e "${greenColour} Connectivity established with $TARGET${endColour}"
echo -e "${yellowColour} Estimated operating system:${endColour} $OS (TTL=$TTL)"
