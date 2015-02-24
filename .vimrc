set nocompatible
set number
syntax on
set tabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start

"indent setting"
set autoindent
set cindent
set smarttab

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
 NeoBundle 'L9'
 NeoBundle 'FuzzyFinder'
 NeoBundle 'rails.vim'
 NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
 NeoBundle 'https://bitbucket.org/ns9tks/vim-fuzzyfinder'


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
 "  NeoBundle 'alpaca-tc/alpaca_powertabline'
 "  NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}

 " NewPowerLine
 NeoBundle 'itchyny/lightline.vim'

 " PowerUp Powerline
 NeoBundle 'Shougo/vimfiler.vim'
 NeoBundle 'Shougo/unite.vim'
 NeoBundle 'Shougo/vimshell.vim'

 " Syntax checking plugin
 NeoBundle 'scrooloose/syntastic'

 " help to write html
 NeoBundle 'mattn/emmet-vim'

 " git plugin
 NeoBundle 'gregsexton/gitv.git'

 " help to write markdown
 " Make Preview
 NeoBundle 'kannokanno/previm'

 " OpenBrowser
 NeoBundle 'tyru/open-browser.vim'

 " help to write javascript & coffee script
 NeoBundle 'hail2u/vim-css3-syntax'
 NeoBundle 'taichouchou2/html5.vim'
 NeoBundle 'kchmck/vim-coffee-script'

 NeoBundleLazy 'jelera/vim-javascript-syntax', {'autoload':{'filetypes':['javascript']}}

 filetype plugin indent on
 
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

" build vimproc

let vimproc_updcmd = has('win64') ?
      \ 'tools\\update-dll-mingw 64' : 'tools\\update-dll-mingw 32'
execute "NeoBundle 'Shougo/vimproc.vim'," . string({
      \ 'build' : {
      \     'windows' : vimproc_updcmd,
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ })


" set *.md filetype
augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END

" lightline.vim setting

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }
set laststatus=2
