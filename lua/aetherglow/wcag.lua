-- WCAG contrast ratio calculator and validator
local M = {}

-- Convert hex to RGB
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16) / 255,
    g = tonumber(hex:sub(3, 4), 16) / 255,
    b = tonumber(hex:sub(5, 6), 16) / 255,
  }
end

-- Calculate relative luminance
local function get_luminance(rgb)
  local function adjust(c)
    if c <= 0.03928 then
      return c / 12.92
    else
      return ((c + 0.055) / 1.055) ^ 2.4
    end
  end
  
  return 0.2126 * adjust(rgb.r) + 0.7152 * adjust(rgb.g) + 0.0722 * adjust(rgb.b)
end

-- Calculate contrast ratio between two colors
function M.contrast_ratio(color1, color2)
  local rgb1 = hex_to_rgb(color1)
  local rgb2 = hex_to_rgb(color2)
  
  local lum1 = get_luminance(rgb1)
  local lum2 = get_luminance(rgb2)
  
  local lighter = math.max(lum1, lum2)
  local darker = math.min(lum1, lum2)
  
  return (lighter + 0.05) / (darker + 0.05)
end

-- Check if contrast meets WCAG AA standard (4.5:1 for normal text, 3:1 for large text)
function M.is_wcag_aa(color1, color2, large_text)
  local ratio = M.contrast_ratio(color1, color2)
  local required = large_text and 3 or 4.5
  return ratio >= required, ratio
end

-- Check if contrast meets WCAG AAA standard (7:1 for normal text, 4.5:1 for large text)
function M.is_wcag_aaa(color1, color2, large_text)
  local ratio = M.contrast_ratio(color1, color2)
  local required = large_text and 4.5 or 7
  return ratio >= required, ratio
end

-- Lighten a color by a percentage
function M.lighten(hex, percent)
  local rgb = hex_to_rgb(hex)
  local factor = 1 + (percent / 100)
  
  local r = math.min(255, math.floor(rgb.r * 255 * factor))
  local g = math.min(255, math.floor(rgb.g * 255 * factor))
  local b = math.min(255, math.floor(rgb.b * 255 * factor))
  
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Darken a color by a percentage
function M.darken(hex, percent)
  local rgb = hex_to_rgb(hex)
  local factor = 1 - (percent / 100)
  
  local r = math.floor(rgb.r * 255 * factor)
  local g = math.floor(rgb.g * 255 * factor)
  local b = math.floor(rgb.b * 255 * factor)
  
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Adjust color to meet WCAG AA standard against background
function M.ensure_contrast(fg, bg, large_text)
  local passes, ratio = M.is_wcag_aa(fg, bg, large_text)
  if passes then
    return fg
  end
  
  -- Try lightening/darkening the foreground
  local bg_lum = get_luminance(hex_to_rgb(bg))
  local adjust_fn = bg_lum > 0.5 and M.darken or M.lighten
  
  for i = 5, 50, 5 do
    local adjusted = adjust_fn(fg, i)
    local passes, _ = M.is_wcag_aa(adjusted, bg, large_text)
    if passes then
      return adjusted
    end
  end
  
  -- If we can't meet AA, return the original color
  return fg
end

-- Validate all colors in a palette
function M.validate_palette(palette)
  local report = {
    passed = {},
    failed = {},
    adjusted = {},
  }
  
  local bg = palette.bg
  local important_colors = {
    { name = "fg", color = palette.fg },
    { name = "fg_alt", color = palette.fg_alt },
    { name = "grey", color = palette.grey },
    { name = "red", color = palette.red },
    { name = "green", color = palette.green },
    { name = "blue", color = palette.blue },
    { name = "yellow", color = palette.yellow },
    { name = "orange", color = palette.orange },
    { name = "purple", color = palette.purple },
    { name = "teal", color = palette.teal },
    { name = "cyan", color = palette.cyan },
  }
  
  for _, item in ipairs(important_colors) do
    local passes, ratio = M.is_wcag_aa(item.color, bg, false)
    if passes then
      table.insert(report.passed, {
        name = item.name,
        ratio = ratio,
        color = item.color
      })
    else
      local adjusted = M.ensure_contrast(item.color, bg, false)
      if adjusted ~= item.color then
        table.insert(report.adjusted, {
          name = item.name,
          original = item.color,
          adjusted = adjusted,
          ratio = M.contrast_ratio(adjusted, bg)
        })
      else
        table.insert(report.failed, {
          name = item.name,
          ratio = ratio,
          color = item.color
        })
      end
    end
  end
  
  return report
end

return M