#!/bin/bash
# ============================================================
# zBANK - Launcher com Cool Retro Term (Alien Isolation)
# Instala o Cool Retro Term se necessario e abre o banco
# ============================================================

PROJ="/mnt/c/Users/levi.lucena/Documents/GitHub/zBANK/gnucobol"

# Instala cool-retro-term se nao estiver instalado
if ! command -v cool-retro-term &>/dev/null; then
    echo "[*] Instalando Cool Retro Term..."
    sudo apt-get update -qq
    sudo apt-get install -y cool-retro-term
    echo "[OK] Instalado."
fi

# Cria o perfil Sevastopol se nao existir
PROFILE_DIR="$HOME/.config/coolretroterm"
mkdir -p "$PROFILE_DIR"

# Grava perfil via qmlscene settings (importado pelo CRT na 1a abertura)
cat > "$PROFILE_DIR/sevastopol.json" << 'EOF'
{
  "name": "Sevastopol",
  "font": {
    "family": "Monospace",
    "pixelSize": 14,
    "scaling": 1.0
  },
  "colors": {
    "backgroundColor": "#000000",
    "fontColor": "#00FF41"
  },
  "effects": {
    "ambientLight": 0.15,
    "bloom": 0.45,
    "burnIn": 0.40,
    "burnInTime": 0.50,
    "chromaColor": 0.15,
    "flickering": 0.04,
    "glowing": 0.20,
    "horizontalSync": 0.03,
    "jitter": 0.08,
    "noise": 0.03,
    "rbgShift": 0.10,
    "scanlines": 0.30,
    "screenCurvature": 0.12,
    "staticNoise": 0.02
  }
}
EOF

echo ""
echo "  =================================================="
echo "  >>  ZBANK FINANCIAL TERMINAL"
echo "  >>  Launching Cool Retro Term with Sevastopol profile"
echo "  =================================================="
echo ""

# Abre Cool Retro Term executando o zBANK diretamente
cool-retro-term --workdir "$PROJ" -e bash -c \
    "cd '$PROJ' && ./zbank; read -p 'Press ENTER to close...' x" &
