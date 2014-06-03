set nocompatible
set number
syntax on
set tabstop=4
set shiftwidth=4
set noexpandtab

if has('vim_starting')
   set nocompatible               " Be iMproved
   set runtimepath+=~/.vim/bundle/neobundle.vim/
 endif

 call neobundle#rc(expand('~/.vim/bundle/'))

 NeoBundleFetch 'Shougo/neobundle.vim'

 NeoBundle 'Shougo/vimproc'

 NeoBundle 'tpope/vim-fugitive'
 NeoBundle 'Lokaltog/vim-easymotion'
 NeoBundle 'rstacruz/sparkup', {'rtp': 'vim/'}
 " vim-scripts repos
 NeoBundle 'L9'
 NeoBundle 'FuzzyFinder'
 NeoBundle 'rails.vim'
 " Non github repos
 NeoBundle 'git://git.wincent.com/command-t.git'
 " Non git repos
 NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
 NeoBundle 'https://bitbucket.org/ns9tks/vim-fuzzyfinder'


 filetype plugin indent on


 " 自動補完機構
 NeoBundle 'Shougo/neocomplcache'
 NeoBundle 'Shougo/neosnippet'
 NeoBundle 'Shougo/neosnippet-snippets'

 " 自動括弧閉じ
 NeoBundle 'yuroyoro/vim-autoclose'
 let g:autoclose_vim_commentmode = 1

 " 高性能整形（らしい）
 NeoBundle 'Align'

 NeoBundle 'yuroyoro/smooth_scroll.vim'

 " PowerLine
 NeoBundle 'alpaca-tc/alpaca_powertabline'
 NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}

 " Syntax checking plugin ruby
 NeoBundle 'scrooloose/syntastic'

 "いい感じのhtml
 NeoBundle 'mattn/emmet-vim'

 "git plugin
 NeoBundle 'gregsexton/gitv.git'

 NeoBundleCheck

" neocomplcacheの設定
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
"  Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : ''
    \ }
" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()
" Recommended key-mappings.
" " <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
	  return neocomplcache#smart_close_popup() . "\<CR>"
  endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

 " git branch name 
set statusline+=%{fugitive#statusline()}
