local roblox = require("rbx-ui-autocomplete.roblox")

local docstring_format = [[
%s

[Learn More](%s)
]]

---@param class_name string
---@param property_name string
---@return string?
local function get_property_docs(class_name, property_name)
    local key = ("@roblox/globaltype/%s.%s"):format(class_name, property_name)
    local info = roblox.api_docs[key]

    if not info then
        return
    end

    return string.format(docstring_format, info.documentation, info.learn_more_link)
end

return get_property_docs
