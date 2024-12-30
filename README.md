# Switchboard

If you have a growing number of "toggle this" and "switch that" keymaps, this
plugin allows you to group all of these "switches" in one place and provides a
neat little "switchboard" listing all switch positions and their associated
keymaps.

![Screenshot](https://github.com/user-attachments/assets/ba05592e-7285-4e06-ae93-04d9652960f1)


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
local hl_groups = require("switchboard.types").highlight_groups

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
        [hl_groups.SwitchboardKeymapLhs] = { link = "WhichKey"           },
        [hl_groups.SwitchboardSeparator] = { link = "WhichKeySeparator"  },
        [hl_groups.SwitchboardIconOn   ] = { link = "WhichKeyIconGreen"  },
        [hl_groups.SwitchboardIconOff  ] = { link = "WhichKeyIconOrange" },
        [hl_groups.SwitchboardLabel    ] = { link = "WhichKeyDesc"       },
    },
    switches = {},
}
```

> [!WARNING]
> The highlight groups are linked to the [which-key.nvim](https://github.com/folke/which-key.nvim)
> highlight groups by default. If you do not use which-key, you should define
> your own colors or links.

---

You need to provide your `switches` like so:
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


## FAQ

Q: Can Switchboard handle other positions than "on" or "off"?  
A: No.


## Similar plugins

This plugin is my attempt at reproducting [Snacks.toggle](https://github.com/folke/snacks.nvim/blob/main/docs/toggle.md),
I wasn't happy about the documentation, couldn't make it work, the customization options seemed very limited, and the code is unreadable to me.
A week-end later and voilà, "we have Toggle at home".


## TODOs

- [ ] Figure out what to do with the cursor. It'd be nice if it stayed in place
      when we open the window.
- [ ] Scrolling?

