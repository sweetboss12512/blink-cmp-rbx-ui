local cmp_types = require("blink.cmp.types")
local config = require("rbx-ui-autocomplete.config")
local roblox = require("rbx-ui-autocomplete.roblox")

local ignore_tags = {
    "ReadOnly",
    "Hidden",
    "Deprecated",
}
local include_member_types = {
    "Property",
    "Event",
}
local docstring_format = [[
%s

[Learn More](%s)
]]

---@param class_name string
---@param property_name string
local function get_property_docs(class_name, property_name)
    local key = ("@roblox/globaltype/%s.%s"):format(class_name, property_name)
    local info = roblox.api_docs[key]

    if not info then
        return
    end

    return string.format(docstring_format, info.documentation, info.learn_more_link)
end

---@param class table
---@return blink.cmp.CompletionItem[]
local function get_class_completions(class)
    local properties = {}

    for _, member in ipairs(class.Members) do
        if vim.tbl_contains(include_member_types, member.MemberType) == false then
            goto continue
        end

        if member.Tags then
            local exclude = false
            for _, name in ipairs(ignore_tags) do
                if vim.tbl_contains(member.Tags, name) then
                    exclude = true
                    break
                end
            end

            if exclude then
                goto continue
            end
        end

        local type_text =
            config.current.complete_snippets.completions[member.ValueType and member.ValueType.Name or member.MemberType]

        if type_text and type_text ~= "" and config.current.complete_snippets.enabled then
            type_text = type_text .. ","
        else
            type_text = ""
        end

        if member.ValueType and member.ValueType.Category == "Enum" and config.current.complete_snippets.enums then
            type_text = "Enum." .. member.ValueType.Name .. "."
        end

        table.insert(properties, {
            label = member.Name,
            kind = member.MemberType == "Property" and cmp_types.CompletionItemKind.Property
                or cmp_types.CompletionItemKind.Event,
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
            textEdit = { newText = ("%s = %s"):format(member.Name, type_text) },
            documentation = {
                kind = "markdown",
                value = get_property_docs(class.Name, member.Name) or "",
            },
        })

        ::continue::
    end

    if class.Superclass then
        for _, randomClass in ipairs(roblox.api_dump.Classes) do
            if randomClass.Name == class.Superclass then
                local inherited = get_class_completions(randomClass)
                for _, v in ipairs(inherited) do
                    table.insert(properties, v)
                end
            end
        end
    end

    return properties
end

return get_class_completions
