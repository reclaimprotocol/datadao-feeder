#!/bin/bash

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
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
    :) echo "Option -$OPTARG requires an argument." >&2
        exit 1
    ;;
  esac
done

# Validate required parameters
if [ -z "$APP_SECRET" ] || [ -z "$NETWORK" ] || [ -z "$API_URL" ] || [ -z "$FEED_INTERVAL" ]; then
    echo "Usage: $0 -s APP_SECRET -n NETWORK -u API_URL -i FEED_INTERVAL"
    echo "Example:"
    echo "$0 -s 0xa5a3cdc0b4e14be68ed0c0de775d015c311fb25813332da60e26da63dff06e22 \\"
    echo "   -n arbitrum-mainnet \\"
    echo '   -u "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDC" \\'
    echo "   -i 3600"
    exit 1
fi

echo "Starting DataDAO Feeder Setup...\n"

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     
        OS='Linux'
        ;;
    Darwin*)    
        OS='Mac'
        ;;
    MINGW*|CYGWIN*|MSYS*)    
        OS='Windows'
        ;;
    *)          
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

echo "Detected OS: ${OS}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install git if not present
if ! command_exists git; then
    echo "Installing git..."
    case "${OS}" in
        Linux)
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        Mac)
            brew install git
            ;;
        Windows)
            echo "Please install Git manually from https://git-scm.com/download/win"
            exit 1
            ;;
    esac
    
    if ! command_exists git; then
        echo "Failed to install git. Please install manually."
        exit 1
    fi
fi

# Install Node.js and npm if not present
if ! command_exists node; then
    echo "Installing Node.js and npm..."
    case "${OS}" in
        Linux)
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        Mac)
            brew install node@18
            ;;
        Windows)
            echo "Please install Node.js manually from https://nodejs.org/"
            exit 1
            ;;
    esac
    
    if ! command_exists node; then
        echo "Failed to install Node.js. Please install manually."
        exit 1
    fi
fi

# Create project directory
PROJECT_DIR="datadao-feeder"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clone the repository
echo "Cloning the repository..."
git clone https://github.com/reclaimprotocol/datadao-feeder.git .

# Create .env file with provided parameters
echo "Creating .env file..."
cat > .env << EOL
APP_SECRET=$APP_SECRET
NETWORK=$NETWORK
API_URL="$API_URL"
FEED_INTERVAL=$FEED_INTERVAL
EOL

# Install dependencies only if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
else
    echo "Node modules already installed, skipping npm install..."
fi

# Start the feeder
echo "Starting the feeder..."
node feeder.js 