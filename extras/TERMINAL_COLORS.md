# Terminal Color Reference

This document maps ANSI color codes to AetherGlow's WCAG-compliant colors.

## ANSI Color Mapping

| ANSI Code | Color Name    | Dark Variants  | Light Dawn     | Usage              |
|-----------|---------------|----------------|----------------|--------------------|
| 0         | Black         | #15161e        | #e4e4e7        | Terminal black     |
| 1         | Red           | #f7768e        | #c42e2e        | Errors             |
| 2         | Green         | #9ece6a        | #0e7c0e        | Success            |
| 3         | Yellow        | #e0af68        | #795e00        | Warnings           |
| 4         | Blue          | #7aa2f7        | #0451a5        | Info/Keywords      |
| 5         | Magenta       | #bb9af7        | #8839a5        | Special            |
| 6         | Cyan          | #73daca        | #006f94        | Strings/Links      |
| 7         | White         | #a9b1d6        | #24283b        | Normal text        |
| 8         | Bright Black  | #828bb8 ✓      | #5a5a5a        | Comments (WCAG AA) |
| 9         | Bright Red    | #f7768e        | #c42e2e        | Bright errors      |
| 10        | Bright Green  | #9ece6a        | #0e7c0e        | Bright success     |
| 11        | Bright Yellow | #e0af68        | #795e00        | Bright warnings    |
| 12        | Bright Blue   | #7aa2f7        | #0451a5        | Bright info        |
| 13        | Bright Magenta| #bb9af7        | #8839a5        | Bright special     |
| 14        | Bright Cyan   | #73daca        | #006f94        | Bright strings     |
| 15        | Bright White  | #c0caf5        | #1a1b26        | Bright text        |

## Special Variants

### Neon Glow
- Red: #ff69b4 (neon pink)
- Green: #00ff7f (neon green)
- Blue: #00bfff (neon blue)
- Foreground: #d0d0ff

### Aurora Burst
Uses boosted colors (20% brighter) while maintaining WCAG compliance.

## WCAG Compliance Notes

✓ All color combinations meet WCAG AA standards (4.5:1 contrast ratio)
✓ Bright Black (color8) specifically adjusted to #828bb8 for proper contrast
✓ Light theme colors carefully selected for readability on #f7f7fa background

## Terminal Support

- **Kitty**: Full 256 color support, uses native config format
- **Alacritty**: TOML format, supports true color
- **WezTerm**: Lua config with named color table
- **Ghostty**: Simple palette format
- **iTerm2**: Can import from Kitty format
- **Windows Terminal**: Can use Alacritty TOML as reference