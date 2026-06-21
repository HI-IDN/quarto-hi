# quarto-hi

A [Quarto](https://quarto.org/) RevealJS presentation template following the [Háskóli Íslands (University of Iceland)](https://honnun.hi.is) visual identity guidelines.

## Use this template

```bash
quarto use template tungufoss/quarto-hi
```

Or clone manually:

```bash
git clone git@github.com:tungufoss/quarto-hi.git
```

## What's included

| Path | Purpose |
|---|---|
| `styles/colors.css` | HI colour palette and CSS variables |
| `styles/hi26-reveal.css` | Core layout, typography, card components |
| `styles/cdio2026.css` | Presentation-specific overrides (fa-cards, h2 accent) |
| `_extensions/hi-title/` | Custom title slide Lua filter |
| `_extensions/card-enum/` | `{.fa-card}` card grid shortcode |
| `_extensions/pause/` | Pause shortcode for speaker pacing |
| `partials/` | HTML includes (fonts, Font Awesome, favicon, countdown) |
| `scripts/countdown.js` | Countdown timer for in-slide clocks |
| `img/hi/` | HI logos and favicon (SVG) |
| `template.qmd` | Starter slide deck |

## Card syntax

```markdown
::: {.fa-card cols=2}
- lightbulb | **Key idea** | supporting text
- chart-line | **Another** | more detail
:::
```

Icons are [Font Awesome 6](https://fontawesome.com/icons) names (without the `fa-` prefix).

## Colour palette

Defined as CSS variables in `styles/colors.css`, matching [honnun.hi.is](https://honnun.hi.is):

- `--primary` / `--blue`: `#10099F`
- `--teal`: `#2DD2C0`
- `--secondary`: `#D61F69`
- `--yellow`: `#FAC55B`
- `--orange`: `#FFA05F`
- `--red`: `#FC8484`

## Font

[Jost](https://fonts.google.com/specimen/Jost) loaded from Google Fonts via `partials/header-includes.inc`.
