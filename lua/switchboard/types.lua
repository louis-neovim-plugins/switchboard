local M = {}

---@enum SwichboardHlGroup
M.swichboard_hl_group = {
    SwitchboardKeymapLhs = "SwitchboardKeymapLhs",
    SwitchboardSeparator = "SwitchboardSeparator",
    SwitchboardIconOn    = "SwitchboardIconOn",
    SwitchboardIconOff   = "SwitchboardIconOff",
    SwitchboardLabel     = "SwitchboardLabel",
}


---Top level Switchboard options container.
---
---@class SwitchboardOpts
---@field window? SwitchboardWindowOpts
---@field switches? SwitchboardSwitch[] List of switch configurations.
---@field icons? SwitchBoardIconsOpts
---@field highlight_groups? table<SwichboardHlGroup, vim.api.keyset.highlight>


---Switchboard icons options.
---Purely visual.
---
---@class SwitchBoardIconsOpts
---@field is_on? string Icon that will signify that an option is "on".
---@field is_off? string Icon that will signify that an option is "off".
---@field separator? string Icon after the keymap lhs and before the icon + label.


---Style and positioning options for the Switchboard window.
---
---@class SwitchboardWindowOpts: vim.api.keyset.win_config
---@field min_width? integer
---@field min_height? integer


---Switchboard switch options.
---This is where you switch logic is defined.
---
---@class SwitchboardSwitch
---@field label string
---@field is_on fun(): boolean
---@field keymap SwitchboardKeymap


---Container for the various "blocks" or "elements" composing a line.
---This makes highlighting easier. I think.
---
---@class SwitchboardLineElement
---@field text string Raw text.
---@field highlight_group string Highlight group.


---Which-key style keymap definition. e.g.
---{ "lhs", "rhs", desc="Example" }
---{ "lhs", function() do stuff end, desc="Example" }
---
---@class SwitchboardKeymap: vim.keymap.set.Opts
---@field [1] string
---@field [2] string|function


return M

