# Switchboard

If you have a growing number of "toggle this" and "switch that" keymaps, this
plugin allows you to group all of these "switches" in one place and provides a
neat little "switchboard" listing all switch positions and their associated
keymaps.

![Screenshot](https://github.com/user-attachments/assets/5e387d33-6a7b-48ed-be05-a88e7eac0028)


## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
return {
    "louis-neovim-plugins/switchboard",
    opts = {},
    keys = {
        {
            "<leader>s",
            "<cmd>Switchboard<CR>",
            desc = "Switchboard",
        },
    },
}
```


## Configuration

Here are the default options:
```lua
---@type SwitchboardOpts
local default_opts = {
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
        SwitchboardKeymapLhs = { link = "WhichKey"           },
        SwitchboardSeparator = { link = "WhichKeySeparator"  },
        SwitchboardIconOn    = { link = "WhichKeyIconGreen"  },
        SwitchboardIconOff   = { link = "WhichKeyIconOrange" },
        SwitchboardLabel     = { link = "WhichKeyDesc"       },
    },
    switches = {},
}
```

> [!WARNING]
> The highlight groups are linked to the [which-key.nvim](https://github.com/folke/which-key.nvim)
> highlight groups by default. If you do not use which-key, you should define
> your own colors or links. See the "more complex" example below.

---

You need to provide your `switches` like so (replace the `switches` above):
```lua
---@type SwitchboardSwitch[]
local switches = {
    {
        label = "Inlay hints",

        -- This function is used to determine the position of the switch.
        is_on = function ()
            return vim.lsp.inlay_hint.is_enabled()
        end,

        -- Which-key style keymap, i.e { lhs, rhs }
        -- The rhs function/<cmd> is expected to flip the switch.
        -- The keymap is only defined inside the Switchboard window.
        keymap = {
            "h",
            function ()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end,
        },
    },
}
```

More complex example:
```lua
---@type SwitchboardSwitch
local color_preview_switch = {
    label = "Color preview",
    is_on = function ()
        return require("nvim-highlight-colors").is_active()
    end,
    keymap = {
        "c",
        function () require("nvim-highlight-colors").toggle() end,
    },
}


---@param _ any
---@param opts SwitchboardOpts
local function make_config(_, opts)
    local switches = require("switchboard.builtins").switches
    local hl_group = require("switchboard.types").swichboard_hl_group

    opts.switches = {
        color_preview_switch,
        -- Convenience function to quickly make switches with the given
        -- keymap lhs, and an optional label. You can easily overwrite
        -- the returned table on top of that.
        switches.make_diagnostics_switch("d"),
        switches.make_inlay_hints_switch("h"),
        switches.make_relative_line_numbers_switch("r"),
        switches.make_line_wrap_switch("w"),
    }

    opts.highlight_groups = {
        [hl_group.SwitchboardKeymapLhs] = { fg = "red"    },
        [hl_group.SwitchboardSeparator] = { fg = "blue"   },
        [hl_group.SwitchboardIconOn   ] = { fg = "green"  },
        [hl_group.SwitchboardIconOff  ] = { fg = "orange" },
        [hl_group.SwitchboardLabel    ] = { fg = "cyan"   },
    }

    require("switchboard").setup(opts)
end


return {
    "louis-neovim-plugins/switchboard",
    config = make_config,
    keys = {
        {
            "<leader>s",
            "<cmd>Switchboard<CR>",
            desc = "Switchboard",
        },
    },
}
```


## FAQ

Q: Can Switchboard handle other positions than "on" or "off"?  
A: No.

Q: Does it integrate with Which-key?  
A: No. Besides reusing the Which-key Highlight groups, there are no interactions between the two plugins.


## Similar plugins

This plugin is my attempt at reproducting [Snacks.toggle](https://github.com/folke/snacks.nvim/blob/main/docs/toggle.md),
I wasn't happy about the documentation, couldn't make it work, the customization
options seemed very limited, and the code is unreadable to me. A week-end later
and voilà, "we have Toggle at home".


## TODOs

- [ ] Which-key like global keymaps, and don't focus the window.
- [ ] A footer with the "quit" keymap indicator.

