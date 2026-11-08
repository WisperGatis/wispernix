#!/usr/bin/env python3
"""Build and list cached Rofi thumbnails without blocking the wallpaper menu."""
import hashlib
import os
from pathlib import Path
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

from PIL import Image, ImageOps

WALLPAPERS = Path(sys.argv[2]).expanduser()
CACHE = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "wallpaper-menu"
EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def images():
    try:
        return sorted((p for p in WALLPAPERS.iterdir() if p.is_file() and p.suffix.lower() in EXTENSIONS),
                      key=lambda p: p.name.lower())
    except OSError:
        return []


def thumbnail(path):
    stat = path.stat()
    key = f"{path.absolute()}\0{stat.st_mtime_ns}\0{stat.st_size}"
    return CACHE / (hashlib.sha256(os.fsencode(key)).hexdigest() + ".png")


def build(path):
    try:
        target = thumbnail(path)
        if target.is_file():
            return
        with Image.open(path) as image:
            image.draft("RGB", (384, 384))
            image = ImageOps.exif_transpose(image)
            image.thumbnail((384, 384), Image.Resampling.LANCZOS)
            # Atomic replacement lets concurrent menus share the cache safely.
            with tempfile.NamedTemporaryFile(dir=CACHE, suffix=".png", delete=False) as tmp:
                temporary = Path(tmp.name)
            try:
                image.save(temporary, format="PNG")
                os.replace(temporary, target)
            finally:
                temporary.unlink(missing_ok=True)
    except (OSError, ValueError, Image.DecompressionBombError):
        pass  # Fall back to the original image in the menu.


def main():
    if sys.argv[1] == "warm":
        CACHE.mkdir(parents=True, exist_ok=True)
        with ThreadPoolExecutor(max_workers=2) as pool:
            list(pool.map(build, images()))
    elif sys.argv[1] == "list":
        for path in images():
            try:
                cached = thumbnail(path)
                icon = cached if cached.is_file() else path
                sys.stdout.buffer.write(os.fsencode(path.name) + b"\0icon\x1f" + os.fsencode(icon) + b"\n")
            except OSError:
                continue


if __name__ == "__main__":
    main()
