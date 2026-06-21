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

## Demo pages

The GitHub Pages demo renders two showcase decks:

- `example-en.qmd` -> `index.html`
- `example-is.qmd` -> `example-is.html`

The starter template copy excludes these showcase files and starts from `template.qmd`.

## What's included

| Path | Purpose |
|---|---|
| `styles/hi.scss` | HI palette, RevealJS theme variables, typography, layouts, and components |
| `styles/watermark.css` | Reusable watermark/background mark using one external SVG mask |
| `_extensions/hi-title/` | Custom title slide Lua filter |
| `_extensions/card-enum/` | `{.fa-card}` card grid shortcode |
| `_extensions/pause/` | Pause shortcode for speaker pacing |
| `_extensions/menti/` | Menti login and embedded question slide helpers |
| `partials/` | HTML includes (fonts, Font Awesome, favicon, countdown) |
| `scripts/countdown.js` | Countdown timer for in-slide clocks |
| `img/hi/` | HI logos and favicon (SVG) |
| `template.qmd` | Starter slide deck |
| `example-en.qmd` | English showcase rendered for the GitHub Pages demo |
| `example-is.qmd` | Icelandic showcase source for users who want an Icelandic deck |

## HI SVG assets

| Path | Purpose |
|---|---|
| `img/hi/favicon.svg` | Browser/tab icon |
| `img/hi/hi_named_logo-en.svg` | English named logo for RevealJS `logo:` |
| `img/hi/hi_named_logo-is.svg` | Icelandic named logo for RevealJS `logo:` |
| `img/hi/hi_logo.svg` | Single standalone logo used for watermark/background decoration |

The watermark/background mark is stored once and recoloured in CSS with `mask-image`.
Do not duplicate the SVG for colour variants; change `--watermark-color` instead.

## Card syntax

```markdown
::: {.fa-card cols=2}
- lightbulb | **Key idea** | supporting text
- chart-line | **Another** | more detail
:::
```

Icons are [Font Awesome 6](https://fontawesome.com/icons) names (without the `fa-` prefix).

## Colour palette

Defined as CSS variables in `styles/hi.scss`, matching [honnun.hi.is](https://honnun.hi.is):

- `--primary` / `--blue`: `#10099F`
- `--teal`: `#2DD2C0`
- `--secondary`: `#D61F69`
- `--yellow`: `#FAC55B`
- `--orange`: `#FFA05F`
- `--red`: `#FC8484`

## Font

[Jost](https://fonts.google.com/specimen/Jost) loaded from Google Fonts via `partials/header-includes.inc`.
