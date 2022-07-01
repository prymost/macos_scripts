#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "***** Brew packs *****"
brew upgrade

echo "***** NPM Packages *****"
npm up -g
