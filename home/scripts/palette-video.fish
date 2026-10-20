#!/usr/bin/env fish
# palette-video.fish <input_video> [palette] [style]
# Sans palette en argument, le script la demande interactivement.

if test (count $argv) -lt 1
    echo "Usage: palette-video.fish <input_video> [palette] [style]" >&2
    exit 1
end

set INPUT $argv[1]
if not test -f "$INPUT"
    echo "❌ Fichier introuvable : $INPUT" >&2
    exit 1
end

# Vérifications
for cmd in ffmpeg ffprobe dipc
    if not command -v $cmd &>/dev/null
        echo "❌ $cmd manquant" >&2
        exit 1
    end
end

# --- Choix de la palette --------------------------------------------------
set KNOWN_PALETTES catppuccin dracula everforest gruvbox nord rose-pine solarized tokyo-night

set PALETTE ""
set STYLE ""

if test (count $argv) -ge 2
    set PALETTE $argv[2]
else
    echo "🎨 Palettes disponibles :"
    for i in (seq (count $KNOWN_PALETTES))
        echo "  $i) $KNOWN_PALETTES[$i]"
    end
    set OTHER_IDX (math (count $KNOWN_PALETTES) + 1)
    echo "  $OTHER_IDX) autre (saisie libre, voir `dipc --help`)"
    echo ""

    while test -z "$PALETTE"
        read -P "Palette (numéro ou nom) [1] : " CHOICE
        if test -z "$CHOICE"
            set CHOICE 1
        end

        if string match -qr '^[0-9]+$' -- $CHOICE
            if test $CHOICE -ge 1 -a $CHOICE -le (count $KNOWN_PALETTES)
                set PALETTE $KNOWN_PALETTES[$CHOICE]
            else if test $CHOICE -eq $OTHER_IDX
                read -P "Nom de la palette : " PALETTE
            else
                echo "⚠️  Choix invalide"
            end
        else
            set PALETTE $CHOICE
        end
    end
end

# --- Choix du style / variante --------------------------------------------
if test (count $argv) -ge 3
    set STYLE $argv[3]
else
    if test "$PALETTE" = catppuccin
        read -P "Flavor (latte|frappe|macchiato|mocha) [mocha] : " STYLE
        if test -z "$STYLE"
            set STYLE mocha
        end
    else
        read -P "Style/variante (vide = défaut de la palette) : " STYLE
    end
end

set DIPC_ARGS $PALETTE
if test -n "$STYLE"
    set -a DIPC_ARGS --styles $STYLE
end

# --- Préparation ----------------------------------------------------------
set BASENAME (basename $INPUT)
set NAME_NOEXT (string replace -r '\.[^.]+$' '' $BASENAME)
set OUT_DIR (dirname $INPUT)

set SUFFIX $PALETTE
if test -n "$STYLE"
    set SUFFIX "$PALETTE-$STYLE"
end
set OUT_VIDEO "$OUT_DIR/$NAME_NOEXT"_"$SUFFIX".mp4

mkdir -p $HOME/.cache
set FRAMES_IN (mktemp -d -p $HOME/.cache)
set FRAMES_OUT (mktemp -d -p $HOME/.cache)

echo ""
echo "🎬 $INPUT → $OUT_VIDEO"
echo "🌈 Palette: $SUFFIX"
echo ""

echo "[1/4] Extraction frames → $FRAMES_IN"
ffmpeg -hide_banner -loglevel error -i $INPUT \
    "$FRAMES_IN/frame_%05d.png"
if test $status -ne 0
    echo "❌ Erreur lors de l'extraction des frames" >&2
    rm -rf $FRAMES_IN $FRAMES_OUT
    exit 1
end

echo "[2/4] Application de la palette $PALETTE..."
dipc $DIPC_ARGS -d $FRAMES_OUT $FRAMES_IN/*.png
if test $status -ne 0
    echo "❌ Erreur dipc" >&2
    rm -rf $FRAMES_IN $FRAMES_OUT
    exit 1
end

echo "[2.5/4] Renommage des frames..."
set i 1
for f in (printf '%s\n' $FRAMES_OUT/*.png | sort)
    set target (printf "$FRAMES_OUT/frame_%05d.png" $i)
    if test "$f" != "$target"
        mv $f $target
    end
    set i (math $i + 1)
end

echo "[3/4] Récupération du framerate..."
set FPS_RAW (ffprobe -v 0 -of csv=p=0 -select_streams v:0 \
    -show_entries stream=r_frame_rate $INPUT)
set FPS_PARTS (string split / $FPS_RAW)
set FPS (math "$FPS_PARTS[1] / $FPS_PARTS[2]")
echo "    $FPS fps"

echo "[4/4] Reconstruction vidéo..."
# -map 1:a? : reprend l'audio de la vidéo d'origine s'il y en a un
ffmpeg -hide_banner -loglevel error \
    -framerate $FPS -i "$FRAMES_OUT/frame_%05d.png" \
    -i $INPUT \
    -map 0:v -map '1:a?' \
    -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a copy -shortest \
    $OUT_VIDEO
if test $status -ne 0
    echo "❌ Erreur lors de la reconstruction" >&2
    rm -rf $FRAMES_IN $FRAMES_OUT
    exit 1
end

echo ""
echo "✨ Terminé → $OUT_VIDEO"
rm -rf $FRAMES_IN $FRAMES_OUT
