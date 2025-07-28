# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AetherGlow is a premium Neovim colorscheme with 5 cosmic-inspired variants, WCAG AA accessibility compliance, and support for 60+ plugins. The theme focuses on both visual appeal and accessibility, with built-in color contrast validation and adjustment.

## Key Architecture Patterns

### Color System
- Base palette defined in `lua/aetherglow/init.lua:35-128` with WCAG-compliant colors
- Each variant overrides specific colors while maintaining consistency
- Colors are validated against WCAG AA standards (4.5:1 contrast ratio)
- Dynamic palette generation based on variant and user customization

### Highlight Compilation
- Central `compile_highlights()` function in `lua/aetherglow/init.lua:450-1300` generates all highlight groups
- Systematic organization: core highlights → syntax → diagnostics → plugins
- Supports `on_highlights` hook for user customization without modifying core code
- Caching system stores compiled highlights to improve startup performance

### WCAG Accessibility Module
- `lua/aetherglow/wcag.lua` implements W3C contrast calculations
- Automatic color adjustment to meet AA standards
- Validation function checks all highlight groups for compliance
- Uses relative luminance formula per W3C specifications

### Performance Optimizations
- Compiled highlights cached in `vim.fn.stdpath("cache")/aetherglow/`
- Cache key includes variant, options, and modification times
- Loadstring with error handling prevents crashes from corrupted cache
- Only recompiles when configuration changes

## Development Workflow

### Testing Changes
```lua
-- After modifying theme colors or highlights:
require("aetherglow").clear_cache()
vim.cmd("colorscheme aetherglow")

-- To validate WCAG compliance:
require("aetherglow").validate_wcag("dark_bold")  -- or any variant
```

### Adding Plugin Support
1. Add highlight groups in `compile_highlights()` function
2. Follow existing plugin patterns (search for similar plugins)
3. Test with actual plugin to ensure proper highlighting
4. Update PLUGINS.md if adding new plugin support

### Modifying Colors
1. Edit base palette or variant overrides in `init.lua`
2. Run WCAG validation to ensure accessibility
3. Test across all variants for consistency
4. Update terminal themes in `extras/` if needed

## Important Implementation Details

### Transparency Handling
- Four levels: `false`, `true`, `"partial"`, `"full"`
- Floating windows maintain readability even with full transparency
- Background colors carefully chosen for each transparency level

### Auto-switching Mode
- Uses `OptionSet` autocommand to watch `background` changes
- Automatically switches between `dark_bold` and `light_dawn`
- Preserves user configuration while switching

### Cache Management
- Cache files use Lua serialization for fast loading
- Automatic invalidation on file changes or config updates
- Safe error handling prevents startup failures

### Terminal Integration
- Color mappings defined in `extras/TERMINAL_COLORS.md`
- Consistent palette across Alacritty, Kitty, WezTerm, and Ghostty
- Terminal colors follow Neovim's g:terminal_color_* convention

## Code Style Guidelines

- Use local variables for performance
- Follow existing indentation (2 spaces)
- Group related highlights together
- Comment complex color calculations
- Maintain WCAG compliance for all changes