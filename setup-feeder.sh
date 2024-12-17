#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
while getopts ":s:n:u:i:" opt; do
  case $opt in
    s) APP_SECRET="$OPTARG"
    ;;
    n) NETWORK="$OPTARG"
    ;;
    u) API_URL="$OPTARG"
    ;;
    i) FEED_INTERVAL="$OPTARG"
    ;;
    \?) echo -e "${RED}Invalid option -$OPTARG${NC}" >&2
        exit 1
    ;;
    :) echo -e "${RED}Option -$OPTARG requires an argument.${NC}" >&2
        exit 1
    ;;
  esac
done

# Validate required parameters
if [ -z "$APP_SECRET" ] || [ -z "$NETWORK" ] || [ -z "$API_URL" ] || [ -z "$FEED_INTERVAL" ]; then
    echo -e "${RED}Usage: $0 -s APP_SECRET -n NETWORK -u API_URL -i FEED_INTERVAL${NC}"
    echo "Example:"
    echo "$0 -s 0xa5a3cdc0b4e14be68ed0c0de775d015c311fb258148d2da60e26da63dff06e22 \\"
    echo "   -n arbitrum-mainnet \\"
    echo '   -u "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDC" \\'
    echo "   -i 3600"
    exit 1
fi

echo -e "${GREEN}Starting DataDAO Feeder Setup...${NC}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install git if not present
if ! command_exists git; then
    echo -e "${GREEN}Installing git...${NC}"
    sudo apt-get update
    sudo apt-get install -y git
    
    if ! command_exists git; then
        echo -e "${RED}Failed to install git. Please install manually.${NC}"
        exit 1
    fi
fi

# Install Node.js and npm if not present
if ! command_exists node; then
    echo -e "${GREEN}Installing Node.js and npm...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    if ! command_exists node; then
        echo -e "${RED}Failed to install Node.js. Please install manually.${NC}"
        exit 1
    fi
fi

# Create project directory
PROJECT_DIR="datadao-feeder"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clone the repository
echo -e "${GREEN}Cloning the repository...${NC}"
git clone https://github.com/reclaimprotocol/datadao-feeder.git .

# Create .env file with provided parameters
echo -e "${GREEN}Creating .env file...${NC}"
cat > .env << EOL
APP_SECRET=$APP_SECRET
NETWORK=$NETWORK
API_URL="$API_URL"
FEED_INTERVAL=$FEED_INTERVAL
EOL

# Install dependencies only if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo -e "${GREEN}Installing dependencies...${NC}"
    npm install
else
    echo -e "${GREEN}Node modules already installed, skipping npm install...${NC}"
fi

# Start the feeder
echo -e "${GREEN}Starting the feeder...${NC}"
node feeder.js 