# quarto-hi

A [Quarto](https://quarto.org/) RevealJS presentation template following the [Háskóli Íslands (University of Iceland)](https://honnun.hi.is) visual identity guidelines.

This is Helga Ingimundardóttir's personal starter: `template.qmd` is pre-filled with her details and ends with the VR-II contact slide. The look comes from the shared [HÍ Quarto theme](https://github.com/tungufoss/quarto-haskoli-islands-theme/releases/tag/v0.2.0) v0.2.0.

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
| `_extensions/tungufoss/haskoli-islands/` | The [HÍ Quarto theme](https://github.com/tungufoss/quarto-haskoli-islands-theme/releases/tag/v0.2.0) v0.2.0: styles, title slide, contact card, cards, pause and Menti. Update with `quarto update extension tungufoss/quarto-haskoli-islands-theme` |
| `img/` | HÍ logos, watermark, favicon and the VR-II photo used by this template |
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

## Contact card

Use the metadata-driven contact card shortcode on a slide:

```markdown
{{< contact-card >}}
```

It uses the first entry in `presenters`:

```yaml
presenters:
  - name: "Your Name"
    hi-username: "username"
    email: "optional.override@hi.is"
    office: "Optional office"
    affiliation: "University of Iceland"
    orcid: "0000-0000-0000-0000"
    github: "yourusername"
```

If `email` is omitted, the card derives `username@hi.is` from `hi-username`.

## Colour palette

Defined as CSS variables in the theme extension, matching [honnun.hi.is](https://honnun.hi.is):

- `--primary` / `--blue`: `#10099F`
- `--teal`: `#2DD2C0`
- `--secondary`: `#D61F69`
- `--yellow`: `#FAC55B`
- `--orange`: `#FFA05F`
- `--red`: `#FC8484`

## Font

[Jost](https://fonts.google.com/specimen/Jost) loaded from Google Fonts by the theme extension.
