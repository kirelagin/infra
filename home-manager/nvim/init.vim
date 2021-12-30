scriptencoding utf-8

let plugin_dir = expand('~/.cache/nvim/plugins')
let dein_dir = plugin_dir . "/repos/github.com/Shougo/dein.vim"

if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  if !filereadable(dein_dir . '/README.md')
    silent exec "!mkdir -p " . dein_dir
    silent exec "!git clone 'https://github.com/Shougo/dein.vim' " . dein_dir
  endif

  let &runtimepath .= "," . dein_dir
endif

if dein#load_state(plugin_dir)
  call dein#begin(plugin_dir)

  call dein#add('chiuczek/inkpot', {
    \   'hook_post_source': 'set bg=dark'
    \ })

  call dein#load_toml(expand('<sfile>:p:h') . '/plugins.toml', {'merge_ftdetect': 1})

  call dein#end()
  call dein#save_state()
endif
" Required by dein:
filetype plugin indent on
syntax on

if dein#check_install()
  call dein#install()
endif

colors inkpot
hi Normal gui=NONE guifg=#cfbfad guibg=#2e2e31
hi LineNr gui=NONE guifg=#3a3a51 guibg=#2e2e2e
"hi Normal guibg=NONE ctermbg=NONE
set guifont=DejaVu\ Sans\ Mono:h10

"set noswapfile
set hidden
set encoding=utf-8
set termencoding=utf-8

" restore last cursor position in the file
if has("autocmd")
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
endif

set expandtab
set autoindent
set smartindent
set shiftround
set tabstop=8
set softtabstop=2
set shiftwidth=2

set listchars=tab:▒░,trail:▓,nbsp:␣
set list
set virtualedit=block,onemore
set linebreak  " do not break line in the middle of the word

set pastetoggle=<F8>

set wmh=0
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
set splitbelow
set splitright
set laststatus=2

if (exists(":tnoremap"))
  tnoremap <C-w> <C-\><C-N><C-w>
"  au BufEnter term://* startinsert
  au TermOpen * au BufEnter <buffer> startinsert
endif

noremap <C-h> :tabp<CR>
noremap <C-l> :tabn<CR>


" sane movement with wrap turned on
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" center screen when iterating over search results
noremap n nzz
noremap N Nzz

set statusline=%<\ %n\ %f\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}%m%r%y%=\ %l\/\%L\ \|%v\|\ 

vnoremap > >gv
vnoremap < <gv

set wildmenu
set wildmode=longest:full,full
set wildignore=*.swp,*.bak
set wildignore+=*.pyc
set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
set wildignore+=tags
set wildignorecase

set scrolloff=3

set gdefault
set hlsearch
set incsearch
set ignorecase
set smartcase
nmap <silent> <Leader>q :nohl<CR>

set vb
set t_vb=  " No bell


set formatoptions-=o
set formatoptions+=c

set spellfile=~/.config/nvim/spell/ru.utf-8.add,~/.config/nvim/spell/en.utf-8.add
set spelllang=en,ru

if (has("termguicolors"))
  set termguicolors
endif


highlight OverLength guibg=#592929
match OverLength /\%81v./
