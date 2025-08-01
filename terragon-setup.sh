#!/bin/bash

export XATA_BRANCHNAME=main
export XATA_DATABASENAME=app

# Install dependencies
bun install

# Install jq if not present
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y jq
    elif command -v yum &> /dev/null; then
        yum install -y jq
    elif command -v brew &> /dev/null; then
        brew install jq
    else
        echo "Error: Could not install jq. Please install it manually."
        exit 1
    fi
fi

# Install Xata CLI
curl -fsSL https://xata.io/install.sh | bash

# Setup PATH for Xata
export PATH="$HOME/.config/xata/bin:$PATH"

# Display Xata version and status
xata version
xata status

# Delete existing branch if it exists
xata branch delete $E2B_SANDBOX_ID --yes || true

# Create new branch (also does branch checkout)
xata branch create --name $E2B_SANDBOX_ID
unset XATA_BRANCHID

# Wait for branch to be ready
xata branch wait-ready $E2B_SANDBOX_ID

# Create .env file with database connection string
echo DATABASE_URL="$(xata branch view $E2B_SANDBOX_ID --json | jq -r '.connectionString')" > .env

echo "Setup complete! Database URL has been written to .env"
