#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  focus-opacity.sh — Opacité dynamique Sway / Noctalia        ║
# ║  Focus   → 0.95  (au premier plan, quasi-opaque)             ║
# ║  Unfocus → 0.75  (en retrait, transparent)                   ║
# ╚══════════════════════════════════════════════════════════════╝

OPACITY_FOCUSED=0.95
OPACITY_UNFOCUSED=0.75

# Tue toute instance précédente du script (relance propre via exec_always)
pkill -f "focus-opacity.sh" 2>/dev/null || true
sleep 0.2

swaymsg -t subscribe '["window"]' --monitor | while IFS= read -r event; do

  change=$(printf '%s' "$event" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('change',''))
except:
    print('')
" 2>/dev/null)

  [[ "$change" != "focus" ]] && continue

  # ID de la fenêtre focalisée
  focused_id=$(swaymsg -t get_tree | python3 -c "
import sys, json

def find_focused(node):
    if node.get('focused'):
        return node.get('id')
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        r = find_focused(child)
        if r is not None:
            return r
    return None

print(find_focused(json.load(sys.stdin)) or '')
" 2>/dev/null)

  [[ -z "$focused_id" ]] && continue

  # Fenêtre focus → opaque
  swaymsg "[con_id=$focused_id] opacity $OPACITY_FOCUSED" 2>/dev/null

  # Toutes les autres fenêtres → transparent
  swaymsg -t get_tree | python3 -c "
import sys, json, subprocess

UNFOCUSED = '$OPACITY_UNFOCUSED'
EXCLUDE   = int('$focused_id')

def collect(node, ids):
    if (node.get('type') in ('con', 'floating_con')
            and node.get('id') != EXCLUDE
            and node.get('pid')):
        ids.append(node['id'])
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        collect(child, ids)
    return ids

for wid in collect(json.load(sys.stdin), []):
    subprocess.run(
        ['swaymsg', f'[con_id={wid}] opacity {UNFOCUSED}'],
        capture_output=True
    )
" 2>/dev/null

done
