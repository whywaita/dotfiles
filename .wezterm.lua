local wezterm = require 'wezterm'

local config = {}

config.front_end = "OpenGL"

config.color_scheme = "iceberg-dark"
config.window_background_opacity = 0.9
config.text_background_opacity = 1.0
--config.macos_window_background_blur = 20

config.use_ime = true
config.ime_preedit_rendering = "Builtin"
config.colors = {
  compose_cursor = "orange",
}

config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Biz UDGothic",
})
config.font_size = 17
config.line_height = 1.0

config.scrollback_lines = 1000
config.animation_fps = 120
config.max_fps = 120

config.window_frame = {
  active_titlebar_bg = "#282c34",
}
config.use_fancy_tab_bar = false

config.term = "xterm-256color"

return config
