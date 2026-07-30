if vim.b.did_switchboard_ftplugin == 1 then
    print('already did ftplugin')
    return
end
vim.b.did_switchboard_ftplugin = 1

print('ftplugin')

local constants = require("switchboard.constants")
local hl_groups = require("switchboard.types.enums").swichboard_hl_group
local Switchboard = require("switchboard")

vim.b.modifiable = false
vim.b.swapfile = false
vim.b.buftype = "nofile"
vim.b.filetype = constants.filetype

vim.w.scrolloff = 0
vim.w.sidescrolloff = 0


local bufnr = vim.api.nvim_get_current_buf()


-- vim.api.nvim_create_autocmd("WinLeave", {
--     callback = function ()
--         vim.api.nvim_win_hide(Switchboard.win_id)
--         Switchboard.show_cursor()
--         Switchboard.board_is_visible = false
--     end,
--     buffer = bufnr,
-- })
-- vim.api.nvim_create_autocmd("WinEnter", {
--     callback = function()
--         Switchboard.hide_cursor()
--         Switchboard.board_is_visible = true
--     end,
--     buffer = bufnr,
-- })


for group_name, def in pairs(Switchboard.final_opts.highlight_groups) do
    vim.api.nvim_set_hl(0, group_name, def)
end


Switchboard.create_keymaps()

