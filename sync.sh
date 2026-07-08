#!/bin/bash
cd "$(dirname "$0")"
git add -A
git commit -m "update $(date +%Y-%m-%d_%H-%M-%S)"
git push
