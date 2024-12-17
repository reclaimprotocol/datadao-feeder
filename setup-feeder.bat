@echo off
setlocal EnableDelayedExpansion

echo DataDAO Feeder Setup Wizard
echo -------------------------

:: Get user inputs interactively
set /p APP_SECRET="Enter APP_SECRET: "
set /p NETWORK="Enter NETWORK (e.g., arbitrum-mainnet): "
set /p API_URL="Enter API_URL (e.g., https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDC): "
set /p FEED_INTERVAL="Enter FEED_INTERVAL in seconds (e.g., 3600): "

echo.
echo Starting DataDAO Feeder Setup...

:: Check if git is installed
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing git...
    winget install --id Git.Git -e --source winget
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install git. Please install manually from https://git-scm.com/download/win
        exit /b 1
    )
)

:: Check if Node.js is installed
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing Node.js...
    winget install OpenJS.NodeJS
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install Node.js. Please install manually from https://nodejs.org/
        exit /b 1
    )
)

:: Create project directory
set "PROJECT_DIR=datadao-feeder"
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
cd "%PROJECT_DIR%"

:: Clone the repository
echo Cloning the repository...
git clone https://github.com/reclaimprotocol/datadao-feeder.git .

:: Create .env file with provided parameters
echo Creating .env file...
(
echo APP_SECRET=%APP_SECRET%
echo NETWORK=%NETWORK%
echo API_URL=%API_URL%
echo FEED_INTERVAL=%FEED_INTERVAL%
) > .env

:: Install dependencies if node_modules doesn't exist
if not exist "node_modules\" (
    echo Installing dependencies...
    call npm install
) else (
    echo Node modules already installed, skipping npm install...
)

:: Start the feeder
echo Starting the feeder...
node feeder.js

endlocal 