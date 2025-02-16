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

# Check if a domain is provided
if [ -z "$1" ]; then
    echo -e "${redColour} Incorrect usage:${endColour} $0 <domain>"
    exit 1
fi

DOMAIN=$1
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"

echo -e "${blueColour} Performing WHOIS lookup on $DOMAIN...${endColour}"

# Run whois and extract key information
WHOIS_INFO=$(whois "$DOMAIN" 2>/dev/null)

# Extract relevant data and clean extra spaces
REGISTRANT=$(echo "$WHOIS_INFO" | grep -Ei 'Registrant|OrgName|Owner|holder' | head -1 | awk -F': ' '{print $2}' | sed 's/^[ \t]*//')
CREATION_DATE=$(echo "$WHOIS_INFO" | grep -Ei 'Creation Date|Registered On' | head -1 | awk -F': ' '{print $2}' | sed 's/^[ \t]*//')
EXPIRATION_DATE=$(echo "$WHOIS_INFO" | grep -Ei 'Expiry Date|Expiration Date' | head -1 | awk -F': ' '{print $2}' | sed 's/^[ \t]*//')
NAME_SERVERS=$(echo "$WHOIS_INFO" | grep -Ei 'Name Server' | awk '{print $NF}' | paste -sd ", ")

# Scraping the website to extract emails and phone numbers
echo -e "${yellowColour} Extracting contact details from the website...${endColour}"
WEB_HTML=$(curl -s "http://$DOMAIN")

# Search for emails in the source code (method 1)
EMAILS_RAW=$(echo "$WEB_HTML" | grep -Eoi '[[:alnum:]_.+-]+@[[:alnum:]_-]+(\.[[:alnum:]_-]+)+' | sort -u)

# Search for emails in the rendered page using lynx (method 2)
if command -v lynx &>/dev/null; then
    EMAILS_LYNX=$(lynx -dump "http://$DOMAIN" | grep -Eoi '[[:alnum:]_.+-]+@[[:alnum:]_-]+(\.[[:alnum:]_-]+)+' | sort -u)
else
    EMAILS_LYNX=""
fi

# Combine both methods and remove duplicates
EMAILS=$(echo -e "$EMAILS_RAW\n$EMAILS_LYNX" | sort -u | tr '\n' ',' | sed 's/,$//')

# Search for phone numbers
PHONE_NUMBERS=$(echo "$WEB_HTML" | grep -Eo '\+?[0-9]{1,3}[-. ]?[0-9]{1,4}[-. ]?[0-9]{3,4}[-. ]?[0-9]{3,4}' | sort -u | tr '\n' ',' | sed 's/,$//')

# Assign "Not available" if no data is found
REGISTRANT=${REGISTRANT:-Not available}
CREATION_DATE=${CREATION_DATE:-Not available}
EXPIRATION_DATE=${EXPIRATION_DATE:-Not available}
NAME_SERVERS=${NAME_SERVERS:-Not available}
EMAILS=${EMAILS:-Not available}
PHONE_NUMBERS=${PHONE_NUMBERS:-Not available}

# Save the information to a file and display clean output
{
    echo -e " ${yellowColour}Owner:${endColour} ${purpleColour}$REGISTRANT${endColour}"
    echo -e " ${yellowColour}Creation Date:${endColour} ${purpleColour}$CREATION_DATE${endColour}"
    echo -e " ${yellowColour}Expiration Date:${endColour} ${purpleColour}$EXPIRATION_DATE${endColour}"
    echo -e " ${yellowColour}DNS Servers:${endColour} ${blueColour}$NAME_SERVERS${endColour}"
    echo -e " ${yellowColour}Emails found:${endColour} ${greenColour}$EMAILS${endColour}"
    echo -e " ${yellowColour}Phone numbers found:${endColour} ${turquoiseColour}$PHONE_NUMBERS${endColour}"
} | tee "$OUTPUT_DIR/whois_$DOMAIN.txt"

echo -e "${greenColour} WHOIS lookup and web scraping completed. Results saved in:${endColour} ${blueColour}$OUTPUT_DIR/whois_$DOMAIN.txt${endColour}"
