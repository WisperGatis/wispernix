#!/usr/bin/env python3
"""Render the pixel-art emblem with fastfetch categories in square boxes.

Usage: box.py <logo.txt> <software.jsonc> <fastfetch-binary>

Layout (same as the reference): the category keys (icon + name) sit inside a
square box, their values are printed to the right of the box. The palette
row gets its own small box labelled "colors".

fastfetch's config sets display.separator to U+2063 (an invisible separator),
which lets this script split each line into key and value.
"""
import re
import subprocess
import sys

ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
SEPARATOR_LINE = re.compile(r"^-{3,}$")
KEY_VALUE_MARK = "⁣"
COLORS_LABEL = "\U000f03d8 colors"  # nf-md-palette, matches the reference's palette icon
GAP = 4        # space between the logo and the key box
VALUE_GAP = 2  # space between the key box and the values


def vis(s):
    return len(ANSI.sub("", s))


def dotify(palette_line):
    """Turn fastfetch's background swatches into small colored dots.

    Each swatch is a background-colored block (ESC[4Xm plus spaces); keep its
    color but draw a "●" in the foreground instead, as in the reference.
    """
    return re.sub(r"\x1b\[4([0-7])m +", lambda m: f"\x1b[3{m.group(1)}m● ", palette_line)


def trim_blank(lines):
    # Only drop truly empty lines: the palette row is spaces with background
    # colors, which look blank once ANSI codes are stripped but must be kept.
    while lines and not ANSI.sub("", lines[0]):
        lines = lines[1:]
    while lines and not ANSI.sub("", lines[-1]):
        lines = lines[:-1]
    return lines


def to_items(lines, palette_label=None):
    """Turn raw fastfetch lines into (key, value) pairs; blank lines stay blank."""
    items = []
    labelled = False
    for line in lines:
        if KEY_VALUE_MARK in line:
            key, value = line.split(KEY_VALUE_MARK, 1)
            items.append((key, value))
        elif not ANSI.sub("", line):
            # A true blank line (the fastfetch "break" module).
            items.append(("", ""))
        else:
            # Palette rows have no key. Only the first one gets the label, so
            # the two palette rows share one "colors" entry.
            items.append((palette_label if palette_label and not labelled else "", dotify(line)))
            labelled = True
    return items


def frame_row(content, key_width, value=""):
    pad = " " * (key_width - vis(content))
    return ("│ " + content + pad + " │", value)


def single_box(top_items, bottom_items, key_width):
    """One rounded box holding the keys, a divider, then the palette row.

    Returns (box_part, value_part) pairs; values sit outside the box.
    """
    width = key_width + 2
    rows = [("╭" + "─" * width + "╮", "")]
    rows += [frame_row(key, key_width, value) for key, value in top_items]
    if bottom_items:
        rows.append(("├" + "─" * width + "┤", ""))
        rows += [frame_row(key, key_width, value) for key, value in bottom_items]
    rows.append(("╰" + "─" * width + "╯", ""))
    return rows


def main():
    logo_path, cfg, ff = sys.argv[1], sys.argv[2], sys.argv[3]

    raw = subprocess.run(
        [ff, "-c", cfg, "--pipe", "false"],
        capture_output=True, text=True, check=True,
    ).stdout.splitlines()

    sep = next((i for i, l in enumerate(raw) if SEPARATOR_LINE.match(ANSI.sub("", l).strip())), None)
    if sep is None:
        top, bottom = raw, []
    else:
        top, bottom = raw[:sep], raw[sep + 1:]
    top = trim_blank(top)
    bottom = trim_blank(bottom)

    # Blank lines are not drawn inside the box, so the rows stay packed.
    top_items = [i for i in to_items(top) if i != ("", "")]
    # fastfetch prints the palette as two rows (normal and bright); the
    # reference shows one row of dots, so only the first row is used.
    bottom_items = [i for i in to_items(bottom, palette_label=COLORS_LABEL) if i != ("", "")][:1]

    key_width = max([vis(k) for k, _ in top_items + bottom_items if k] or [0])

    rows = single_box(top_items, bottom_items, key_width)

    with open(logo_path, encoding="utf-8") as f:
        logo = f.read().rstrip("\n").split("\n")
    logo_w = max(vis(l) for l in logo)

    out = []
    for i in range(max(len(logo), len(rows))):
        left = logo[i] if i < len(logo) else ""
        box, value = rows[i] if i < len(rows) else ("", "")
        line = left + " " * (logo_w - vis(left))
        if box:
            line += " " * GAP + box
        if value:
            line += " " * VALUE_GAP + value
        out.append(line)
    print("\n".join(out) + "\x1b[0m")


if __name__ == "__main__":
    main()
