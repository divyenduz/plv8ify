#!/bin/bash

export XATA_BRANCHNAME=main
export XATA_DATABASENAME=app

bun install
curl -fsSL https://xata.io/install.sh | bash

env
echo ~/
export PATH="~/.config/xata/bin:$PATH"

xata version
xata status
xata branch delete $E2B_SANDBOX_ID --yes || true
# Create also does branch checkout
xata branch create --name $E2B_SANDBOX_ID
unset XATA_BRANCHID
xata branch wait-ready $E2B_SANDBOX_ID
echo DATABASE_URL="$(xata branch view $E2B_SANDBOX_ID --json | jq -r '.connectionString')" > .env
