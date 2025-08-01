#!/bin/bash

export XATA_BRANCHNAME=main
export XATA_DATABASENAME=app

bun install
curl -fsSL https://xata.io/install.sh | bash

env

xata status
xata checkout main