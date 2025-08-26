---@class SwitchboardBuiltins
---@field switches SwitchboardBuiltinSwitches


--- Function that generates a switch.
---
---@alias SwitchboardSwitchGenerator fun(lhs: string, label?: string): SwitchboardSwitch


--- A table with a bunch of helper functions to quickly make switches for common
--- things.
---@class SwitchboardBuiltinSwitches
---@field make_inlay_hints_switch SwitchboardSwitchGenerator
---@field make_diagnostics_switch SwitchboardSwitchGenerator
---@field make_relative_line_numbers_switch SwitchboardSwitchGenerator
---@field make_line_wrap_switch SwitchboardSwitchGenerator

