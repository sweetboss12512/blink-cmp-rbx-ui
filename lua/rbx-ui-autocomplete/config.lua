local M = {}

---@class rbx-ui.Config
local defaults = {
    complete_aliases = {
        "create", -- Vide
        "scope:new", -- Fusion 0.3
    },
    complete_snippets = {
        enabled = true,
        enums = true,
        ---@type string[]
        completions = {
            CFrame = "CFrame.new($0)",
            Color3 = "Color3.new($0)",
            ColorSequence = "ColorSequence.new($0)",
            ColorSequenceKeypoint = "ColorSequenceKeypoint.new($0)",
            NumberRange = "NumberRange.new($0)",
            NumberSequence = "NumberSequence.new($0)",
            NumberSequenceKeypoint = "NumberSequenceKeypoint.new($0)",
            PhysicalProperties = "PhysicalProperties.new($0)",
            Ray = "Ray.new($0)",
            Rect = "Rect.new($0)",
            Region3 = "Region3.new($0)",
            Region3int16 = "Region3int16.new($0)",
            UDim = "UDim.new($0)",
            UDim2 = "UDim2.new($0)",
            Vector2 = "Vector2.new($0)",
            Vector2int16 = "Vector2int16.new($0)",
            Vector3 = "Vector3.new($0)",
            Vector3int16 = "Vector3int16.new($0)",
        },
    },
}

M.current = vim.deepcopy(defaults)
M.defaults = defaults

---@param opts rbx-ui.Config
function M.setup(opts)
    M.current = vim.tbl_deep_extend("force", defaults, opts)
end

return M
