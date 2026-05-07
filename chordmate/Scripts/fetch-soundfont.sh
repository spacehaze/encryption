#!/usr/bin/env bash
# Downloads GeneralUser GS SoundFont into Audio/Resources/.
# License: SCC (S. Christian Collins) — free for any use, attribution appreciated.
# Source: https://schristiancollins.com/generaluser.php

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
DEST="$PROJECT_ROOT/Audio/Resources/GeneralUser-GS.sf2"

if [[ -f "$DEST" ]]; then
    echo "SoundFont already present at $DEST"
    exit 0
fi

mkdir -p "$(dirname "$DEST")"

# Mirror that hosts a stable copy of GeneralUser GS v1.471.
URL="https://github.com/musescore/MuseScore/raw/v3.6.2/share/sound/MuseScore_General.sf2"
# Fallback: official site (slower, occasionally rate-limited).
FALLBACK_URL="https://schristiancollins.com/soundfonts/GeneralUser_GS_1.471.zip"

echo "Downloading SoundFont from $URL ..."
if curl -fL --progress-bar "$URL" -o "$DEST"; then
    echo "Saved to $DEST"
else
    echo "Primary download failed; trying fallback..."
    TMP_ZIP="$(mktemp -t generaluser.XXXXXX.zip)"
    curl -fL --progress-bar "$FALLBACK_URL" -o "$TMP_ZIP"
    unzip -j -o "$TMP_ZIP" "*.sf2" -d "$(dirname "$DEST")"
    mv "$(dirname "$DEST")"/*.sf2 "$DEST"
    rm -f "$TMP_ZIP"
    echo "Saved to $DEST"
fi
