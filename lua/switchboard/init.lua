local constants = require("switchboard.constants")
local hl_groups = require("switchboard.types.enums").swichboard_hl_group
local default_opts = require("switchboard.default_opts").default_opts


---@type integer
local original_cursor_blend = 0


local commands_set = false
local hl_groups_set = false


---Switchboard main class.
---
---@class Switchboard
---@field bufnr integer
---@field win_id integer
---@field final_opts SwitchboardOpts
---
---@field private final_window_width integer
---@field private final_window_height integer
---@field private ns_id integer
---@field private previous_win_id integer Winid of the window we triggered Switchboard from.
---@field private previous_bufnr integer Bufnr of the buffer we triggered Switchboard from.
---@field private board_is_visible boolean Wether the Switchboard panel is visible or not.
local Switchboard = {}



---Hides the cursor.
---
function Switchboard.hide_cursor()
    -- We don't need to hide again if we are just refreshing the board.
    -- And we avoid overwriting the cache with invalid values.
    if Switchboard.board_is_visible then return end

    -- Disable smear_cursor as the smear / trail to the window is not exactly
    -- visually pleasing.
    local ok, smear = pcall(require, "smear_cursor")
    if ok then
        smear.setup({ smear_between_buffers = false })
    end

    local hl = vim.api.nvim_get_hl(0, { name = "Cursor" })
    original_cursor_blend = hl.blend or 0
    hl.blend = 100
    vim.opt.guicursor:append('a:Cursor/lCursor')

    ---@diagnostic disable-next-line
    vim.api.nvim_set_hl(0, "Cursor", hl)
end


---Shows the cursor again. Basically undoes everything the hide_cursor()
---function does.
---
function Switchboard.show_cursor()
    local hl = vim.api.nvim_get_hl(0, { name = "Cursor" })
    hl.blend = original_cursor_blend
    ---@diagnostic disable-next-line
    vim.api.nvim_set_hl(0, "Cursor", hl)

    vim.opt.guicursor:remove('a:Cursor/lCursor')
end


---"Constructor" for the Switchboard class.
---
---@param opts UserSwitchboardOpts
function Switchboard.setup(opts)
    Switchboard.final_opts = vim.tbl_deep_extend("force", default_opts, opts)
    -- Switchboard.create_hl_groups()
    Switchboard.create_commands()

    Switchboard.final_window_width = Switchboard.final_opts.window.min_width or 0
    Switchboard.final_window_height = Switchboard.final_opts.window.min_height or 0

    -- Create or get the namespace.
    Switchboard.ns_id = vim.api.nvim_create_namespace(constants.namespace)
end


---Creates autocommands for the Switchboard window.
---
function Switchboard.create_autocmds()
    -- Note: It looks like the event is not triggering when we replace the
    -- window and buffer.
    vim.api.nvim_create_autocmd("WinLeave", {
        callback = function ()
            vim.api.nvim_win_hide(Switchboard.win_id)
            Switchboard.show_cursor()
            Switchboard.board_is_visible = false
        end,
        buffer = Switchboard.bufnr,
    })
    vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
            Switchboard.hide_cursor()
            Switchboard.board_is_visible = true
        end,
        buffer = Switchboard.bufnr,
    })
end


---Create the Switchboard highlight groups only once ever.
---
function Switchboard.create_hl_groups()
    if hl_groups_set then return end
    hl_groups_set = true

    print('create hl groups')

    for group_name, def in pairs(Switchboard.final_opts.highlight_groups) do
        vim.api.nvim_set_hl(0, group_name, def)
    end
end


---Creates the keymaps for the current Switchboard buffer.
---
function Switchboard.create_keymaps()
    -- Disable undesirable keys.
    local keys_to_be_disabled = { "i", "I", "a", "A", "r", "R", "v", "V", "" }
    for _, key in pairs(keys_to_be_disabled) do
        vim.keymap.set("n", key, "<nop>", { buffer = Switchboard.bufnr })
    end

    -- Keymaps to quit the window.
    local escape_lhs_list = { "q", "<C-[>", "<Esc>" }
    for _, lhs in pairs(escape_lhs_list) do
        vim.keymap.set(
            "n",
            lhs,
            function () vim.api.nvim_win_hide(Switchboard.win_id) end,
            { buffer = Switchboard.bufnr }
        )
    end

    -- Define the mappings for the switches.
    for _, switch in pairs(Switchboard.final_opts.switches) do
        vim.keymap.set(
            "n",
            switch.keymap[1],
            Switchboard.wrap_keymap_rhs(switch),
            { buffer = Switchboard.bufnr }
        )
    end
end


---Creates the Switchboard buffer and its contents.
---
function Switchboard.create_buffer()
    Switchboard.bufnr = vim.api.nvim_create_buf(false, true)

    ---@type SwitchboardLineElement[][]
    local all_lines_elements = {}

    ---@type string[]
    local buffer_contents = {}

    for _, switch in pairs(Switchboard.final_opts.switches) do
        local ok, is_on = pcall(switch.is_on)
        if not ok then
            vim.notify_once(
                "Failed to get swtich status for switch \"" .. switch.label .. "\".",
                vim.log.levels.ERROR,
                { title = "Switchboard configuration error." }
            )

            goto continue
        end

        local icon = is_on
            and Switchboard.final_opts.icons.is_on
            or Switchboard.final_opts.icons.is_off

        ---@type SwitchboardLineElement[]
        local line_elements = {
            {
                text = " ",
                highlight_group = "NormalFloat",
            },
            {
                text = switch.keymap[1],
                highlight_group = hl_groups.SwitchboardKeymapLhs,
            },
            {
                text = " ",
                highlight_group = "NormalFloat",
            },
            {
                text = Switchboard.final_opts.icons.separator,
                highlight_group = hl_groups.SwitchboardSeparator,
            },
            {
                text = " ",
                highlight_group = "NormalFloat",
            },
            {
                text = icon,
                highlight_group = is_on
                    and hl_groups.SwitchboardIconOn
                    or hl_groups.SwitchboardIconOff,
            },
            {
                text = " ",
                highlight_group = "NormalFloat",
            },
            {
                text = switch.label,
                highlight_group = hl_groups.SwitchboardLabel,
            },
        }
        table.insert(all_lines_elements, line_elements)

        ---@type string[]
        local text_elements = vim.tbl_map(
            function (element) return element.text end,
            line_elements
        )

        local line = table.concat(text_elements)
        table.insert(buffer_contents, line)

        Switchboard.final_window_width = math.max(
            Switchboard.final_window_width,
            -- This is not accurate as some symbols can take multiple cells.
            string.len(line)
        )

        ::continue::
    end


    Switchboard.final_window_height = math.max(
        Switchboard.final_window_height,
        vim.tbl_count(buffer_contents)
    )

    vim.api.nvim_buf_set_lines(Switchboard.bufnr, 0, -1, true, buffer_contents)

    vim.bo[Switchboard.bufnr].modifiable = false
    vim.bo[Switchboard.bufnr].swapfile = false
    vim.bo[Switchboard.bufnr].buftype = "nofile"
    vim.bo[Switchboard.bufnr].filetype = constants.filetype

    Switchboard.highlight_buffer(all_lines_elements)
end


---Highlight the current Switchboard buffer.
---This needs the buffer to have its contents set already, otherwise you will
---get range errors.
---
---@param all_lines_elements SwitchboardLineElement[][]
function Switchboard.highlight_buffer(all_lines_elements)
    for line_number, line_elements in ipairs(all_lines_elements) do
        local line_length = 0
        for _, element in pairs(line_elements) do
            local text_length = string.len(element.text)

            vim.api.nvim_buf_set_extmark(
                Switchboard.bufnr,
                Switchboard.ns_id,
                line_number - 1,
                line_length,
                {
                    hl_group = element.highlight_group,
                    end_col = line_length + text_length,
                }
            )

            line_length = line_length + text_length
        end
    end
end


---Wraps a keymap rhs command / function to catch errors and update the UI
---when it has completed its job.
---
---@param switch SwitchboardSwitch
---@return function
function Switchboard.wrap_keymap_rhs(switch)
    local rhs = switch.keymap[2]

    local function safe_rhs()
        if type(rhs) == "string" then
            -- TODO: Almost certainly wrong.
            -- vim.cmd(rhs)
        else
            local ok = pcall(rhs)
            if not ok then
                vim.notify_once(
                    "Failed to execute rhs for switch \"" .. switch.label .. "\".",
                    vim.log.levels.ERROR,
                    { title = "Switchboard configuration error." }
                )
            end
        end

        Switchboard.update()
    end

    return function ()
        -- It's important to place ourselves in the context of the window we
        -- were in when we opened Switchboard.
        vim.api.nvim_win_call(
            Switchboard.previous_win_id,
            safe_rhs
        )
    end
end


---Completely replace the current buffer and window if any.
---
function Switchboard.update()
    -- Warn when the switchboard is opened from a 'nofile' buffer.
    if vim.api.nvim_get_option_value("buftype", {}) == "nofile" then
        local ft = vim.api.nvim_get_option_value("filetype", {})
        if(ft == constants.filetype) {

        }

        vim.notify(
            "Filetype is " .. ft .. ", in a 'nofile' buffer.",
            vim.log.levels.WARN,
            { title = "Switchboard warning." }
        )
    end

    -- Close the current switchboard window if any is present.
    if Switchboard.win_id and vim.api.nvim_win_is_valid(Switchboard.win_id) then
        vim.api.nvim_win_close(Switchboard.win_id, true)
    end
    if Switchboard.bufnr then vim.api.nvim_buf_delete(Switchboard.bufnr, {}) end

    local previous_bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[previous_bufnr].filetype ~= constants.filetype then
        Switchboard.previous_bufnr = previous_bufnr
        Switchboard.previous_win_id = vim.api.nvim_get_current_win()
    end

    Switchboard.create_buffer()
    Switchboard.draw_window()
    -- Done in ftplugin now.
    -- Switchboard.create_keymaps()
    -- Switchboard.create_autocmds()

    -- We need to enter the window after we set the autocommands.
    vim.api.nvim_set_current_win(Switchboard.win_id)
end


---Creates a new window to display the current buffer.
---
function Switchboard.draw_window()
    -- Calculate where the bottom of the window should be, this is to avoid
    -- covering the statusline and command line.
    local editor_height = vim.o.lines
    local cmdline_height = vim.o.cmdheight
    local statusline_height = vim.o.statusline and 1 or 0
    local bottom_position = editor_height - statusline_height - cmdline_height

    -- Force a few window options, in case the user got "creative".
    local win_opts = vim.tbl_extend("force",
        Switchboard.final_opts.window,
        {
            relative = "editor",
            anchor = "SE",

            -- Position.
            row = bottom_position,
            -- Neovim is smart enough not to place it outside the editor.
            col = 9999,

            -- Size.
            width = Switchboard.final_window_width,
            height = Switchboard.final_window_height,
        }
    )

    -- Nvim doesn't like additional keys, it will have none of your shit.
    win_opts.min_height = nil
    win_opts.min_width = nil


    Switchboard.win_id = vim.api.nvim_open_win(
        Switchboard.bufnr,
        false,
        win_opts
    )

    -- vim.wo[Switchboard.win_id].scrolloff = 0
    -- vim.wo[Switchboard.win_id].sidescrolloff = 0
end


function Switchboard.close()
    vim.api.nvim_win_hide(Switchboard.win_id)
end


function Switchboard.open()
    vim.api.nvim_win_hide(Switchboard.win_id)
end


function Switchboard.toggle()
    if  then
    else
        vim.api.nvim_win_hide(Switchboard.win_id)
    end
end


function is_open()

end


---Create the command line commands.
---
function Switchboard.create_commands()
    if commands_set then return end
    commands_set = true

    vim.api.nvim_create_user_command("Switchboard",
        function()
        -- function(opts)
            -- local arg = string.lower(opts.fargs[1])
            -- if arg == "on" then
            --     M.turn_on()
            -- end
            Switchboard.update()
        end,
        { desc = "Manage your Switchboard." }
    )
end


return Switchboard

