#!/usr/bin/env python3
"""Render the pixel-art emblem with fastfetch specs inside rounded boxes.

Usage: box.py <logo.txt> <software.jsonc> <fastfetch-binary>

fastfetch prints the specs with its own colors and icons; this script frames
them. The line produced by the `separator` module splits the output into two
boxes: the specs on top, the palette row below (same layout as the reference).
"""
import re
import subprocess
import sys

ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
SEPARATOR = re.compile(r"^-{3,}$")
GAP = 4


def vis(s):
    return len(ANSI.sub("", s))


def trim_blank(lines):
    # Only drop truly empty lines: the palette row is spaces with background
    # colors, which look blank once ANSI codes are stripped but must be kept.
    while lines and not ANSI.sub("", lines[0]):
        lines = lines[1:]
    while lines and not ANSI.sub("", lines[-1]):
        lines = lines[:-1]
    return lines


def main():
    logo_path, cfg, ff = sys.argv[1], sys.argv[2], sys.argv[3]

    raw = subprocess.run(
        [ff, "-c", cfg, "--pipe", "false"],
        capture_output=True, text=True, check=True,
    ).stdout.splitlines()

    sep = next((i for i, l in enumerate(raw) if SEPARATOR.match(ANSI.sub("", l).strip())), None)
    if sep is None:
        top, bottom = raw, []
    else:
        top, bottom = raw[:sep], raw[sep + 1:]
    top, bottom = trim_blank(top), trim_blank(bottom)

    inner = max([vis(l) for l in top + bottom] or [0])
    width = inner + 2  # one space of padding on each side of the content

    def row(content):
        return "│ " + content + " " * (inner - vis(content)) + " │"

    box = ["╭" + "─" * (width) + "╮"]
    box += [row(l) for l in top]
    if bottom:
        box.append("├" + "─" * width + "┤")
        box += [row(l) for l in bottom]
    box.append("╰" + "─" * width + "╯")

    with open(logo_path, encoding="utf-8") as f:
        logo = f.read().rstrip("\n").split("\n")
    logo_w = max(vis(l) for l in logo)

    rows = max(len(logo), len(box))
    out = []
    for i in range(rows):
        left = logo[i] if i < len(logo) else ""
        right = box[i] if i < len(box) else ""
        left_pad = " " * (logo_w - vis(left))
        out.append(left + left_pad + " " * GAP + right if right else left)
    print("\n".join(out) + "\x1b[0m")


if __name__ == "__main__":
    main()
