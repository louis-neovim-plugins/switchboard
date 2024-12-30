
---@class SwitchboardBuiltins
---@field switches SwitchboardBuiltinSwitches
local M = { switches = {} }

---@alias SwitchboardSwitchGenerator fun(lhs: string, label?: string): SwitchboardSwitch

---@class SwitchboardBuiltinSwitches
---@field make_inlay_hints_switch SwitchboardSwitchGenerator
---@field make_diagnostics_switch SwitchboardSwitchGenerator
---@field make_relative_line_numbers_switch SwitchboardSwitchGenerator
---@field make_line_wrap_switch SwitchboardSwitchGenerator

function M.switches.make_inlay_hints_switch(lhs, label)
    return {
        label = label or "Inlay hints",
        is_on = function () return vim.lsp.inlay_hint.is_enabled() end,
        keymap = {
            lhs,
            function ()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end,
        },
    }
end

function M.switches.make_diagnostics_switch(lhs, label)
    return {
        label = label or "Diagnostics",
        is_on = function () return vim.diagnostic.is_enabled() end,
        keymap = {
            lhs,
            function () vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
        },
    }
end

function M.switches.make_relative_line_numbers_switch(lhs, label)
    return {
        label = label or "Relative line numbers",
        is_on = function () return vim.o.relativenumber end,
        keymap = {
            lhs,
            function () vim.o.relativenumber = not vim.o.relativenumber end,
        },
    }
end

function M.switches.make_line_wrap_switch(lhs, label)
    return {
        label = label or "Line wrap",
        is_on = function () return vim.wo.wrap end,
        keymap = {
            lhs,
            function () vim.wo.wrap = not vim.wo.wrap end,
        },
    }
end


return M

