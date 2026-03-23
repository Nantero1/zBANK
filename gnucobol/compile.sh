#!/bin/bash
# zBANK - GnuCOBOL Compile Script
# Usage: ./compile.sh

set -e

PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJ_DIR"

echo "=== zBANK GnuCOBOL Build ==="
echo "Directory: $PROJ_DIR"
echo ""

echo "[1/4] Compiling ZBNKAUTH (authentication module)..."
cobc -m ZBNKAUTH.cbl -o ZBNKAUTH.so
echo "      OK"

echo "[2/4] Compiling ZBNKTXN (transaction module)..."
cobc -m ZBNKTXN.cbl -o ZBNKTXN.so
echo "      OK"

echo "[3/4] Compiling SEED (demo data loader)..."
cobc -x SEED.cbl -o seed
echo "      OK"

echo "[4/4] Compiling ZBNKBANK (main program)..."
cobc -x ZBNKBANK.cbl -o zbank
echo "      OK"

echo ""
echo "=== Build complete ==="
echo ""
echo "Next steps:"
echo "  1. Load demo accounts : ./seed"
echo "  2. Run zBANK          : ./zbank"
