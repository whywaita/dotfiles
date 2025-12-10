set nocompatible
set number

syntax on
set tabstop=2
set shiftwidth=2
set expandtab

set autoindent
set smarttab

set backspace=indent,eol,start

set cursorline

set encoding=UTF-8
set fileencoding=UTF-8

set showmatch

filetype on
filetype plugin on
filetype indent on

augroup PrevimSettings
  autocmd!
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

let g:rc_dir = expand('~/dotfiles/nvim')

if !isdirectory(s:dein_repo_dir)
  execute '!git clone <https://github.com/Shougo/dein.vim>' s:dein_repo_dir
endif
execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " load the file which contain the plugin list
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:darkpower_toml      = g:rc_dir . '/dein_darkpower.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:darkpower_toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

lua << EOF
local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
 client.server_capabilities.documentFormattingProvider = false
 local set = vim.keymap.set
 set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
 set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
 set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
 set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
 set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
 set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
 set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
 set('n', 'gx', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
 set('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
 set('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
 set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  function(server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach,
    }
  end,
}
EOF
