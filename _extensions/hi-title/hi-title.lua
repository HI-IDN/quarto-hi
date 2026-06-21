local function stringify(value)
  if value == nil then
    return ""
  end
  return pandoc.utils.stringify(value)
end

local function meta_to_html(value)
  if value == nil then return "" end
  local doc = pandoc.Pandoc({pandoc.Plain(value)})
  local html = pandoc.write(doc, "html")
  html = html:gsub("^%s*<p>", ""):gsub("</p>%s*$", ""):gsub("\n", "")
  return html
end

local function metadata_value(meta, key)
  if meta then
    return meta[key]
  end
  return nil
end

local function html_escape(value)
  local text = stringify(value)
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  text = text:gsub('"', "&quot;")
  return text
end

local function document_lang(meta)
  local lang = stringify(metadata_value(meta, "lang")):lower()
  if lang == "" then
    return "is"
  end
  return lang
end

local function hi_profile_path(meta)
  if document_lang(meta):sub(1, 2) == "is" then
    return "starfsfolk"
  end
  return "staff"
end

local function presenter_html(meta, presenter)
  local name = html_escape(presenter.name)
  local username = stringify(presenter["hi-username"])
  local orcid = stringify(presenter.orcid)
  local github = stringify(presenter.github)

  if name == "" then
    return ""
  end

  local name_html = "<strong>" .. name .. "</strong>"
  if username ~= "" then
    local safe_username = html_escape(username)
    name_html = '<a href="https://hi.is/' .. hi_profile_path(meta) .. "/" .. safe_username .. '" target="_blank" rel="noopener noreferrer">' ..
      name_html .. "</a>"
  end

  local links = {}
  if orcid ~= "" then
    local safe_orcid = html_escape(orcid)
    table.insert(
      links,
      '<a class="title-meta-icon" href="https://orcid.org/' .. safe_orcid .. '" target="_blank" rel="noopener noreferrer" aria-label="ORCID">' ..
      '<i class="fa-brands fa-orcid" aria-hidden="true"></i></a>'
    )
  end

  if github ~= "" then
    local safe_github = html_escape(github:gsub("^@", ""))
    table.insert(
      links,
      '<a class="title-meta-icon" href="https://github.com/users/' .. safe_github .. '/" target="_blank" rel="noopener noreferrer" aria-label="GitHub">' ..
      '<i class="fa-brands fa-github" aria-hidden="true"></i></a>'
    )
  end

  if username == "" then
    return name_html .. table.concat(links, "")
  end

  local safe_username = html_escape(username)
  local email = safe_username .. "@hi.is"

  return name_html .. table.concat(links, "") .. " " ..
    '<a class="title-meta-email" href="mailto:' .. email .. '">' ..
    '<i class="fa-solid fa-envelope" aria-hidden="true"></i> ' .. email .. "</a>"
end

local function presenters_html(meta)
  local presenters = metadata_value(meta, "presenters")
  if type(presenters) ~= "table" then
    return ""
  end

  local parts = {}
  for _, presenter in ipairs(presenters) do
    local item = presenter_html(meta, presenter)
    if item ~= "" then
      table.insert(parts, item)
    end
  end

  return table.concat(parts, "<br>\n")
end

local function icelandic_today()
  local months = {
    "janúar",
    "febrúar",
    "mars",
    "apríl",
    "maí",
    "júní",
    "júlí",
    "ágúst",
    "september",
    "október",
    "nóvember",
    "desember"
  }
  local now = os.date("*t")
  return string.format("%d. %s %d", now.day, months[now.month], now.year)
end

return {
  ["hi-title"] = function(args, kwargs, meta)
    local event_meta = meta_to_html(metadata_value(meta, "event-meta"))
    local date = meta_to_html(metadata_value(meta, "event-date"))
    if date == "" then
      date = icelandic_today()
    end
    local event_line = event_meta

    if event_meta ~= "" and date ~= "" then
      event_line = event_meta .. " · " .. date
    elseif date ~= "" then
      event_line = date
    end

    local subtitle_pos = stringify(metadata_value(meta, "subtitle-position"))
    local extra_class = ""
    if subtitle_pos == "below" then
      extra_class = " subtitle-below"
    end

    return {
      pandoc.Header(
        2,
        {},
        pandoc.Attr(
          "",
          { "title-slide", "custom-title" },
          {
            ["data-background-color"] = "#2DD2C0",
            ["data-state"] = "hide-logo"
          }
        )
      ),
      pandoc.RawBlock(
        "html",
        '<div class="title-content' .. extra_class .. '">\n' ..
        '<div class="title-theme">' .. html_escape(metadata_value(meta, "title-theme")) .. "</div>\n" ..
        '<h1 class="subtitle-highlight">' .. html_escape(metadata_value(meta, "subtitle-highlight")) .. "</h1>\n" ..
        '</div>\n' ..
        '<div class="title-meta">\n' .. presenters_html(meta) .. "\n</div>\n" ..
        '<div class="event-meta">' .. event_line .. "</div>"
      )
    }
  end
}
