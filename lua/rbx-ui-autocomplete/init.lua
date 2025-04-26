local ts_utils = require("nvim-treesitter.ts_utils")
local get_class_completions = require("rbx-ui-autocomplete.get_class_completions")
local config = require("rbx-ui-autocomplete.config")
local roblox = require("rbx-ui-autocomplete.roblox")

local class_name_query = vim.treesitter.query.parse(
    "luau",
    [[ (function_call arguments: (arguments (string content: (string_content) @instance_name))) ]]
)
local creator_query = assert(vim.treesitter.query.get("luau", "rbx-ui-creator"), "Failed to get rbx-ui-creator query") -- Should be extendable

---@return string?
local function get_class_name()
    local current_node = ts_utils.get_node_at_cursor(0)

    if not current_node or current_node:type() ~= "table_constructor" then
        return
    end

    while current_node:type() ~= "function_call" do
        current_node = current_node:parent()

        if not current_node then
            return
        end
    end

    for _, node in class_name_query:iter_captures(current_node, "luau", 0) do
        return vim.treesitter.get_node_text(node, 0)
    end
end

---@return boolean
local function is_in_creator()
    local current_node = ts_utils.get_node_at_cursor(0)

    if not current_node then
        return false
    end

    if not vim.tbl_contains({ "string_content", "string" }, current_node:type()) then
        return false
    end

    while current_node:type() ~= "function_call" do
        current_node = current_node:parent()

        if not current_node then
            return false
        end
    end

    for _, node in creator_query:iter_captures(current_node, 0) do
        local node_text = string.lower(vim.treesitter.get_node_text(node, 0))

        for _, alias in ipairs(config.current.complete_aliases) do
            if string.lower(alias) == node_text then
                return true
            end
        end
    end

    return false
end

local instance_names = {} ---@type blink.cmp.CompletionItem[]
local properties_cache = {} ---@type blink.cmp.CompletionItem[]

---@param items blink.cmp.CompletionItem[]
---@param context blink.cmp.Context
local function apply_cursors(items, context)
    return vim.tbl_map(function(entry)
        local tbl = vim.tbl_deep_extend("force", entry, {
            textEdit = {
                range = {
                    start = { line = context.cursor[1] - 1, character = context.bounds.start_col - 1 },
                    ["end"] = { line = context.cursor[1] - 1, character = context.cursor[2] },
                },
            },
        })

        return tbl
    end, items)
end

local function make_lsp_happy() end

---@type blink.cmp.Source
---@diagnostic disable-next-line: missing-fields
local source = {}

function source.new(opts)
    local self = setmetatable({}, { __index = source })
    config.setup(opts)

    for _, class in ipairs(roblox.api_dump.Classes) do
        table.insert(instance_names, {
            kind = require("blink.cmp.types").CompletionItemKind.Class,
            label = class.Name,
            textEdit = { newText = class.Name },
        })
        properties_cache[class.Name] = get_class_completions(class)
    end

    return self
end

function source:enabled()
    -- FIXME: blink gets really slow with only the filetype check.
    return vim.bo.filetype == "luau" and (is_in_creator() == true or get_class_name() ~= nil)
end

---@param context blink.cmp.Context
function source:get_completions(context, callback)
    ---@diagnostic disable-next-line: redefined-local
    local completions
    local class_name = get_class_name()

    if is_in_creator() then
        completions = instance_names
    elseif class_name then
        completions = properties_cache[class_name]
    end

    if not completions then
        return make_lsp_happy
    end

    callback({
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = apply_cursors(completions, context),
        context = context,
    })

    return make_lsp_happy
end

return source
