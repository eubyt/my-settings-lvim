local M = {}

M.config = function()
    local status_ok, nls = pcall(require, "null-ls")
    if not status_ok then
        return
    end
    local semgrep_rule_folder = os.getenv "HOME" .. "/.config/semgrep/semgrep-rules/"
    local use_semgrep = false
    if vim.fn.filereadable(semgrep_rule_folder .. "template.yaml") then
        use_semgrep = true
    end

    local custom_go_actions = require "user.null_ls.go"
    local custom_md_hover = require "user.null_ls.markdown"
    local eslintrc = {".eslintrc", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml", ".eslintrc.js"}
    local sources = { -- NOTE: npm install -g prettier prettier-plugin-solidity
    nls.builtins.formatting.prettier.with {
        filetypes = {"solidity"},
        timeout = 10000
    }, nls.builtins.formatting.prettierd.with {
        condition = function(utils)
            return utils.root_has_file {"prettier.config.js", ".prettierrc", ".prettierrc.json", ".prettierrc.yaml",
                                        ".prettierrc.yml", ".prettierrc.js"}
        end,
        prefer_local = "node_modules/.bin"
    }, nls.builtins.formatting.eslint_d.with {
        condition = function(utils)
            return utils.root_has_file {eslintrc}
        end,
        prefer_local = "node_modules/.bin"
    }, nls.builtins.formatting.stylua, nls.builtins.formatting.goimports, nls.builtins.formatting.cmake_format,
    nls.builtins.formatting.scalafmt, nls.builtins.formatting.sqlformat, nls.builtins.formatting.terraform_fmt,
    -- Support for nix files
    nls.builtins.formatting.alejandra, nls.builtins.formatting.shfmt.with {
        extra_args = {"-i", "2", "-ci"}
    }, nls.builtins.formatting.black.with {
        extra_args = {"--fast"},
        filetypes = {"python"}
    }, nls.builtins.formatting.isort.with {
        extra_args = {"--profile", "black"},
        filetypes = {"python"}
    }, nls.builtins.diagnostics.ansiblelint.with {
        condition = function(utils)
            return utils.root_has_file "roles" and utils.root_has_file "inventories"
        end
    }, nls.builtins.diagnostics.solhint.with {
        condition = function(utils)
            return utils.root_has_file ".solhint.json"
        end
    }, nls.builtins.diagnostics.hadolint, nls.builtins.diagnostics.eslint_d.with {
        condition = function(utils)
            return utils.root_has_file {eslintrc}
        end,
        prefer_local = "node_modules/.bin"
    }, nls.builtins.diagnostics.semgrep.with {
        condition = function(utils)
            return utils.root_has_file ".semgrepignore" and use_semgrep
        end,
        extra_args = {"--metrics", "off", "--exclude", "vendor", "--config", semgrep_rule_folder}
    }, nls.builtins.diagnostics.luacheck, nls.builtins.diagnostics.vint, nls.builtins.diagnostics.chktex, -- Support for nix files
    nls.builtins.diagnostics.deadnix, nls.builtins.diagnostics.statix, nls.builtins.diagnostics.markdownlint.with {
        filetypes = {"markdown"}
    }, nls.builtins.diagnostics.vale.with {
        filetypes = {"markdown"}
    }, nls.builtins.diagnostics.revive.with {
        condition = function(utils)
            return utils.root_has_file "revive.toml"
        end
    }, nls.builtins.diagnostics.golangci_lint.with {
        condition = function(utils)
            return utils.root_has_file ".golangci.yml"
        end
    }, nls.builtins.code_actions.eslint_d.with {
        condition = function(utils)
            return utils.root_has_file {eslintrc}
        end,
        prefer_local = "node_modules/.bin"
    }, custom_go_actions.gomodifytags, custom_go_actions.gostructhelper, custom_md_hover.dictionary}

    -- if lvim.builtin.refactoring.active then
    --     table.insert(sources, nls.builtins.code_actions.refactoring.with {
    --         filetypes = {"typescript", "javascript", "lua", "c", "cpp", "go", "python", "java", "php"}
    --     })
    -- end

    local setup_code_actions = require("lvim.lsp.null-ls.code_actions").setup
    local refactorin_opts = nls.builtins.code_actions.refactoring.with {
        filetypes = {"typescript", "javascript", "lua", "c", "cpp", "go", "python", "java", "php"}
    }
    setup_code_actions {refactorin_opts}

    nls.setup {
        on_attach = require("lvim.lsp").common_on_attach,
        debounce = 150,
        save_after_format = false,
        sources = sources
    }
end

return M
