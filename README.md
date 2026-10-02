# quarto-hi

A [Quarto](https://quarto.org/) RevealJS presentation template following the [Háskóli Íslands (University of Iceland)](https://honnun.hi.is) visual identity guidelines.

The HI-IDN starter template: `template.qmd` is a ready deck with HÍ logos, watermark and a VR-II contact slide; fill in your details in the YAML. For a personal version, fork this repo and put your details in the fork. The look comes from the shared [HÍ Quarto theme](https://github.com/tungufoss/quarto-haskoli-islands-theme/releases/tag/v0.2.0) v0.2.0.

## Use this template

```bash
quarto use template HI-IDN/quarto-hi
```

Or clone manually:

```bash
git clone git@github.com:HI-IDN/quarto-hi.git
```

## Demo pages

The GitHub Pages demo renders two showcase decks, the article template and a book example:

- `slides/en/index.qmd` -> `slides/en/`
- `slides/is/index.qmd` -> `slides/is/`
- `article.qmd` -> `article.html` (HTML article template)
- `book/` -> `book/index.html` (Quarto book example)

The starter template copy excludes the showcase decks and the book example, and starts from `template.qmd` (slides) and `article.qmd` (article).

## What's included

| Path | Purpose |
|---|---|
| `_extensions/tungufoss/haskoli-islands/` | The [HÍ Quarto theme](https://github.com/tungufoss/quarto-haskoli-islands-theme/releases/tag/v0.2.0) v0.2.0: styles, title slide, contact card, cards, pause and Menti. Update with `quarto update extension tungufoss/quarto-haskoli-islands-theme` |
| `img/` | HÍ logos, watermark, favicon and the VR-II photo used by this template |
| `img/hi/` | HI logos and favicon (SVG) |
| `template.qmd` | Starter slide deck |
| `article.qmd` | Starter HTML article (Icelandic), see [Article template](#article-template) |
| `article.bib`, `apa.csl` | Example bibliography and APA style using "og" between authors |
| `styles/article.css`, `styles/article-meta.html` | Article look: theme pills, ORCID icon, publication note, photo credit |
| `book/` | Quarto book example in the same look (demo only) |
| `scripts/render-book.ts` | Post-render step that renders `book/` into `_site/book` |
| `slides/en/index.qmd` | English showcase deck for the GitHub Pages demo |
| `slides/is/index.qmd` | Icelandic showcase deck (sýnishorn) |

## HI SVG assets

| Path | Purpose |
|---|---|
| `img/hi/favicon.svg` | Browser/tab icon |
| `img/hi/hi_named_logo-en.svg` | English named logo for RevealJS `logo:` |
| `img/hi/hi_named_logo-is.svg` | Icelandic named logo for RevealJS `logo:` |
| `img/hi/hi_logo.svg` | Single standalone logo used for watermark/background decoration |

The watermark/background mark is stored once and recoloured in CSS with `mask-image`.
Do not duplicate the SVG for colour variants; change `--watermark-color` instead.

## Article template

`article.qmd` is an HTML article in the `haskoli-islands-html` format, for papers and other long-form text rather than slides. Fill in the YAML and replace the body. It adds:

- `categories` shown as pills under **Þema** in the title block, next to **Birt**
- the author's `orcid` as a Font Awesome icon in ORCID green
- a `.pub-note` block in HÍ colours for "Greinin birtist í …"
- an `.author-photo` block with a right-aligned photo credit
- `citation` metadata, so Quarto adds a "Vinsamlega vitnið í þetta verk sem:" box with BibTeX
- `other-links` for a link to the published PDF under **Önnur snið**

```yaml
categories:
  - Fræðimennska náms og kennslu
  - Námskeiðshönnun
author:
  - name: "Nafnið þitt"
    orcid: "0000-0000-0000-0000"
    affiliation: "Deild, Háskóli Íslands"
```

Example in use: [Viðskiptagreind sem brú milli náms og starfs](https://tungufoss.github.io/sotl-vidskiptagreind/).

## Book example

`book/` is a Quarto book (`project: type: book`) in the `haskoli-islands-html` format, with chapters, a figure, a table and references. A book is its own Quarto project, so it is rendered by `scripts/render-book.ts` after the main site (`post-render` in `_quarto.yml`). The script copies `_extensions/`, `img/hi/`, `styles/`, `article.bib` and `apa.csl` into `book/` (gitignored), so the repo keeps one copy of the theme.

To start your own book, copy `book/` into a new repo together with `_extensions/`, `img/hi/`, `styles/article.css`, `article.bib` and `apa.csl` (all inside the book folder), then run `quarto render`.

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

It creates a contact block for each entry in `presenters`, so you can include one or more presenters:

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
