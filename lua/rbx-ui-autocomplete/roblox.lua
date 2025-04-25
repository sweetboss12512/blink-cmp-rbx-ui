local curl = require("plenary.curl") -- I have no idea how to use this!
local json = require("rbx-ui-autocomplete.json")

local API_DOCS_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/api-docs/en-us.json"
local API_DUMP_URL =
    "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/Mini-API-Dump.json"
local DOCS_FILE = "api-docs.json"
local API_FILE = "api-dump.json"

local function is_dir(path)
    local stat = vim.uv.fs_stat(path)
    return stat and stat.type == "directory" or false
end

local function storage_file(key)
    local path = vim.fs.joinpath(vim.fn.stdpath("data"), "rbx-ui-autocomplete")
    if not is_dir(path) then
        vim.fn.mkdir(path, "p")
    end

    return vim.fs.joinpath(path, key)
end

local download_api = function()
    curl.get(API_DUMP_URL, {
        output = storage_file(DOCS_FILE),
        on_error = function()
            print("Failed to request api-docs.json")
        end,
    })

    curl.get(API_DOCS_URL, {
        output = storage_file(API_FILE),
        on_error = function()
            print("Failed to request api-dump.json")
        end,
    })
end

coroutine.resume(coroutine.create(download_api))

return {
    api_docs = json.from_path(storage_file(API_FILE)),
    api_dump = json.from_path(storage_file(DOCS_FILE)),
}
