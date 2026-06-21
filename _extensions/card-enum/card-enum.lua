local function has_class(classes, wanted)
  for _, class in ipairs(classes) do
    if class == wanted then
      return true
    end
  end
  return false
end

local function render_blocks(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html"):gsub("%s+$", "")
end

local function html_escape(text)
  text = tostring(text or "")
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  return text
end

-- Render **bold**, _emph_, and `code` in a plain string to HTML
local function md_inline(s)
  local result = {}
  local i = 1
  while i <= #s do
    local b1 = s:find("%*%*", i)
    local e1 = s:find("_", i)
    local c1 = s:find("`", i)
    local k1 = s:find("%[", i)
    -- pick earliest marker
    local next_marker
    if b1 and (not e1 or b1 <= e1) and (not c1 or b1 <= c1) and (not k1 or b1 <= k1) then next_marker = "bold"
    elseif e1 and (not c1 or e1 <= c1) and (not k1 or e1 <= k1) then next_marker = "emph"
    elseif c1 and (not k1 or c1 <= k1) then next_marker = "code"
    elseif k1 then next_marker = "icon" end

    if not next_marker then
      table.insert(result, html_escape(s:sub(i))); break
    end

    if next_marker == "bold" then
      table.insert(result, html_escape(s:sub(i, b1 - 1)))
      local b2 = s:find("%*%*", b1 + 2)
      if b2 then
        table.insert(result, "<strong>" .. html_escape(s:sub(b1 + 2, b2 - 1)) .. "</strong>")
        i = b2 + 2
      else
        table.insert(result, html_escape(s:sub(b1))); break
      end
    elseif next_marker == "emph" then
      table.insert(result, html_escape(s:sub(i, e1 - 1)))
      local e2 = s:find("_", e1 + 1)
      if e2 then
        table.insert(result, '<em class="emph">' .. html_escape(s:sub(e1 + 1, e2 - 1)) .. "</em>")
        i = e2 + 1
      else
        table.insert(result, html_escape(s:sub(e1))); break
      end
    elseif next_marker == "code" then
      table.insert(result, html_escape(s:sub(i, c1 - 1)))
      local c2 = s:find("`", c1 + 1)
      if c2 then
        table.insert(result, "<code>" .. html_escape(s:sub(c1 + 1, c2 - 1)) .. "</code>")
        i = c2 + 1
      else
        table.insert(result, html_escape(s:sub(c1))); break
      end
    else
      -- [icon-name] → FA icon inheriting current text colour
      local _, kend, ic = s:find("%[([%w%-]+)%]", k1)
      if ic then
        table.insert(result, html_escape(s:sub(i, k1 - 1)))
        table.insert(result, '<i class="fa-solid fa-' .. ic .. '" aria-hidden="true"></i>')
        i = kend + 1
      else
        table.insert(result, html_escape(s:sub(i))); break
      end
    end
  end
  return table.concat(result)
end

-- Renders formula text: escapes HTML but expands [icon-name] → FA icon
local function render_formula(s)
  local out = {}
  local i = 1
  while i <= #s do
    local b, e, icon = s:find("%[([%w%-]+)%]", i)
    if b then
      table.insert(out, html_escape(s:sub(i, b - 1)))
      table.insert(out, '<i class="fa-solid fa-' .. icon .. '"></i>')
      i = e + 1
    else
      table.insert(out, html_escape(s:sub(i)))
      break
    end
  end
  return table.concat(out)
end

-- Renders a numbered card (card-enum)
local function item_html(number, blocks)
  return '<div class="enum-card">' ..
    "<h3>" .. tostring(number) .. "</h3>" ..
    '<div class="card-enum-body">' .. render_blocks(blocks) .. "</div>" ..
    "</div>"
end

-- Renders an FA-icon card (fa-card)
-- Expects list item text in the form:  icon-name | Title | Body text | * item1 | * item2 …
-- Optional family prefix:  [brands] spotify | …  or  [regular] heart | …
-- Default family is fa-solid.
local function fa_item_html(_, blocks)
  local text = pandoc.utils.stringify(blocks)

  -- Split on | into all segments
  local segs = {}
  for seg in (text .. "|"):gmatch("([^|]*)|") do
    table.insert(segs, seg:match("^%s*(.-)%s*$"))
  end

  if #segs < 2 then
    return '<div class="card fa-card-item">' ..
      '<div class="fa-card-icon"><i class="fa-solid fa-circle-exclamation fa-fw box-icon"></i></div>' ..
      '<div class="fa-card-body"><h3>Error</h3><p>Use: icon | title | body</p></div>' ..
      "</div>"
  end

  local icon_part = segs[1]
  local title    = #segs >= 3 and segs[2] or ""
  local subtitle = ""
  local body     = #segs >= 3 and segs[3] or segs[2]

  -- Optional subtitle: 4+ segments where seg[3] starts with ~ (pre) or / (post)
  -- Or: 4 segments where seg[3] looks like a subtitle (starts with _ or is short)
  -- Simpler: if 4+ segments and seg[3] starts with "/" treat as subtitle before body
  if #segs >= 4 then
    local maybe_sub = segs[3]
    if maybe_sub:match("^/") then
      subtitle = maybe_sub:sub(2):match("^%s*(.-)%s*$")
      body = segs[4]
    end
  end

  -- Collect any remaining | * item segments as bullet list items
  -- and | ~ text segments as formula lines
  local list_items = {}
  local formula_lines = {}
  local start = (#segs >= 4 and subtitle ~= "") and 5 or (#segs >= 3 and 4 or 3)
  for i = start, #segs do
    local seg = segs[i]
    local bullet  = seg:match("^%*%s*(.+)$") or seg:match("^%-+%s*(.+)$")
    local formula = seg:match("^~%s*(.+)$")
    if bullet and bullet ~= "" then
      table.insert(list_items, "<li>" .. md_inline(bullet) .. "</li>")
    elseif formula and formula ~= "" then
      table.insert(formula_lines, '<p class="card-formula">' .. render_formula(formula) .. "</p>")
    end
  end

  -- Detect optional prefix: [brands]/[regular] = font family, [hi-red] etc = color class
  local family = "fa-solid"
  local color_class = ""
  local icon = icon_part
  local prefix, rest = icon:match("^%[([^%]]+)%]%s*(.+)$")
  if prefix then
    if prefix:match("^hi%-") then
      color_class = prefix   -- e.g. "hi-red", "hi-pink", "hi-teal"
    else
      family = "fa-" .. prefix
    end
    icon = rest
  end
  icon = icon:gsub("^fa%-%a+%s+", ""):gsub("^fa%-", ""):gsub("%s+$", "")

  local list_html = #list_items > 0
    and '<ul class="fa-card-list">' .. table.concat(list_items) .. "</ul>"
    or ""
  local formula_html = table.concat(formula_lines)

  local sub_html = subtitle ~= "" and ('<p class="fa-card-subtitle">' .. md_inline(subtitle) .. "</p>") or ""
  local body_html
  if title == "" then
    body_html = '<div class="fa-card-body fa-card-body--centred"><p>' .. md_inline(body) .. "</p>" .. list_html .. formula_html .. "</div>"
  else
    local p = body ~= "" and ("<p>" .. md_inline(body) .. "</p>") or ""
    body_html = '<div class="fa-card-body"><h3>' .. md_inline(title) .. "</h3>" .. sub_html .. p .. list_html .. formula_html .. "</div>"
  end

  local item_class = color_class ~= "" and ("fa-card-item " .. color_class) or "fa-card-item"
  return '<div class="' .. item_class .. '">' ..
    '<div class="fa-card-icon"><i class="' .. family .. ' fa-' .. html_escape(icon) .. ' fa-fw box-icon"></i></div>' ..
    body_html ..
    "</div>"
end

-- Wraps a list of rendered item strings into a row div
local function row_html(items, row_class)
  if #items == 0 then return "" end
  return '<div class="' .. row_class .. '" style="--card-enum-cols: ' .. tostring(#items) .. ';">' ..
    table.concat(items, "\n") ..
    "</div>"
end

-- Collects all list items from a div's content, then chunks them into
-- rows of `cols` items.  HorizontalRule blocks are ignored (they are
-- produced by `---` which Quarto revealjs treats as a slide break, so
-- they never arrive at this filter reliably).
local function render_card_rows(div, item_renderer, wrapper_class, row_class)
  -- Allow per-block column override via  ::: {.card-enum cols=4}
  local cols = tonumber(div.attributes and div.attributes["cols"]) or 3

  -- Pass through any extra classes on the div (e.g. .colorful)
  local extra = {}
  for _, cls in ipairs(div.classes) do
    if cls ~= wrapper_class then
      table.insert(extra, cls)
    end
  end
  local all_classes = #extra > 0 and (wrapper_class .. " " .. table.concat(extra, " ")) or wrapper_class

  -- Collect every rendered item in order
  local all_items = {}
  local number = 1

  for _, block in ipairs(div.content) do
    if block.t == "OrderedList" or block.t == "BulletList" then
      for _, item in ipairs(block.content) do
        table.insert(all_items, item_renderer(number, item))
        number = number + 1
      end
    elseif block.t ~= "Null" and block.t ~= "HorizontalRule" then
      table.insert(all_items, item_renderer(number, { block }))
      number = number + 1
    end
    -- HorizontalRule is silently skipped
  end

  -- Chunk into rows
  local rows = {}
  local i = 1
  while i <= #all_items do
    local row = {}
    for j = i, math.min(i + cols - 1, #all_items) do
      table.insert(row, all_items[j])
    end
    table.insert(rows, row_html(row, row_class))
    i = i + cols
  end

  return pandoc.RawBlock("html",
    '<div class="' .. all_classes .. '">' .. table.concat(rows, "\n") .. "</div>")
end

-- Splits a list of inlines at the first bare "|" Str token
local function split_inlines_at_pipe(inlines)
  local left, right = {}, {}
  local found = false
  for _, inline in ipairs(inlines) do
    if not found and inline.t == "Str" and inline.text == "|" then
      found = true
    elseif not found then
      table.insert(left, inline)
    else
      table.insert(right, inline)
    end
  end
  return left, right, found
end

-- Renders a list of inlines to HTML, stripping the <p> wrapper Para adds.
-- Uses pandoc.write (same as render_blocks) so formatting is always correct.
local function inlines_to_html(inlines)
  if #inlines == 0 then return "" end
  local html = pandoc.write(pandoc.Pandoc({ pandoc.Para(inlines) }), "html")
  html = html:gsub("%s+$", "")           -- trim trailing whitespace/newlines
  html = html:gsub("^<p>", "")           -- strip opening <p>
  html = html:gsub("</p>$", "")          -- strip closing </p>
  return html
end

-- Trim leading/trailing Space inlines
local function trim_spaces(inlines)
  while #inlines > 0 and (inlines[1].t == "Space" or inlines[1].t == "SoftBreak") do
    table.remove(inlines, 1)
  end
  while #inlines > 0 and (inlines[#inlines].t == "Space" or inlines[#inlines].t == "SoftBreak") do
    table.remove(inlines, #inlines)
  end
  return inlines
end

-- Renders one opposing-arrow row from a list item
local function oppose_row_html(_, blocks)
  for _, block in ipairs(blocks) do
    if block.t == "Para" or block.t == "Plain" then
      local left_inl, right_inl, found = split_inlines_at_pipe(block.content)
      if found then
        local left_html  = inlines_to_html(trim_spaces(left_inl))
        local right_html = inlines_to_html(trim_spaces(right_inl))
        return '<div class="oppose-row">' ..
          '<div class="oppose-arrow oppose-arrow--right">' .. left_html  .. '</div>' ..
          '<div class="oppose-dot"></div>' ..
          '<div class="oppose-arrow oppose-arrow--left">'  .. right_html .. '</div>' ..
          '</div>'
      end
    end
  end
  -- fallback: full text left, empty right
  local text = pandoc.utils.stringify(blocks)
  return '<div class="oppose-row">' ..
    '<div class="oppose-arrow oppose-arrow--right">' .. html_escape(text) .. '</div>' ..
    '<div class="oppose-dot"></div>' ..
    '<div class="oppose-arrow oppose-arrow--left"></div>' ..
    '</div>'
end

-- Renders a chevron step (for .steps diagrams)
local function step_chip_html(index, blocks)
  local text = pandoc.utils.stringify(blocks)
  local label, desc = text:match("^%s*([^|]+)%s*|%s*(.+)%s*$")
  if not label then
    label = text:gsub("^%s+", ""):gsub("%s+$", "")
    desc = nil
  end
  label = label:gsub("%s+$", "")
  local inner = "<strong>" .. html_escape(label) .. "</strong>"
  if desc then
    inner = inner .. "<span>" .. html_escape(desc:gsub("%s+$", "")) .. "</span>"
  end
  return '<div class="step-chip" data-step="' .. tostring(index) .. '">' .. inner .. "</div>"
end

function Div(div)
  if has_class(div.classes, "card-enum") then
    return render_card_rows(div, item_html, "card-enum", "card-enum-row")
  end

  if has_class(div.classes, "fa-card") then
    return render_card_rows(div, fa_item_html, "fa-card", "fa-card-row")
  end

  if has_class(div.classes, "steps") then
    local chips = {}
    local i = 1
    for _, block in ipairs(div.content) do
      if block.t == "BulletList" or block.t == "OrderedList" then
        for _, item in ipairs(block.content) do
          table.insert(chips, step_chip_html(i, item))
          i = i + 1
        end
      elseif block.t ~= "Null" and block.t ~= "HorizontalRule" then
        table.insert(chips, step_chip_html(i, { block }))
        i = i + 1
      end
    end
    return pandoc.RawBlock("html",
      '<div class="steps-row" style="--steps-count: ' .. tostring(#chips) .. ';">' ..
      table.concat(chips, "") .. "</div>")
  end

  if has_class(div.classes, "oppose") then
    local left_label  = (div.attributes and div.attributes["left"])       or "A"
    local right_label = (div.attributes and div.attributes["right"])      or "B"
    local left_icon   = div.attributes and div.attributes["left-icon"]
    local right_icon  = div.attributes and div.attributes["right-icon"]

    local li = left_icon  and ('<i class="fa-solid fa-' .. left_icon  .. ' fa-fw"></i> ') or ""
    local ri = right_icon and (' <i class="fa-solid fa-' .. right_icon .. ' fa-fw"></i>') or ""

    local header = '<div class="oppose-header">' ..
      '<div class="oppose-head oppose-head--right">' .. li .. html_escape(left_label)  .. '</div>' ..
      '<div class="oppose-head oppose-head--center">VS</div>' ..
      '<div class="oppose-head oppose-head--left">'  .. html_escape(right_label) .. ri .. '</div>' ..
      '</div>'

    local rows = {}
    for _, block in ipairs(div.content) do
      if block.t == "BulletList" or block.t == "OrderedList" then
        for _, item in ipairs(block.content) do
          table.insert(rows, oppose_row_html(nil, item))
        end
      end
    end

    return pandoc.RawBlock("html",
      '<div class="oppose-diagram">' .. header .. table.concat(rows, "\n") .. '</div>')
  end

  return nil
end
