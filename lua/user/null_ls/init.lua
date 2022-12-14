local M = {}

M.config = function()
    local status_ok, nls = pcall(require, "null-ls")
    if not status_ok then
        return
    end

    local sources = {}
    local js_ts = require("user.null_ls.js_ts").config(nls)

    for _, source in ipairs(js_ts) do
        table.insert(sources, source)
    end

    if lvim.builtin.refactoring.active then
        table.insert(sources, nls.builtins.code_actions.refactoring.with {
            filetypes = {"typescript", "javascript", "lua", "c", "cpp", "go", "python", "java", "php"}
        })
    end

    nls.setup {
        on_attach = require("lvim.lsp").common_on_attach,
        debounce = 150,
        save_after_format = false,
        sources = sources
    }
end

return M

