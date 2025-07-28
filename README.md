# AetherGlow.nvim

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.8+-blueviolet.svg?style=flat-square&logo=Neovim&logoColor=white" alt="Neovim"/>
  <img src="https://img.shields.io/github/stars/binbandit/aetherglow.nvim?style=flat-square" alt="Stars"/>
  <img src="https://img.shields.io/badge/themes-5%20variants-ff69b4?style=flat-square" alt="Themes"/>
  <img src="https://img.shields.io/badge/plugins-60%2B%20supported-00ff7f?style=flat-square" alt="Plugins"/>
</p>

<p align="center">
  <b>Code under the northern lights: Ethereal, glowing, and endlessly shareable.</b>
</p>

<p align="center">
  <a href="#showcase">Showcase</a> •
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#variants">Variants</a> •
  <a href="#extras">Extras</a>
</p>

---

**AetherGlow** is a from-scratch Neovim theme inspired by cosmic auroras and nebulae. With mystical purples, teals, and subtle neon accents, it delivers a hypnotic, premium feel that's built for 2025 trends. Whether you prefer soothing pastels or vibrant neon, AetherGlow adapts to your vibe with automatic light/dark switching and 5 stunning variants.

> **Why developers love it:** Stunning screenshots that pop on socials, buttery smooth usability, and that "coding in space" aesthetic. Built for both marathon coding sessions and quick screenshot shares.

## Showcase

<table>
  <tr>
    <td width="50%">
      <img src="screenshots/dark_soft.png" alt="Dark Soft Variant"/>
      <p align="center"><b>Dark Soft</b> - Eye-friendly low contrast</p>
    </td>
    <td width="50%">
      <img src="screenshots/neon_glow.png" alt="Neon Glow Variant"/>
      <p align="center"><b>Neon Glow</b> - Cyberpunk vibes</p>
    </td>
  </tr>
</table>

## Features
- **Variants**: Dark Soft (low-contrast), Dark Bold (vibrant), Neon Glow (cyberpunk neon), Aurora Burst (vivid aurora colors), Light Dawn (warm light). Auto-switches via `vim.o.background`.
- **Palette**: Original cosmic hues—soft purples/teals with neon pops. WCAG-compliant contrast.
- **Customization**: Transparency, dim inactive windows, bold/italic styles, color overrides.
- **Support**: Treesitter, LSP, diagnostics, terminal colors. 50+ plugins (Telescope, Lazy, Gitsigns, etc.).
- **Extras**: Themes for Kitty, Alacritty, WezTerm, Ghostty, iTerm, Fish.
- **Performance**: Pure Lua, lightweight, with compiled highlight caching for instant startups.

## Installation
Via [Lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "binbandit/aetherglow.nvim",
  priority = 1000,
  config = function()
    require("aetherglow").setup({
      -- Your config here
    })
    vim.cmd.colorscheme "aetherglow"
  end,
}
```

Via [Packer](https://github.com/wbthomason/packer.nvim):
```lua
use {
  "binbandit/aetherglow.nvim",
  config = function()
    require("aetherglow").setup()
    vim.cmd.colorscheme "aetherglow"
  end
}
```

## Quick Start

Just want to try it out? After installation:

```vim
:colorscheme aetherglow
```

## Configuration
Default setup:
```lua
require("aetherglow").setup({
  variant = "auto",  -- "dark_soft", "dark_bold", "neon_glow", "aurora_burst", "light_dawn", or "auto"
  transparent = false,
  dim_inactive = true,
  styles = { comments = { italic = true }, keywords = { bold = true } },
  terminal_colors = true,
  compile = true,  -- Enable cached highlights for faster startup
})
```

Override colors:
```lua
require("aetherglow").setup({
  on_colors = function(colors)
    colors.bg = "#0a0b14"  -- Darker cosmic bg
  end,
})
```

### Performance

AetherGlow uses compiled highlight caching (like Catppuccin) for blazing fast startups. The cache is stored in `vim.fn.stdpath("cache")/aetherglow/` and automatically invalidates when you change settings.

To clear the cache manually:
```lua
require("aetherglow").clear_cache()
```

## Variants

<table>
  <tr>
    <td><b>Dark Soft</b></td>
    <td>Low-contrast for long coding sessions</td>
  </tr>
  <tr>
    <td><b>Dark Bold</b></td>
    <td>Vibrant colors with high contrast</td>
  </tr>
  <tr>
    <td><b>Neon Glow</b></td>
    <td>Cyberpunk-inspired neon accents</td>
  </tr>
  <tr>
    <td><b>Aurora Burst</b></td>
    <td>Vivid aurora borealis colors - bright and energetic</td>
  </tr>
  <tr>
    <td><b>Light Dawn</b></td>
    <td>Warm, pastel light theme</td>
  </tr>
</table>

## Supported Plugins

AetherGlow provides first-class support for **60+ plugins** with meticulously crafted highlight groups.

**Highlights include:**
- Complete **Treesitter** & **LSP** integration
- **AI assistants** (Copilot, Codeium, Supermaven)
- **File explorers** (Telescope, NvimTree, neo-tree)
- **Navigation** (Flash, Hop, Leap)
- **UI enhancements** (Noice, WhichKey, Alpha, Dashboard)
- **Git tools** (Gitsigns, Neogit)
- **Completion** (nvim-cmp with kind-specific colors)
- **Debugging** (DAP-UI, Neotest)
- And many more...

📋 **[See the complete plugin list →](PLUGINS.md)**

## Extras

Terminal themes included for:
- **Kitty** - `extras/kitty/aetherglow.conf`
- **Alacritty** - `extras/alacritty/aetherglow.toml`
- **WezTerm** - `extras/wezterm/aetherglow.lua`
- **Ghostty** - `extras/ghostty/aetherglow`

## Contributing

PRs welcome! Add plugin support, new variants, or terminal themes.

## Show Your Support

If you love AetherGlow, give it a star on GitHub and share your setup on social media with **#AetherGlow**.

## License

MIT © 2025 binbandit