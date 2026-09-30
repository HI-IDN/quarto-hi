-- Page-level extras for haskoli-islands-revealjs:
--   * countdown script for {{< pause >}} slides
--   * hides footer and logo inside the speaker-notes view
--   * `watermark: img/hi/hi_logo.svg` and `favicon: img/hi/favicon.svg`
--     (HÍ brand files are not bundled; each deck points to its own copy)

local function str(v)
  if v == nil then return nil end
  local s = pandoc.utils.stringify(v)
  if s == "" then return nil end
  return s
end

local function resolve(path)
  if pandoc.path.is_absolute(path) then return path end
  return pandoc.path.join({ pandoc.path.directory(quarto.doc.input_file), path })
end

-- Embed as a data URI so the image works wherever the HTML is written
-- (e.g. an output-dir such as docs/)
local function data_uri(path)
  local f = io.open(resolve(path), "rb")
  if not f then
    quarto.log.warning("haskoli-islands: cannot read " .. path)
    return nil
  end
  local bytes = f:read("a")
  f:close()
  local mime = path:match("%.svg$") and "image/svg+xml" or
    (path:match("%.png$") and "image/png" or "image/jpeg")
  return "data:" .. mime .. ";base64," .. quarto.base64.encode(bytes)
end

function Meta(meta)
  if not quarto.doc.is_format("revealjs") then return nil end

  quarto.doc.add_html_dependency({
    name = "haskoli-islands-countdown",
    version = "1.0.0",
    scripts = { { path = "countdown.js", afterBody = true } },
  })

  quarto.doc.include_text("in-header", [[
<script>
// Hide footer/logo in the RevealJS speaker-notes receiver iframe
if (window.location.search.includes('receiver') || window.location.hash.includes('receiver')) {
  document.documentElement.classList.add('speaker-receiver');
}
</script>]])

  local favicon = str(meta["favicon"])
  if favicon then
    quarto.doc.include_text("in-header",
      '<link rel="icon" href="' .. favicon .. '"' ..
      (favicon:match("%.svg$") and ' type="image/svg+xml"' or "") .. '>')
  end

  local watermark = str(meta["watermark"])
  if watermark then
    local uri = data_uri(watermark)
    if uri then
      quarto.doc.include_text("in-header",
        '<style>.reveal .slide-background { --watermark-image: url("' .. uri ..
        '"); --watermark-content: ""; }</style>')
    end
  end
end
