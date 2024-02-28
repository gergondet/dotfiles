local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if not vim.loop.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require('lazy').setup({
  { 'tiagovla/tokyodark.nvim' },
  { 'nvim-treesitter/nvim-treesitter' },
  { 'tpope/vim-fugitive' },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim' },           -- Optional
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },     -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      {
        'L3MON4D3/LuaSnip',
        dependencies = { "rafamadriz/friendly-snippets" }
      }, -- Required
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      {
        'ray-x/lsp_signature.nvim',
        event = 'VeryLazy',
        opts = {},
        config = function(_, opts) require 'lsp_signature'.setup(opts) end
      }
    }
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  { 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
  { 'tiagovla/scope.nvim' },
  {
    'metalelf0/jellybeans-nvim',
    dependencies = { 'rktjmp/lush.nvim' }
  },
  { 'sainnhe/sonokai' },
  { 'nvim-tree/nvim-tree.lua' },
  { 'mhartington/formatter.nvim' },
  {
    'folke/trouble.nvim',
    opts = {
      auto_preview = false
    }
  },
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    lazy = false,
  },
})

local lsp = require('lsp-zero').preset({ name = 'recommended' })

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  -- Use Format if we configured it, otherwise LSP if it provides formatting, otherwise Format with a warning
  if vim.g.formatter_config.filetype[vim.bo.filetype] ~= nil
  then
    vim.keymap.set('n', '<F3>', ':Format<cr>', bufopts)
  elseif client.server_capabilities.documentFormattingProvider
  then
    vim.keymap.set('n', '<F3>', function() vim.lsp.buf.format { async = true, range = nil, } end, bufopts)
  else
    print("No LSP formatter for " .. vim.bo.filetype .. " and no formatter config")
    vim.keymap.set('n', '<F3>', ':Format<cr>', bufopts)
  end
  -- Same as lsp-zero defaults but opens in a new tab
  vim.keymap.set('n', 'gd', '<cmd>tab split | lua vim.lsp.buf.definition()<cr>', { buffer = bufnr })
  vim.keymap.set('n', 'gD', '<cmd>tab split | lua vim.lsp.buf.declaration()<cr>', { buffer = bufnr })
  vim.keymap.set('n', 'gi', '<cmd>tab split | lua vim.lsp.buf.implementation()<cr>', { buffer = bufnr })
  vim.keymap.set('n', 'go', '<cmd>tab split | lua vim.lsp.buf.type_definition()<cr>', { buffer = bufnr })
  -- Same as lsp-zero defaults but with f
  vim.keymap.set('n', 'fd', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = bufnr })
  vim.keymap.set('n', 'fD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { buffer = bufnr })
  vim.keymap.set('n', 'fi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { buffer = bufnr })
  -- Open references in Telescope instead of scratchpad
  vim.keymap.set('n', 'gR', function() require('telescope.builtin').lsp_references() end,
    { buffer = bufnr, silent = true })
  -- Apply fix, skip selection if only one
  vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.code_action({apply = true})<cr>', { buffer = bufnr })
end)

-- Formatter configuration
vim.g.formatter_config = {
  filetype = {
    c = {
      require('formatter.filetypes.c').clangformat
    },
    cmake = {
      require('formatter.filetypes.cmake').cmakeformat
    },
    cpp = {
      require('formatter.filetypes.cpp').clangformat
    },
    html = {
      require('formatter.filetypes.markdown').prettier
    },
    json = {
      require('formatter.filetypes.json').prettier
    },
    markdown = {
      require('formatter.filetypes.markdown').prettier
    },
    python = {
      require('formatter.filetypes.python').black
    },
    rust = {
      require('formatter.filetypes.rust').rustfmt
    },
    sh = {
      require('formatter.filetypes.sh').shfmt
    },
    xml = {
      require('formatter.filetypes.xml').tidy
    },
    yaml = {
      require('formatter.filetypes.yaml').prettier
    },
    zsh = {
      require('formatter.filetypes.zsh').beautysh
    },
  }
}

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

require 'lspconfig'.cmake.setup {
  init_options = {
    buildDirectory = "build/"
  }
}

require 'lspconfig'.clangd.setup {
  cmd = {
    'clangd',
    '--background-index',
    '--function-arg-placeholders',
    '--completion-style=detailed',
    '--header-insertion=never',
    '--clang-tidy'
  }
}

require("lsp_signature").setup({
  hint_enable = false,
})

lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path',    option = { trailing_slash = true } },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
  mapping = {
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
    ['<Down>'] = cmp_action.luasnip_supertab(),
    ['<Up>'] = cmp_action.luasnip_shift_supertab(),
  }
})

require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "cmake", "cpp", "lua", "vim", "vimdoc", "query", "yaml", "json", "python" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = true,
    -- Disable treesitter in big files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
}

-- Quit telescope with a single hit of the escape key
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    sorting_strategy = 'ascending',
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-Down>"] = require('telescope.actions').cycle_history_next,
        ["<C-Up>"] = require('telescope.actions').cycle_history_prev,
        ['<C-d>'] = require('telescope.actions').delete_buffer
      },
    },
  },
})

-- Telescope bindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, {})
vim.keymap.set('n', 'fF', function() builtin.find_files({ no_ignore = true }) end, {})
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})
vim.keymap.set('n', 'fb', builtin.buffers, {})
vim.keymap.set('n', 'fh', builtin.help_tags, {})
vim.keymap.set('n', 'fd', ':TroubleToggle<cr>', {})
vim.keymap.set('n', 'tf', function() require("trouble").first({ skip_groups = true, jump = true }) end, {})
vim.keymap.set('n', 'tl', function() require("trouble").last({ skip_groups = true, jump = true }) end, {})
vim.keymap.set('n', 'tn', function() require("trouble").next({ skip_groups = true, jump = true }) end, {})
vim.keymap.set('n', 'tp', function() require("trouble").previous({ skip_groups = true, jump = true }) end, {})
vim.keymap.set('n', 'fo', builtin.oldfiles, {})

local cwd = vim.uv.cwd()

vim.keymap.set('n', '<leader><PageUp>', ':bp<cr>')
vim.keymap.set('n', '<leader><PageDown>', ':bn<cr>')

vim.keymap.set('n', '<F12>', ':NvimTreeToggle<cr>')

-- Remember where we left off (Except in git commit)
if not string.match(vim.api.nvim_buf_get_name(0), '.*COMMIT_EDITMSG$')
then
  vim.cmd [[
    autocmd BufReadPost * silent! normal! g`"zv
  ]]
end

-- Auto-format if we are outside a git repo or if the repo has .clang-format
local cwd = vim.uv.cwd()
local git_folder = cwd .. '/.git'
local clang_format_file = cwd .. '/.clang-format'
local clang_format_common = cwd .. '/.clang-format-common.sh'

if vim.fn.filereadable(clang_format_common) == 1
then
  vim.g['ClangFormatAuto'] = false;
  -- Auto-enable ClangFormat if we are outside a git folder or inside a git folder with a .clang-format file
elseif (vim.fn.isdirectory(git_folder) == 1 or vim.fn.filereadable(git_folder) == 1) and vim.fn.filereadable(clang_format_file) == 0
then
  vim.g['ClangFormatAuto'] = true;
else
  vim.g['ClangFormatAuto'] = false;
end

-- Options
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.termguicolors = true
vim.opt.undofile = true                                   -- persistent undo
vim.opt.matchpairs = "(:),{:},[:],<:>"
vim.opt.wildignore = '*.o,*.obj,*~,*.so,*.swp,*.DS_Store' -- stuff to ignore when tab completing
vim.opt.wildmode = 'list:longest,list:full'
vim.opt.list = true
vim.opt.listchars = 'tab:>-,trail:-'
-- vim.opt.foldmethod = 'indent'
-- vim.opt.foldlevel = 12
vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 100
-- Makes the diagnostic window nicer by adding indent after the list of issues
vim.opt.breakindent = true
vim.opt.breakindentopt = 'shift:2'
-- Colorscheme
vim.cmd [[
  au ColorScheme * hi Normal ctermbg=None guibg=None
  au BufNewFile,BufRead *.launch setf xml
  au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set syntax=glsl
]]
vim.cmd.colorscheme('sonokai')

local lualine_filename_config = { 'filename', path = 1 }
local lualine_winbar = { { 'filetype', icon_only = true, separator = '' }, 'filename' }

require('lualine').setup({
  options = { globalstatus = false },
  sections = {
    lualine_c = { lualine_filename_config }
  },
  inactive_sections = {
    lualine_c = { lualine_filename_config }
  },
  winbar = {
    lualine_c = lualine_winbar,
  },
  inactive_winbar = {
    lualine_c = lualine_winbar,
  },
})
require('bufferline').setup({
  options = {
    mode = "tabs",
    numbers = "ordinal",
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = false,
    show_duplicate_prefix = false,
    separator_style = "slant"
  }
})
require('nvim-tree').setup()

require("formatter").setup(vim.g.formatter_config)

local diagnostic_config = {
  virtual_text = false,
  signs = true,
  float = {
    border = "single",
    source = 'if_many',
    header = '',
    prefix =
        function(diagnostic, i, total)
          return '[' .. diagnostic.source .. ']'
        end,
    suffix = '',
    format =
        function(diagnostic)
          if diagnostic.severity == vim.diagnostic.severity.ERROR
          then
            out = '\n' .. diagnostic.message
            if diagnostic.user_data.lsp.relatedInformation
            then
              for key, value in pairs(diagnostic.user_data.lsp.relatedInformation)
              do
                out = out .. "\n\t. " .. value.message
                --out = out .. "\n\t" .. key .. ". " .. value.message
              end
            end
            return out
          end
          return diagnostic.message
        end
  }
}

-- disable virtual_text (inline) diagnostics and use floating window
-- format the message such that it shows source, message and
-- the error code. Show the message with <space>e
vim.diagnostic.config(diagnostic_config)

-- Function to check if a floating dialog exists and if not
-- then check for diagnostics under the cursor
function OpenDiagnosticIfNoFloat()
  --for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
  --  if vim.api.nvim_win_get_config(winid).zindex then
  --    return
  --  end
  --end
  -- THIS IS FOR BUILTIN LSP
  vim.diagnostic.open_float(0, {
    scope = "line",
    focusable = false,
    close_events = {
      "CursorMoved",
      "CursorMovedI",
      "BufHidden",
      "InsertCharPre",
      "WinLeave",
    },
  })
end

-- Show diagnostics under the cursor when holding position
vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  pattern = "*",
  command = "lua OpenDiagnosticIfNoFloat()",
  group = "lsp_diagnostics_hold",
})

-- Toggle current line or with count
vim.keymap.set('n', '<C-_>', function()
  return vim.v.count == 0
      and '<Plug>(comment_toggle_linewise_current)'
      or '<Plug>(comment_toggle_linewise_count)'
end, { expr = true })
-- Toggle in VISUAL mode
vim.keymap.set('x', '<C-_>', '<Plug>(comment_toggle_linewise_visual)')

-- Always enabled Formatter
vim.keymap.set('n', '<F3>', ':Format<cr>', { noremap = true, silent = true })

-- Disable LSP logging
vim.lsp.set_log_level("off")
