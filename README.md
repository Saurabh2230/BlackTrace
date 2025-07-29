# BLACKTRACE 🕵️‍♂️

**BlackTrace** is an automated Bash-based tool for subdomain enumeration, live host detection, JavaScript file extraction, and sensitive information leak detection from JS files.

## 🚀 Features

- 🔍 Subdomain Enumeration using `subfinder`
- 🌐 Live Host Detection using `httpx`
- 📦 JavaScript URL Extraction using `katana` and `waybackurls`
- 🕵️ Secret Detection in JS files (API keys, tokens, secrets, etc.)
- 📂 Output Files: `domain.txt`, `alive.txt`, `js.txt`, `result.txt`
- 🎨 Stylish banner using `figlet` + `lolcat`

## 🔧 Requirements

- Go (for installing subfinder, httpx, etc.)
- figlet (`sudo apt install figlet`)
- lolcat (`sudo gem install lolcat`)
- curl

## 🛠️ Installation

```bash
git clone https://github.com/YourUsername/blacktrace.git
cd blacktrace
chmod +x blacktrace.sh
./blacktrace.sh
