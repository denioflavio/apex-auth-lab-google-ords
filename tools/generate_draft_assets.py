from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Tuple

from PIL import Image, ImageDraw, ImageFilter


Rect = Tuple[int, int, int, int]

ROOT = Path(__file__).resolve().parent.parent
PRINTS_DIR = ROOT / "prints"
ASSETS_DIR = ROOT / "draft_assets"


@dataclass
class ShotSpec:
    source: str
    target: str
    crop: Rect
    blur_rects: List[Rect] = field(default_factory=list)
    box_rects: List[Rect] = field(default_factory=list)


BOX_COLOR = (119, 36, 50, 255)
BOX_WIDTH = 3


SPECS: List[ShotSpec] = [
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.23.09.png",
        target="01-google-audience.png",
        crop=(170, 110, 1560, 1040),
        blur_rects=[(190, 812, 525, 900)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.24.31.png",
        target="02-google-scopes.png",
        crop=(170, 110, 1870, 1045),
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.29.54.png",
        target="03-google-redirect-uri.png",
        crop=(140, 110, 1735, 940),
        blur_rects=[(140, 690, 620, 760)],
        box_rects=[(130, 635, 635, 770)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.30.58.png",
        target="04-google-client-created.png",
        crop=(500, 160, 1225, 935),
        blur_rects=[
            (415, 256, 680, 392),
            (415, 452, 680, 518),
        ],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.57.48.png",
        target="05-apex-app-pages.png",
        crop=(25, 120, 1875, 935),
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.50.38.png",
        target="06-apex-social-signin-mapping.png",
        crop=(165, 230, 980, 870),
        box_rects=[
            (175, 350, 780, 610),
            (175, 615, 780, 715),
        ],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.38.42.png",
        target="07-apex-post-login-hook.png",
        crop=(165, 155, 1110, 745),
        box_rects=[(190, 185, 700, 355)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.58.01.png",
        target="08-apex-router-page.png",
        crop=(0, 120, 1920, 980),
        box_rects=[(15, 170, 260, 465)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 12.58.57.png",
        target="09-apex-registration-process.png",
        crop=(0, 120, 1885, 975),
        box_rects=[
            (18, 165, 250, 690),
            (1185, 170, 1790, 770),
        ],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.10.27.png",
        target="10-ords-module.png",
        crop=(285, 145, 1845, 975),
        blur_rects=[(145, 188, 795, 260)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.10.52.png",
        target="11-ords-handler.png",
        crop=(285, 145, 1825, 980),
        blur_rects=[(145, 188, 845, 260)],
        box_rects=[(115, 500, 1450, 835)],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.11.06.png",
        target="12-ords-privilege.png",
        crop=(285, 145, 1860, 980),
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.13.21.png",
        target="13-app-users-table.png",
        crop=(200, 140, 1680, 920),
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.16.39.png",
        target="14-postman-me.png",
        crop=(340, 70, 1470, 900),
        blur_rects=[
            (95, 455, 830, 708),
        ],
    ),
    ShotSpec(
        source="Screenshot 2026-04-19 at 13.16.57.png",
        target="15-postman-runtime-diagnostics.png",
        crop=(340, 70, 1470, 900),
        blur_rects=[
            (100, 452, 760, 650),
        ],
    ),
]


def blur_region(image: Image.Image, rect: Rect) -> None:
    region = image.crop(rect)
    region = region.filter(ImageFilter.GaussianBlur(radius=10))
    image.paste(region, rect)


def draw_box(draw: ImageDraw.ImageDraw, rect: Rect) -> None:
    draw.rounded_rectangle(rect, radius=10, outline=BOX_COLOR, width=BOX_WIDTH)


def annotate(spec: ShotSpec) -> None:
    source_path = PRINTS_DIR / spec.source
    target_path = ASSETS_DIR / spec.target
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)

    image = Image.open(source_path).convert("RGBA").crop(spec.crop)

    for rect in spec.blur_rects:
        blur_region(image, rect)

    if spec.box_rects:
        overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        for rect in spec.box_rects:
            draw_box(draw, rect)
        image = Image.alpha_composite(image, overlay)

    image.convert("RGB").save(target_path, quality=94)


def main() -> None:
    for spec in SPECS:
        annotate(spec)
        print(f"generated {spec.target}")


if __name__ == "__main__":
    main()
