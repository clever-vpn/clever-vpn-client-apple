#!/usr/bin/env python3
"""Generate a DMG background image with an arrow hint (stdlib only, no PIL needed).

Creates a 600x400 PNG with:
  - Dark background with a subtle radial gradient
  - A white dashed arrow from left (app icon) to right (Applications folder)
  - "Drag to Applications" hint text area
"""
import struct
import zlib
import sys
import os
import math

WIDTH, HEIGHT = 600, 400
OUTPUT = sys.argv[1] if len(sys.argv) > 1 else "dmg-background.png"


def create_png(width, height):
    """Create a PNG with DMG installer background and arrow hint."""
    cx, cy = width / 2, height / 2

    raw = b""
    for y in range(height):
        raw += b"\x00"  # filter none
        for x in range(width):
            # macOS-style light background with subtle vignette
            dx = (x - cx) / (width * 0.7)
            dy = (y - cy) / (height * 0.7)
            dist = math.sqrt(dx * dx + dy * dy)
            v = max(0, min(1, 1.0 - dist * 0.3))
            base = int(220 + v * 30)  # light gray ~220-250

            r = g = b = base
            a = 255

            # Dashed arrow from app icon area to Applications symlink area
            arrow_y = 195
            arrow_start = 220
            arrow_end = 350
            arrow_thickness = 2
            arrow_color = 120  # medium gray

            # Horizontal dashed line
            if arrow_y - arrow_thickness <= y <= arrow_y + arrow_thickness:
                if arrow_start <= x <= arrow_end:
                    seg = (x - arrow_start) % 14
                    if seg < 8:
                        r = g = b = arrow_color

            # Arrowhead (triangle pointing right)
            arrow_head_x = arrow_end
            head_size = 12
            if arrow_head_x - head_size <= x <= arrow_head_x:
                dy_ah = abs(y - arrow_y)
                max_dy_at_x = int(head_size * (x - (arrow_head_x - head_size)) / head_size)
                if dy_ah <= max_dy_at_x:
                    r = g = b = arrow_color

            raw += struct.pack("BBBB", r, g, b, a)

    def chunk(chunk_type, data):
        c = chunk_type + data
        crc = struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        return struct.pack(">I", len(data)) + c + crc

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr_data = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    ihdr = chunk(b"IHDR", ihdr_data)
    compressed = zlib.compress(raw)
    idat = chunk(b"IDAT", compressed)
    iend = chunk(b"IEND", b"")

    return sig + ihdr + idat + iend


if __name__ == "__main__":
    out_dir = os.path.dirname(OUTPUT)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    png_data = create_png(WIDTH, HEIGHT)
    with open(OUTPUT, "wb") as f:
        f.write(png_data)
    print(f"Created DMG background: {OUTPUT} ({len(png_data)} bytes, {WIDTH}x{HEIGHT})")
