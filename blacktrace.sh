#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
banner() {
clear
echo -e "${CYAN}"
echo '  ____  _            _      _              '
echo ' |  _ \| | __ _  ___| | __ | |_ ___  _ __  '
echo ' | |_) | |/ _` |/ __| |/ / | __/ _ \| `_ \ '
echo ' |  __/| | (_| | (__|   <  | || (_) | |_) |'
echo ' |_|   |_|\__,_|\___|_|\_\  \__\___/| .__/ '
echo '                                   |_|    '
echo -e "         ${RED}↳ JavaScript Secret Scanner by BlackTrace${NC}"
echo
}

# Tool check function
check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}[-] $1 not found. Installing...${NC}"
        GO111MODULE=on go install github.com/projectdiscovery/$1/cmd/$1@latest
        export PATH=$PATH:$(go env GOPATH)/bin
    else
        echo -e "${GREEN}[+] $1 is installed.${NC}"
    fi
}

# Start
banner

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}[-] Go not found. Please install Go first.${NC}"
    exit 1
fi

# Check and install tools
check_and_install subfinder
check_and_install httpx
check_and_install katana
check_and_install waybackurls

# Get domain from user
read -p "Enter a domain (e.g., example.com): " domain

# Make output folder
mkdir -p $domain && cd $domain

echo -e "${GREEN}[+] Finding subdomains...${NC}"
subfinder -d $domain -silent > domain.txt

echo -e "${GREEN}[+] Checking for live domains...${NC}"
cat domain.txt | httpx -silent > alive.txt

echo -e "${GREEN}[+] Extracting JS files using Katana...${NC}"
katana -u $(cat alive.txt) -jc -silent | grep "\.js" > katana_js.txt

echo -e "${GREEN}[+] Extracting JS files using Waybackurls...${NC}"
cat alive.txt | waybackurls | grep "\.js" > wayback_js.txt

echo -e "${GREEN}[+] Merging and deduplicating JS files...${NC}"
cat katana_js.txt wayback_js.txt | sort -u > js.txt

# Secret patterns
patterns=(
    "api_key"
    "secret"
    "apikey"
    "access_token"
    "authorization"
    "bearer"
    "password"
    "firebase"
    "client_secret"
    "AWSAccessKey"
)

echo -e "${GREEN}[+] Searching for secrets in JS files...${NC}"
> result.txt

for url in $(cat js.txt); do
    echo "[*] Checking $url"
    content=$(curl -s "$url")
    for pattern in "${patterns[@]}"; do
        if echo "$content" | grep -iE "$pattern" &>/dev/null; then
            echo -e "\n[+] Possible secret in: $url" >> result.txt
            echo "$content" | grep -iE "$pattern" >> result.txt
            echo -e "-------------------------------" >> result.txt
        fi
    done
done

if [ -s result.txt ]; then
    echo -e "${GREEN}[+] Secrets found! Check result.txt${NC}"
else
    echo "Nothing is there." > result.txt
    echo -e "${RED}[-] No secrets found.${NC}"
fi
