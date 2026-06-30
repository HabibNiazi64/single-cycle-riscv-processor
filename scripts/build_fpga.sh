#!/bin/bash

set -e

echo "🚀 Cleaning old build files..."
rm -f pack.json route.json top.fs

echo "🧠 Running Yosys synthesis..."
yosys -p "synth_gowin -top top -json pack.json" *.v

echo "📍 Running Place & Route..."
nextpnr-himbaechel \
  --json pack.json \
  --write route.json \
  --device GW1NR-LV9QN88PC6/I5 \
  --vopt family=GW1N-9C \
  --vopt cst=ports.cst

echo "📦 Packing bitstream..."
gowin_pack -d GW1N-9C -o top.fs route.json

echo "⚡ Flashing FPGA..."
sudo openFPGALoader -c ft2232 top.fs

echo "✅ DONE: FPGA programmed successfully!"
