-- (https://github.com/lopi-py/luau-lsp.nvim/blob/main/lua/luau-lsp/json.lua)

local M = {}

---@param str string
---@param opts? table<string, any>
---@return any
function M.decode(str, opts)
    str = str:gsub("//[^\n]*", "")
        :gsub("/%*.-%*/", "")
        :gsub(",%s*([}%]])", "%1")
        :gsub("([%{%s,])([%a_][%w_]*)%s*:", '%1"%2":')

    return vim.json.decode(str, opts or {})
end

---@param path string The path to the file
---@return table
function M.from_path(path)
    local fd = assert(vim.uv.fs_open(path, "r", 420)) -- 0644
    local stat = assert(vim.uv.fs_fstat(fd))
    local content = vim.uv.fs_read(fd, stat.size)
    vim.uv.fs_close(fd)

    ---@cast content string
    -- return M.decode(content, { luanil = { object = true } })
    return vim.json.decode(content, { luanil = { object = true } })
end

return M
