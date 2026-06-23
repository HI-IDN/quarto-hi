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

local function first_presenter(meta)
  local presenters = metadata_value(meta, "presenters")
  if type(presenters) ~= "table" then
    return nil
  end
  return presenters[1]
end

local function presenter_field(presenter, key)
  if presenter == nil then
    return ""
  end
  return stringify(presenter[key])
end

local function contact_row(icon_class, html)
  if html == "" then
    return ""
  end
  return '  <div class="contact-card-row">\n' ..
    '    <i class="' .. icon_class .. ' fa-fw"></i>\n' ..
    "    " .. html .. "\n" ..
    "  </div>\n"
end

local function contact_card_html(meta)
  local presenter = first_presenter(meta)
  if presenter == nil then
    return ""
  end

  local name = html_escape(presenter.name)
  local username = presenter_field(presenter, "hi-username")
  local email = presenter_field(presenter, "email")
  local office = presenter_field(presenter, "office")
  local affiliation = presenter_field(presenter, "affiliation")
  local orcid = presenter_field(presenter, "orcid")
  local github = presenter_field(presenter, "github"):gsub("^@", "")

  if email == "" and username ~= "" then
    email = username .. "@hi.is"
  end

  if office == "" then
    office = affiliation
  elseif affiliation ~= "" then
    office = office .. " · " .. affiliation
  end

  if office == "" then
    if document_lang(meta):sub(1, 2) == "is" then
      office = "Háskóli Íslands"
    else
      office = "University of Iceland"
    end
  end

  local rows = ""
  rows = rows .. contact_row("fa-solid fa-user", name ~= "" and "<span>" .. name .. "</span>" or "")
  rows = rows .. contact_row(
    "fa-solid fa-envelope",
    email ~= "" and '<a href="mailto:' .. html_escape(email) .. '">' .. html_escape(email) .. "</a>" or ""
  )
  rows = rows .. contact_row("fa-solid fa-building-columns", "<span>" .. html_escape(office) .. "</span>")
  rows = rows .. contact_row(
    "fa-brands fa-orcid",
    orcid ~= "" and '<a href="https://orcid.org/' .. html_escape(orcid) .. '" target="_blank" rel="noopener noreferrer">' .. html_escape(orcid) .. "</a>" or ""
  )
  rows = rows .. contact_row(
    "fa-brands fa-github",
    github ~= "" and '<a href="https://github.com/' .. html_escape(github) .. '" target="_blank" rel="noopener noreferrer">@' .. html_escape(github) .. "</a>" or ""
  )

  return '<div class="contact-card">\n' .. rows .. "</div>"
end

local function today_formatted(lang)
  local now = os.date("*t")
  if lang:sub(1, 2) == "is" then
    local months_is = {
      "janúar","febrúar","mars","apríl","maí","júní",
      "júlí","ágúst","september","október","nóvember","desember"
    }
    return string.format("%d. %s %d", now.day, months_is[now.month], now.year)
  else
    local months_en = {
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    }
    local day = now.day
    local suffix = "th"
    if day == 1 or day == 21 or day == 31 then suffix = "st"
    elseif day == 2 or day == 22 then suffix = "nd"
    elseif day == 3 or day == 23 then suffix = "rd" end
    return string.format("%d%s %s %d", day, suffix, months_en[now.month], now.year)
  end
end

return {
  ["hi-title"] = function(args, kwargs, meta)
    local lang = document_lang(meta)
    local event_meta = meta_to_html(metadata_value(meta, "event-meta"))
    local date = meta_to_html(metadata_value(meta, "event-date"))
    if date == "" or date == "today" then
      date = today_formatted(lang)
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

    local presenters = presenters_html(meta)
    local presenter_block = presenters ~= "" and
      '<div class="title-meta">\n' .. presenters .. "\n</div>\n" or ""

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
        presenter_block ..
        '<div class="event-meta">' .. event_line .. "</div>"
      )
    }
  end,
  ["contact-card"] = function(args, kwargs, meta)
    return pandoc.RawBlock("html", contact_card_html(meta))
  end
}
