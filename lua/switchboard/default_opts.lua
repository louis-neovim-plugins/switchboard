local hl_groups = require("switchboard.types.enums").swichboard_hl_group


local M = {}


---@type SwitchboardOpts
M.default_opts = {
    window = {
        title = " Switchboard ",
        title_pos = "center",

        style = "minimal",
        border = "rounded",
        zindex = 220,

        min_width = 15,
        min_height = 8,
    },
    icons = {
        is_on = "󰔡",
        is_off = "",
        separator = "",
    },
    highlight_groups = {
        [hl_groups.SwitchboardKeymapLhs] = { link = "WhichKey"           },
        [hl_groups.SwitchboardSeparator] = { link = "WhichKeySeparator"  },
        [hl_groups.SwitchboardIconOn   ] = { link = "WhichKeyIconGreen"  },
        [hl_groups.SwitchboardIconOff  ] = { link = "WhichKeyIconOrange" },
        [hl_groups.SwitchboardLabel    ] = { link = "WhichKeyDesc"       },
    },
    switches = {},
}


return M
