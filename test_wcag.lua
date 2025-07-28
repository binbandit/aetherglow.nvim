#!/usr/bin/env lua

-- Test WCAG compliance for all variants
package.path = "./lua/?.lua;" .. package.path

local wcag = require("aetherglow.wcag")
local aetherglow = require("aetherglow")

local variants = { "dark_soft", "dark_bold", "neon_glow", "aurora_burst", "light_dawn" }

print("AetherGlow WCAG Compliance Report")
print("=================================\n")

for _, variant in ipairs(variants) do
  print(string.format("Variant: %s", variant))
  print(string.rep("-", 40))
  
  local palette = aetherglow.get_palette(variant)
  local bg = palette.bg
  
  local colors_to_test = {
    { name = "fg", color = palette.fg },
    { name = "fg_alt", color = palette.fg_alt },
    { name = "grey", color = palette.grey },
    { name = "red", color = palette.red },
    { name = "orange", color = palette.orange },
    { name = "yellow", color = palette.yellow },
    { name = "green", color = palette.green },
    { name = "teal", color = palette.teal },
    { name = "blue", color = palette.blue },
    { name = "purple", color = palette.purple },
    { name = "magenta", color = palette.magenta },
    { name = "cyan", color = palette.cyan },
  }
  
  local all_pass = true
  
  for _, item in ipairs(colors_to_test) do
    if item.color and item.color:match("^#%x%x%x%x%x%x$") then
      local passes_aa, ratio = wcag.is_wcag_aa(item.color, bg, false)
      local passes_aaa, _ = wcag.is_wcag_aaa(item.color, bg, false)
      
      local status = passes_aaa and "AAA" or (passes_aa and "AA " or "FAIL")
      if not passes_aa then all_pass = false end
      
      print(string.format("  %-10s %s -> %s  %5.1f:1  [%s]", 
        item.name, item.color, bg, ratio, status))
    end
  end
  
  print(string.format("\n  Overall: %s\n", all_pass and "✓ PASS" or "✗ FAIL"))
end

print("\nLegend:")
print("  AAA = Meets WCAG AAA standard (7:1)")
print("  AA  = Meets WCAG AA standard (4.5:1)")
print("  FAIL = Does not meet minimum standards")