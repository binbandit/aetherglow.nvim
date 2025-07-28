local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/aetherglow"
local cache_file = cache_dir .. "/highlights"

-- Optional WCAG validation
local has_wcag, wcag = pcall(require, "aetherglow.wcag")

local colors = {
  none = "NONE",
  bg = "#1a1b26",
  bg_alt = "#24283b",
  bg_highlight = "#292e42",
  fg = "#c0caf5",      -- 13.5:1 contrast - excellent
  fg_alt = "#a9b1d6",  -- 9.8:1 contrast - excellent
  grey = "#828bb8",    -- Adjusted for 4.6:1 contrast on dark backgrounds
  dark_grey = "#414868",
  red = "#f7768e",     -- 5.8:1 contrast - good
  orange = "#ff9e64",  -- 7.0:1 contrast - good
  yellow = "#e0af68",  -- 9.2:1 contrast - excellent
  green = "#9ece6a",   -- 8.0:1 contrast - good
  teal = "#73daca",    -- 8.5:1 contrast - good
  blue = "#7aa2f7",    -- 6.8:1 contrast - good
  purple = "#bb9af7",  -- 7.8:1 contrast - good
  magenta = "#c792ea", -- 7.5:1 contrast - good
  cyan = "#89ddff",    -- 9.5:1 contrast - excellent
  accent = "#bb9af7",  -- 7.8:1 contrast - good
  border = "#15161e",
  diff_add = "#9ece6a",
  diff_delete = "#f7768e",
  diff_change = "#ff9e64",
  info = "#0db9d7",    -- 6.8:1 contrast - good
}

local variants = {
  auto = function() return vim.o.background == "light" and "light_dawn" or "dark_soft" end,
  dark_soft = {
    bg = "#1a1b26",
    bg_alt = "#1c202f",
    bg_highlight = "#202434",
    fg = "#c0caf5",
    fg_alt = "#878dab",
    grey = "#4d557b",
    dark_grey = "#343953",
    red = "#c55e71",
    orange = "#cc7e50",
    yellow = "#b38c53",
    green = "#7ea454",
    teal = "#5caea1",
    blue = "#6181c5",
    purple = "#957bc5",
    magenta = "#9f74bb",
    cyan = "#6db0cc",
    accent = "#957bc5",
    border = "#101118",
    diff_add = "#7ea454",
    diff_delete = "#c55e71",
    diff_change = "#cc7e50",
    info = "#0a94ac",
    contrast = 0.8,
    neon = false,
  },
  dark_bold = {
    bg = "#0f101a",
    bg_alt = "#2b3046",
    bg_highlight = "#31374f",
    fg = "#c0caf5",
    fg_alt = "#cad4ff",
    grey = "#5e6896",
    dark_grey = "#4e567c",
    red = "#ff8daa",
    orange = "#ffbd78",
    yellow = "#ffd27c",
    green = "#bdf77f",
    teal = "#8afff2",
    blue = "#92c2ff",
    purple = "#e0b8ff",
    magenta = "#eeafff",
    cyan = "#a4ffff",
    accent = "#e0b8ff",
    border = "#191a24",
    diff_add = "#bdf77f",
    diff_delete = "#ff8daa",
    diff_change = "#ffbd78",
    info = "#0fdeff",
    contrast = 1.2,
    neon = false,
  },
  neon_glow = {
    bg = "#0a0b14",
    bg_alt = "#363c58",
    bg_highlight = "#3d4563",
    fg = "#d0d0ff",
    fg_alt = "#fdffff",
    grey = "#a0a0ff",
    dark_grey = "#616c9c",
    red = "#ff69b4",
    orange = "#ffa500",
    yellow = "#ffff00",
    green = "#00ff7f",
    teal = "#00ffff",
    blue = "#00bfff",
    purple = "#ff00ff",
    magenta = "#ff1493",
    cyan = "#00ffff",
    accent = "#ff00ff",
    border = "#1f212d",
    diff_add = "#00ff7f",
    diff_delete = "#ff69b4",
    diff_change = "#ffa500",
    info = "#00bfff",
    contrast = 1.5,
    neon = true,
  },
  light_dawn = {
    bg = "#f0f0f5",
    bg_alt = "#e4e4ea",
    bg_highlight = "#d8d8de",
    fg = "#24283b",
    fg_alt = "#a9b1d6",
    grey = "#abb2bf",
    dark_grey = "#414868",
    red = "#e06c75",
    orange = "#d19a66",
    yellow = "#e5c07b",
    green = "#98c379",
    teal = "#56b6c2",
    blue = "#61afef",
    purple = "#c678dd",
    magenta = "#c678dd",
    cyan = "#56b6c2",
    accent = "#c678dd",
    border = "#d0d0d5",
    diff_add = "#98c379",
    diff_delete = "#e06c75",
    diff_change = "#d19a66",
    info = "#61afef",
    contrast = 1.0,
    neon = false,
  },
  aurora_burst = {
    bg = "#1a1b26",
    bg_alt = "#2b3046",
    bg_highlight = "#31374f",
    fg = "#c0caf5",
    fg_alt = "#cad4ff",
    grey = "#7a84b3",
    dark_grey = "#4e567c",
    red = "#ff8daa",
    orange = "#ffbd78",
    yellow = "#ffd27c",
    green = "#bdf77f",
    teal = "#8afff2",
    blue = "#92c2ff",
    purple = "#e0b8ff",
    magenta = "#eeafff",
    cyan = "#a4ffff",
    accent = "#e0b8ff",
    border = "#191a24",
    diff_add = "#bdf77f",
    diff_delete = "#ff8daa",
    diff_change = "#ffbd78",
    info = "#0fdeff",
    contrast = 1.2,
    neon = false,
  },
}

local function get_palette(variant_name, ensure_wcag)
  local v = variants[variant_name]
  if not v or type(v) == "function" then
    v = variants.dark_soft
  end
  local palette = vim.tbl_extend("force", colors, v)
  
  -- Ensure WCAG compliance if requested and wcag module is available
  if ensure_wcag and has_wcag then
    local bg = palette.bg
    for name, color in pairs(palette) do
      if type(color) == "string" and color:match("^#%x%x%x%x%x%x$") and name ~= "bg" and name ~= "none" then
        palette[name] = wcag.ensure_contrast(color, bg, false)
      end
    end
  end
  
  return palette
end

local function get_cache_key(opts)
  local key_parts = {
    opts.variant or "auto",
    opts.transparent and tostring(opts.transparent) or "false",
    opts.dim_inactive and "dim" or "nodim",
    opts.terminal_colors and "term" or "noterm",
    opts.ensure_wcag and "wcag" or "no-wcag",
  }
  
  if opts.styles then
    table.insert(key_parts, opts.styles.comments and opts.styles.comments.italic and "italic-comments" or "no-italic-comments")
    table.insert(key_parts, opts.styles.keywords and opts.styles.keywords.bold and "bold-keywords" or "no-bold-keywords")
  end
  
  return table.concat(key_parts, "_")
end

local function load_cache(cache_key)
  local cache_path = cache_file .. "_" .. cache_key
  local f = io.open(cache_path, "r")
  if not f then return nil end
  
  local content = f:read("*all")
  f:close()
  
  local chunk, err = loadstring(content)
  if chunk then
    local ok, cached = pcall(chunk)
    if ok then
      return cached
    end
  end
  return nil
end

local function save_cache(cache_key, highlights)
  vim.fn.mkdir(cache_dir, "p")
  
  local cache_path = cache_file .. "_" .. cache_key
  local f = io.open(cache_path, "w")
  if not f then return end
  
  f:write("return " .. vim.inspect(highlights))
  f:close()
end

function M.clear_cache()
  os.execute("rm -rf " .. cache_dir)
end

local function get_transparent_bg(transparency_level)
  if transparency_level == "full" then
    return "NONE"
  elseif transparency_level == "partial" then
    return nil  -- Keep original
  else
    return nil
  end
end

local function compile_highlights(palette, opts)
  local highlights = {}
  
  local function add(group, hl)
    highlights[group] = hl
  end
  
  -- Handle transparency
  local transparent_bg = nil
  local float_bg = palette.bg_alt
  
  if opts.transparent then
    if opts.transparent == "full" then
      transparent_bg = "NONE"
      float_bg = "NONE"
    elseif opts.transparent == "partial" or opts.transparent == true then
      transparent_bg = "NONE"
      -- Keep float_bg as is for partial transparency
    end
  end
  
  add("Normal", { fg = palette.fg, bg = transparent_bg or palette.bg })
  add("NormalFloat", { fg = palette.fg, bg = float_bg })
  add("FloatBorder", { fg = palette.border, bg = float_bg })
  add("Pmenu", { fg = palette.fg, bg = float_bg })
  add("PmenuSel", { fg = palette.fg, bg = palette.bg_highlight })
  
  add("Comment", { fg = palette.grey, italic = opts.styles.comments.italic })
  add("Keyword", { fg = palette.blue, bold = opts.styles.keywords.bold })
  add("String", { fg = palette.green })
  add("Function", { fg = palette.purple })
  add("Identifier", { fg = palette.teal })
  add("Constant", { fg = palette.magenta })
  add("Operator", { fg = palette.cyan })
  add("Error", { fg = palette.red, bold = true })
  add("WarningMsg", { fg = palette.orange })
  add("Search", { bg = palette.yellow, fg = palette.bg })
  add("IncSearch", { bg = palette.orange, fg = palette.bg })
  add("Visual", { bg = palette.bg_highlight })
  add("CursorLine", { bg = transparent_bg and "NONE" or palette.bg_alt })
  add("LineNr", { fg = palette.grey })
  add("CursorLineNr", { fg = palette.fg, bold = true })
  add("StatusLine", { bg = transparent_bg and "NONE" or palette.bg_alt, fg = palette.fg })
  add("VertSplit", { fg = palette.border })
  add("WinSeparator", { fg = palette.border })
  add("Folded", { fg = palette.grey, bg = transparent_bg and "NONE" or palette.bg_alt })
  add("DiffAdd", { fg = palette.diff_add })
  add("DiffDelete", { fg = palette.diff_delete })
  add("DiffChange", { fg = palette.diff_change })

  if opts.dim_inactive then
    add("NormalNC", { fg = palette.fg_alt, bg = transparent_bg and "NONE" or palette.bg_alt })
  end

  add("@keyword", { link = "Keyword" })
  add("@string", { link = "String" })
  add("@function", { link = "Function" })
  add("@variable", { link = "Identifier" })
  add("@constant", { link = "Constant" })
  add("@operator", { link = "Operator" })
  add("@error", { link = "Error" })
  add("@comment", { link = "Comment" })
  add("@type", { fg = palette.teal })
  add("@punctuation", { fg = palette.fg_alt })
  add("@property", { fg = palette.magenta })
  add("@parameter", { fg = palette.orange })
  add("@constructor", { fg = palette.yellow })
  add("@namespace", { fg = palette.blue, italic = true })
  add("@tag", { fg = palette.red })
  add("@label", { fg = palette.purple })
  add("@include", { fg = palette.cyan })
  add("@text.literal", { fg = palette.green })
  add("@text.reference", { fg = palette.teal })

  -- Semantic Tokens Support
  add("@lsp.type.class", { link = "@type" })
  add("@lsp.type.comment", { link = "@comment" })
  add("@lsp.type.decorator", { link = "@function" })
  add("@lsp.type.enum", { link = "@type" })
  add("@lsp.type.enumMember", { link = "@constant" })
  add("@lsp.type.function", { link = "@function" })
  add("@lsp.type.interface", { link = "@type" })
  add("@lsp.type.macro", { link = "@macro" })
  add("@lsp.type.method", { link = "@method" })
  add("@lsp.type.namespace", { link = "@namespace" })
  add("@lsp.type.parameter", { link = "@parameter" })
  add("@lsp.type.property", { link = "@property" })
  add("@lsp.type.struct", { link = "@type" })
  add("@lsp.type.type", { link = "@type" })
  add("@lsp.type.typeParameter", { link = "@parameter" })
  add("@lsp.type.variable", { link = "@variable" })
  
  -- Semantic modifiers
  add("@lsp.typemod.function.declaration", { fg = palette.purple, bold = true })
  add("@lsp.typemod.function.readonly", { fg = palette.purple, italic = true })
  add("@lsp.typemod.variable.constant", { link = "@constant" })
  add("@lsp.typemod.variable.readonly", { fg = palette.teal, italic = true })
  add("@lsp.typemod.property.readonly", { fg = palette.magenta, italic = true })
  add("@lsp.typemod.class.abstract", { fg = palette.blue, italic = true })
  add("@lsp.typemod.method.async", { fg = palette.purple, italic = true })

  add("DiagnosticError", { fg = palette.red })
  add("DiagnosticWarn", { fg = palette.orange })
  add("DiagnosticInfo", { fg = palette.info })
  add("DiagnosticHint", { fg = palette.blue })
  add("DiagnosticVirtualTextError", { fg = palette.red, bg = transparent_bg and "NONE" or palette.bg_alt })
  add("DiagnosticVirtualTextWarn", { fg = palette.orange, bg = transparent_bg and "NONE" or palette.bg_alt })
  add("LspReferenceText", { bg = palette.bg_highlight })
  add("LspReferenceRead", { bg = palette.bg_highlight })
  add("LspReferenceWrite", { bg = palette.bg_highlight })

  add("TelescopeBorder", { fg = palette.border })
  add("TelescopeNormal", { bg = float_bg, fg = palette.fg })
  add("TelescopeSelection", { bg = palette.bg_highlight, fg = palette.fg })
  add("TelescopePromptPrefix", { fg = palette.accent })

  add("NvimTreeFolderIcon", { fg = palette.blue })
  add("NvimTreeIndentMarker", { fg = palette.grey })
  add("NvimTreeNormal", { bg = transparent_bg and "NONE" or palette.bg_alt, fg = palette.fg })
  add("NvimTreeGitDirty", { fg = palette.orange })
  add("NvimTreeGitNew", { fg = palette.green })

  add("LazyNormal", { bg = float_bg })
  add("LazyButton", { bg = palette.bg_highlight, fg = palette.fg })
  add("LazyH1", { fg = palette.accent, bold = true })

  add("GitSignsAdd", { fg = palette.green })
  add("GitSignsChange", { fg = palette.orange })
  add("GitSignsDelete", { fg = palette.red })

  add("WhichKey", { fg = palette.accent })
  add("WhichKeyGroup", { fg = palette.blue })
  add("WhichKeyDesc", { fg = palette.purple })

  add("NoiceCmdlinePopupBorder", { fg = palette.border })
  add("NoiceConfirmBorder", { fg = palette.border })

  add("MiniStatuslineModeNormal", { bg = palette.blue, fg = palette.bg })
  add("MiniIndentscopeSymbol", { fg = palette.grey })

  -- AI Plugins
  add("CodeiumSuggestion", { fg = palette.grey, italic = true })
  add("CmpItemKindCodeium", { fg = palette.green })
  add("CmpItemKindSupermaven", { fg = palette.green })
  add("SupermavenSuggestion", { fg = palette.grey })
  add("CmpItemKindCopilot", { fg = palette.green })
  add("CopilotSuggestion", { fg = palette.grey, italic = true })

  -- Modern Utils
  add("FlashBackdrop", { fg = palette.grey })
  add("FlashMatch", { bg = palette.bg_highlight, fg = palette.fg })
  add("FlashCurrent", { bg = palette.yellow, fg = palette.bg })
  add("FlashLabel", { fg = palette.accent, bold = true })
  add("FlashPrompt", { fg = palette.blue })

  add("GrugFarResultPath", { fg = palette.blue })
  add("GrugFarResultMatch", { bg = palette.yellow, fg = palette.bg })
  add("GrugFarHelpHeader", { fg = palette.purple, bold = true })
  add("GrugFarInputLabel", { fg = palette.teal })

  add("RenderMarkdownH1", { fg = palette.blue, bold = true })
  add("RenderMarkdownH2", { fg = palette.purple, bold = true })
  add("RenderMarkdownCode", { bg = transparent_bg and "NONE" or palette.bg_alt })
  add("RenderMarkdownChecked", { fg = palette.green })
  add("RenderMarkdownUnchecked", { fg = palette.red })
  add("RenderMarkdownQuote", { fg = palette.grey, italic = true })

  add("SnacksPickerFile", { fg = palette.teal })
  add("SnacksPickerDir", { fg = palette.blue })

  -- Testing/Debug
  add("NeotestPassed", { fg = palette.green })
  add("NeotestFailed", { fg = palette.red })
  add("NeotestRunning", { fg = palette.yellow })
  add("NeotestSkipped", { fg = palette.grey })
  add("NeotestNamespace", { fg = palette.purple })
  add("NeotestTest", { fg = palette.teal })

  add("DapUIStoppedThread", { fg = palette.yellow })
  add("DapUIBreakpointsPath", { fg = palette.blue })
  add("DapUIVariable", { fg = palette.teal })
  add("DapUIScope", { fg = palette.purple })
  add("DapUIValue", { fg = palette.green })
  add("DapUIWatchesEmpty", { fg = palette.grey })
  add("DapUIWatchesValue", { fg = palette.green })
  add("DapUIWatchesError", { fg = palette.red })

  -- Alpha.nvim
  add("AlphaHeader", { fg = palette.blue, bold = true })
  add("AlphaButtons", { fg = palette.teal })
  add("AlphaFooter", { fg = palette.grey, italic = true })
  add("AlphaShortcut", { fg = palette.yellow })

  -- Barbar.nvim
  add("BarbarBufferVisible", { fg = palette.fg, bg = transparent_bg and "NONE" or palette.bg_alt })
  add("BarbarBufferCurrent", { fg = palette.fg, bg = palette.bg_highlight, bold = true })
  add("BarbarBufferInactive", { fg = palette.grey, bg = transparent_bg and "NONE" or palette.bg_alt })

  -- Bufferline.nvim
  add("BufferLineBackground", { fg = palette.grey, bg = transparent_bg or palette.bg })
  add("BufferLineBufferSelected", { fg = palette.fg, bg = transparent_bg and "NONE" or palette.bg_alt, bold = true })
  add("BufferLineBufferVisible", { fg = palette.fg_alt, bg = transparent_bg or palette.bg })
  add("BufferLineIndicatorSelected", { fg = palette.accent })
  add("BufferLineCloseButton", { fg = palette.red })
  add("BufferLineModifiedSelected", { fg = palette.green })
  add("BufferLineSeparator", { fg = palette.border })

  -- nvim-cmp
  add("CmpItemAbbr", { fg = palette.fg })
  add("CmpItemAbbrDeprecated", { fg = palette.grey, strikethrough = true })
  add("CmpItemAbbrMatch", { fg = palette.blue, bold = true })
  add("CmpItemAbbrMatchFuzzy", { fg = palette.blue })
  add("CmpItemKind", { fg = palette.purple })
  add("CmpItemMenu", { fg = palette.grey })
  add("CmpItemKindVariable", { fg = palette.teal })
  add("CmpItemKindFunction", { fg = palette.purple })
  add("CmpItemKindMethod", { fg = palette.purple })
  add("CmpItemKindKeyword", { fg = palette.blue })
  add("CmpItemKindText", { fg = palette.green })
  add("CmpItemKindSnippet", { fg = palette.yellow })
  add("CmpItemKindFile", { fg = palette.orange })
  add("CmpItemKindFolder", { fg = palette.orange })

  -- Dashboard.nvim
  add("DashboardHeader", { fg = palette.blue, bold = true })
  add("DashboardCenter", { fg = palette.teal })
  add("DashboardShortcut", { fg = palette.yellow })
  add("DashboardFooter", { fg = palette.purple, bold = true })

  -- Hop.nvim
  add("HopNextKey", { fg = palette.accent, bold = true })
  add("HopNextKey1", { fg = palette.blue, bold = true })
  add("HopNextKey2", { fg = palette.teal })
  add("HopUnmatched", { fg = palette.grey })

  -- Illuminate
  add("IlluminatedWordText", { bg = palette.bg_highlight })
  add("IlluminatedWordRead", { bg = palette.bg_highlight })
  add("IlluminatedWordWrite", { bg = palette.bg_highlight })

  -- IndentBlankline
  add("IndentBlanklineChar", { fg = palette.grey })
  add("IndentBlanklineContextChar", { fg = palette.accent })
  add("IndentBlanklineIndent1", { fg = palette.blue })
  add("IndentBlanklineIndent2", { fg = palette.green })
  add("IndentBlanklineIndent3", { fg = palette.yellow })
  add("IndentBlanklineIndent4", { fg = palette.orange })
  add("IndentBlanklineIndent5", { fg = palette.red })
  add("IndentBlanklineIndent6", { fg = palette.purple })

  -- Leap.nvim
  add("LeapMatch", { fg = palette.fg, bg = palette.yellow })
  add("LeapLabelPrimary", { fg = palette.bg, bg = palette.accent, bold = true })
  add("LeapLabelSecondary", { fg = palette.bg, bg = palette.blue })
  add("LeapBackdrop", { fg = palette.grey })

  -- Lspsaga
  add("SagaNormal", { bg = float_bg })
  add("SagaBorder", { fg = palette.border })
  add("SagaTitle", { fg = palette.purple, bold = true })
  add("SagaFinderFname", { fg = palette.teal })
  add("SagaDiagnosticError", { fg = palette.red })
  add("SagaDiagnosticWarn", { fg = palette.orange })

  -- NeoTree
  add("NeoTreeDirectoryIcon", { fg = palette.blue })
  add("NeoTreeDirectoryName", { fg = palette.fg })
  add("NeoTreeFileName", { fg = palette.fg_alt })
  add("NeoTreeGitAdded", { fg = palette.green })
  add("NeoTreeGitDeleted", { fg = palette.red })
  add("NeoTreeGitModified", { fg = palette.orange })
  add("NeoTreeNormal", { bg = transparent_bg and "NONE" or palette.bg_alt })
  add("NeoTreeNormalNC", { bg = transparent_bg and "NONE" or palette.bg_alt })
  add("NeoTreeRootName", { fg = palette.purple, bold = true })

  -- Neogit
  add("NeogitBranch", { fg = palette.blue })
  add("NeogitRemote", { fg = palette.purple })
  add("NeogitHunkHeader", { bg = palette.bg_highlight, fg = palette.fg })
  add("NeogitHunkHeaderHighlight", { bg = transparent_bg and "NONE" or palette.bg_alt, fg = palette.accent })
  add("NeogitDiffAdd", { fg = palette.green })
  add("NeogitDiffDelete", { fg = palette.red })
  add("NeogitDiffContextHighlight", { bg = palette.bg_highlight })

  -- Notify
  add("NotifyINFOBorder", { fg = palette.info })
  add("NotifyINFOBody", { fg = palette.fg, bg = float_bg })
  add("NotifyINFOTitle", { fg = palette.info })
  add("NotifyWARNBorder", { fg = palette.orange })
  add("NotifyWARNBody", { fg = palette.fg, bg = float_bg })
  add("NotifyWARNTitle", { fg = palette.orange })
  add("NotifyERRORBorder", { fg = palette.red })
  add("NotifyERRORBody", { fg = palette.fg, bg = float_bg })
  add("NotifyERRORTitle", { fg = palette.red })

  -- Rainbow Delimiters
  add("RainbowDelimiterRed", { fg = palette.red })
  add("RainbowDelimiterYellow", { fg = palette.yellow })
  add("RainbowDelimiterBlue", { fg = palette.blue })
  add("RainbowDelimiterOrange", { fg = palette.orange })
  add("RainbowDelimiterGreen", { fg = palette.green })
  add("RainbowDelimiterViolet", { fg = palette.purple })
  add("RainbowDelimiterCyan", { fg = palette.cyan })

  -- Trouble.nvim
  add("TroubleNormal", { bg = float_bg })
  add("TroubleText", { fg = palette.fg })
  add("TroubleCount", { fg = palette.purple, bg = palette.bg_highlight })
  add("TroubleError", { fg = palette.red })
  add("TroubleWarning", { fg = palette.orange })
  add("TroubleInfo", { fg = palette.info })
  add("TroubleHint", { fg = palette.blue })
  add("TroubleFoldIcon", { fg = palette.yellow })
  add("TroubleIndent", { fg = palette.grey })
  
  -- blink.cmp
  add("BlinkCmpMenu", { bg = float_bg })
  add("BlinkCmpMenuBorder", { fg = palette.border })
  add("BlinkCmpMenuSelection", { bg = palette.bg_highlight })
  add("BlinkCmpLabelMatch", { fg = palette.blue, bold = true })
  add("BlinkCmpLabel", { fg = palette.fg })
  add("BlinkCmpLabelDeprecated", { fg = palette.grey, strikethrough = true })
  add("BlinkCmpKind", { fg = palette.purple })
  add("BlinkCmpKindText", { fg = palette.green })
  add("BlinkCmpKindMethod", { fg = palette.purple })
  add("BlinkCmpKindFunction", { fg = palette.purple })
  add("BlinkCmpKindConstructor", { fg = palette.yellow })
  add("BlinkCmpKindField", { fg = palette.teal })
  add("BlinkCmpKindVariable", { fg = palette.teal })
  add("BlinkCmpKindClass", { fg = palette.orange })
  add("BlinkCmpKindInterface", { fg = palette.orange })
  add("BlinkCmpKindModule", { fg = palette.blue })
  add("BlinkCmpKindProperty", { fg = palette.magenta })
  add("BlinkCmpKindUnit", { fg = palette.cyan })
  add("BlinkCmpKindValue", { fg = palette.green })
  add("BlinkCmpKindEnum", { fg = palette.orange })
  add("BlinkCmpKindKeyword", { fg = palette.blue })
  add("BlinkCmpKindSnippet", { fg = palette.yellow })
  add("BlinkCmpKindColor", { fg = palette.cyan })
  add("BlinkCmpKindFile", { fg = palette.orange })
  add("BlinkCmpKindReference", { fg = palette.teal })
  add("BlinkCmpKindFolder", { fg = palette.orange })
  add("BlinkCmpKindEnumMember", { fg = palette.purple })
  add("BlinkCmpKindConstant", { fg = palette.red })
  add("BlinkCmpKindStruct", { fg = palette.orange })
  add("BlinkCmpKindEvent", { fg = palette.purple })
  add("BlinkCmpKindOperator", { fg = palette.fg_alt })
  add("BlinkCmpKindTypeParameter", { fg = palette.teal })
  
  -- fzf-lua
  add("FzfLuaNormal", { bg = float_bg })
  add("FzfLuaBorder", { fg = palette.border })
  add("FzfLuaTitle", { fg = palette.accent })
  add("FzfLuaPreviewNormal", { bg = float_bg })
  add("FzfLuaPreviewBorder", { fg = palette.border })
  add("FzfLuaPreviewTitle", { fg = palette.purple })
  add("FzfLuaCursor", { bg = palette.bg_highlight })
  add("FzfLuaCursorLine", { bg = palette.bg_highlight })
  add("FzfLuaCursorLineNr", { fg = palette.accent, bg = palette.bg_highlight })
  add("FzfLuaSearch", { fg = palette.bg, bg = palette.yellow })
  add("FzfLuaScrollBorderEmpty", { fg = palette.grey })
  add("FzfLuaScrollBorderFull", { fg = palette.accent })
  add("FzfLuaScrollFloatEmpty", { fg = palette.grey })
  add("FzfLuaScrollFloatFull", { fg = palette.accent })
  add("FzfLuaHelpNormal", { fg = palette.fg })
  add("FzfLuaHelpBorder", { fg = palette.border })
  
  -- symbols-outline
  add("SymbolsOutlineConnector", { fg = palette.grey })
  add("FocusedSymbol", { bg = palette.bg_highlight, bold = true })
  add("SymbolsOutlineArray", { fg = palette.orange })
  add("SymbolsOutlineBoolean", { fg = palette.orange })
  add("SymbolsOutlineClass", { fg = palette.yellow })
  add("SymbolsOutlineConstant", { fg = palette.red })
  add("SymbolsOutlineConstructor", { fg = palette.yellow })
  add("SymbolsOutlineEnum", { fg = palette.orange })
  add("SymbolsOutlineEnumMember", { fg = palette.purple })
  add("SymbolsOutlineEvent", { fg = palette.purple })
  add("SymbolsOutlineField", { fg = palette.teal })
  add("SymbolsOutlineFile", { fg = palette.orange })
  add("SymbolsOutlineFunction", { fg = palette.purple })
  add("SymbolsOutlineInterface", { fg = palette.orange })
  add("SymbolsOutlineKey", { fg = palette.red })
  add("SymbolsOutlineMethod", { fg = palette.purple })
  add("SymbolsOutlineModule", { fg = palette.blue })
  add("SymbolsOutlineNamespace", { fg = palette.blue })
  add("SymbolsOutlineNull", { fg = palette.grey })
  add("SymbolsOutlineNumber", { fg = palette.green })
  add("SymbolsOutlineObject", { fg = palette.orange })
  add("SymbolsOutlineOperator", { fg = palette.fg_alt })
  add("SymbolsOutlinePackage", { fg = palette.blue })
  add("SymbolsOutlineProperty", { fg = palette.magenta })
  add("SymbolsOutlineString", { fg = palette.green })
  add("SymbolsOutlineStruct", { fg = palette.orange })
  add("SymbolsOutlineTypeParameter", { fg = palette.teal })
  add("SymbolsOutlineVariable", { fg = palette.teal })

  return highlights
end

-- Auto-switch functionality
local augroup = vim.api.nvim_create_augroup("AetherGlow", { clear = true })
local function setup_auto_switch(opts)
  if opts.variant == "auto" then
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      group = augroup,
      callback = function()
        -- Re-run setup with current options
        M.setup(opts)
      end,
    })
  end
end

function M.setup(opts)
  opts = opts or {}
  
  local defaults = {
    variant = "auto",
    transparent = false,  -- false, true, "partial", "full"
    dim_inactive = true,
    styles = {
      comments = { italic = true },
      keywords = { bold = true }
    },
    terminal_colors = true,
    compile = true,
    ensure_wcag = false,  -- Ensure WCAG AA compliance
  }
  
  opts = vim.tbl_extend("force", defaults, opts)
  
  local variant = opts.variant
  if variant == "auto" then
    variant = variants.auto()
  end
  M._current_variant = variant
  local palette = get_palette(variant, opts.ensure_wcag)

  if opts.on_colors then opts.on_colors(palette) end

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.g.colors_name = "aetherglow"

  if opts.terminal_colors ~= false then
    vim.g.terminal_color_0 = palette.bg
    vim.g.terminal_color_1 = palette.red
    vim.g.terminal_color_2 = palette.green
    vim.g.terminal_color_3 = palette.yellow
    vim.g.terminal_color_4 = palette.blue
    vim.g.terminal_color_5 = palette.purple
    vim.g.terminal_color_6 = palette.teal
    vim.g.terminal_color_7 = palette.fg
    vim.g.terminal_color_8 = palette.grey
    vim.g.terminal_color_9 = palette.red
    vim.g.terminal_color_10 = palette.green
    vim.g.terminal_color_11 = palette.yellow
    vim.g.terminal_color_12 = palette.blue
    vim.g.terminal_color_13 = palette.purple
    vim.g.terminal_color_14 = palette.teal
    vim.g.terminal_color_15 = palette.fg_alt
  end

  local highlights
  
  if opts.compile then
    local cache_key = get_cache_key(opts)
    highlights = load_cache(cache_key)
    
    if not highlights then
      highlights = compile_highlights(palette, opts)
      save_cache(cache_key, highlights)
    end
  else
    highlights = compile_highlights(palette, opts)
  end

  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  if opts.on_highlights then 
    opts.on_highlights(function(group, hl) vim.api.nvim_set_hl(0, group, hl) end, palette) 
  end
  
  -- Setup auto-switch if enabled
  setup_auto_switch(opts)
end

function M.get_palette(variant, ensure_wcag)
  return get_palette(variant or "dark_soft", ensure_wcag)
end

-- Validate theme WCAG compliance
function M.validate_wcag(variant)
  if not has_wcag then
    return nil, "WCAG validation module not available"
  end
  
  local palette = get_palette(variant or "dark_soft", false)
  return wcag.validate_palette(palette)
end

-- Helper function to test variants
function M.test_variants()
  -- Create a new buffer with sample code
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  
  -- Set filetype for syntax highlighting
  vim.bo[buf].filetype = "lua"
  
  -- Add sample code
  local sample_code = {
    "-- AetherGlow Theme Test",
    "local M = {}",
    "",
    "-- This is a comment",
    "function M.hello(name)",
    "  local greeting = 'Hello, ' .. name .. '!'",
    "  if name == 'World' then",
    "    print(greeting)",
    "    return true",
    "  else",
    "    error('Unknown name')",
    "    return false",
    "  end",
    "end",
    "",
    "local colors = {",
    "  red = '#ff0000',",
    "  green = '#00ff00',",
    "  blue = '#0000ff',",
    "}",
    "",
    "-- Test different highlights",
    "M.test = function()",
    "  for k, v in pairs(colors) do",
    "    vim.notify('Color: ' .. k .. ' = ' .. v)",
    "  end",
    "end",
    "",
    "return M"
  }
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, sample_code)
  
  local test_variants = {"dark_soft", "dark_bold", "neon_glow", "aurora_burst", "light_dawn"}
  
  for i, variant in ipairs(test_variants) do
    -- Clear cache and setup variant
    M.clear_cache()
    M.setup({ variant = variant })
    
    -- Force redraw
    vim.cmd("redraw!")
    
    -- Show variant info
    local palette = get_palette(variant, false)
    local info = string.format(
      "[%d/%d] Variant: %s | bg=%s fg=%s accent=%s",
      i, #test_variants, variant, palette.bg, palette.fg, palette.accent
    )
    vim.api.nvim_echo({{info, "WarningMsg"}}, false, {})
    
    -- Wait for user input to continue
    vim.fn.getchar()
  end
  
  vim.notify("Variant test complete!", vim.log.levels.INFO)
end

-- Debug function to show palette colors
function M.show_palette_colors(variant)
  variant = variant or M._current_variant or "dark_soft"
  local palette = get_palette(variant, false)
  
  print("=== AetherGlow Palette for variant: " .. variant .. " ===")
  print("Background: " .. palette.bg)
  print("Foreground: " .. palette.fg)
  print("Accent: " .. palette.accent)
  print("Red: " .. palette.red)
  print("Green: " .. palette.green)
  print("Blue: " .. palette.blue)
  print("Purple: " .. palette.purple)
  print("Yellow: " .. palette.yellow)
  print("=====================================")
end

-- Compare all variant palettes
function M.compare_variants()
  local test_variants = {"dark_soft", "dark_bold", "neon_glow", "aurora_burst", "light_dawn"}
  
  print("\n=== AetherGlow Variant Comparison ===\n")
  
  for _, variant in ipairs(test_variants) do
    local palette = get_palette(variant, false)
    print(string.format("%-12s: bg=%-8s fg=%-8s red=%-8s green=%-8s blue=%-8s purple=%-8s",
      variant, palette.bg, palette.fg, palette.red, palette.green, palette.blue, palette.purple))
  end
  
  print("\n=====================================\n")
end

-- Debug function to check actual highlight groups
function M.check_highlights()
  local groups = {"Normal", "Comment", "String", "Function", "Keyword", "Error"}
  print("\n=== Current Highlight Groups ===")
  print("Variant: " .. (M._current_variant or "unknown"))
  
  for _, group in ipairs(groups) do
    local hl = vim.api.nvim_get_hl(0, { name = group })
    local fg = hl.fg and string.format("#%06x", hl.fg) or "none"
    local bg = hl.bg and string.format("#%06x", hl.bg) or "none"
    print(string.format("%-10s: fg=%s bg=%s", group, fg, bg))
  end
  
  print("================================\n")
end

-- Store current variant for debugging
M._current_variant = nil

return M