#!/usr/bin/env python3
"""Render terminal text output into a PNG image."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def load_font(size: int) -> ImageFont.ImageFont:
    font_candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "C:/Windows/Fonts/consola.ttf",
        "C:/Windows/Fonts/lucon.ttf",
    ]
    for candidate in font_candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


def render(text: str, title: str, output: Path, font_size: int) -> None:
    font = load_font(font_size)
    title_font = load_font(font_size + 4)
    lines = text.splitlines() or [""]

    left_pad = 36
    top_pad = 32
    line_gap = 8

    dummy = Image.new("RGB", (1, 1))
    draw = ImageDraw.Draw(dummy)

    title_box = draw.textbbox((0, 0), title, font=title_font)
    line_boxes = [draw.textbbox((0, 0), line, font=font) for line in lines]

    content_width = max((box[2] - box[0]) for box in line_boxes) if line_boxes else 0
    content_height = sum((box[3] - box[1]) + line_gap for box in line_boxes)

    width = max(1200, left_pad * 2 + content_width)
    height = max(700, top_pad * 2 + 64 + content_height)

    image = Image.new("RGB", (width, height), "#0b1020")
    draw = ImageDraw.Draw(image)

    draw.rounded_rectangle((16, 16, width - 16, height - 16), radius=18, fill="#111827", outline="#334155", width=2)
    draw.text((left_pad, top_pad), title, font=title_font, fill="#e2e8f0")
    draw.line((left_pad, top_pad + 42, width - left_pad, top_pad + 42), fill="#334155", width=2)

    y = top_pad + 62
    for line in lines:
        draw.text((left_pad, y), line, font=font, fill="#d1fae5")
        box = draw.textbbox((0, 0), line, font=font)
        y += (box[3] - box[1]) + line_gap

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="Path to the text file to render")
    parser.add_argument("output", help="Path to the PNG image to create")
    parser.add_argument("--title", default="PES-VCS Terminal Capture", help="Title to show above the capture")
    parser.add_argument("--font-size", type=int, default=20, help="Monospace font size")
    args = parser.parse_args()

    text = Path(args.input).read_text(encoding="utf-8")
    render(text, args.title, Path(args.output), args.font_size)


if __name__ == "__main__":
    main()
