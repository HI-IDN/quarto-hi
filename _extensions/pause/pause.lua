local function stringify(value)
  if value == nil then
    return ""
  end
  return pandoc.utils.stringify(value)
end

local function format_time(seconds)
  local minutes = math.floor(seconds / 60)
  local rest = seconds % 60
  return string.format("%d:%02d", minutes, rest)
end

local pause_count = 0

return {
  ["pause"] = function(args)
    local raw_seconds = stringify(args[1])
    local seconds = tonumber(raw_seconds)

    if seconds == nil or seconds < 1 or seconds % 1 ~= 0 then
      return quarto.shortcode.error_output(
        "pause",
        "Expected a positive integer number of seconds, e.g. {{< pause 300 >}}"
      )
    end

    pause_count = pause_count + 1

    return {
      pandoc.Header(
        2,
        {},
        pandoc.Attr(
          "break-" .. tostring(pause_count),
          { "focus-slide", "break", "countdown-break" },
          {
            ["data-background-color"] = "#2DD2C0",
            ["data-countdown-seconds"] = tostring(seconds)
          }
        )
      ),
      pandoc.RawBlock(
        "html",
        '<h1>Pása</h1>\n' ..
        '<div class="countdown-clock" data-countdown-display>' .. format_time(seconds) .. '</div>'
      )
    }
  end
}
