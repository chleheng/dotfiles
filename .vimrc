" --- Runtime ---
if isdirectory($HOME . '/.vim/bundle/novim-mod')
    set runtimepath^=~/.vim/bundle/novim-mod
endif

" --- General ---
set nocompatible
set encoding=utf-8
set history=1000
set undolevels=1000
set backspace=indent,eol,start
set autoread
set noswapfile
set nobackup
set mouse=a
set clipboard=unnamedplus
set gdefault
set virtualedit=block

" --- Undo persistence ---
if exists("+undofile")
    if isdirectory($HOME . '/.vim/undo') == 0
        :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=~/.vim/undo//
    set undofile
endif

" --- Display ---
set number
set relativenumber
set cursorline
set scrolloff=8
set sidescrolloff=8
set wrap
set linebreak
set showmatch
set showcmd
set showmode
set wildmenu
set wildmode=longest:full,full
set splitright
set splitbelow

" --- Colorscheme ---
syntax on
colorscheme warmlight

" --- Status bar ---
set laststatus=2
set statusline=
set statusline+=\ %f
set statusline+=\ %m
set statusline+=\ %r
set statusline+=%=
set statusline+=\ %{&filetype}
set statusline+=\ \|\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ \|\ %l:%c
set statusline+=\ \|\ %p%%\

" --- Search ---
set incsearch
set hlsearch
set ignorecase
set smartcase
nnoremap <Esc> :nohlsearch<CR>

" --- Indentation ---
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

" --- Leader ---
let mapleader = " "

" --- Navigation ---
nnoremap n nzz
nnoremap } }zz
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" --- Keys ---
nnoremap <F1> <nop>
nnoremap Q <nop>
nnoremap K <nop>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>ev :sp ~/.vimrc<CR>
nnoremap <leader>sv :so ~/.vimrc<CR>

" Blackhole register — delete without clobbering clipboard
nnoremap x "_x
nnoremap m "_d
nnoremap mm "_dd
nnoremap M "_D
nnoremap Y y$
vnoremap m d

" Auto-brackets
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap " ""<left>
inoremap ' ''<left>
autocmd FileType cpp inoremap < <><left>

" --- Filetype ---
filetype plugin indent on

augroup python_settings
    autocmd!
    autocmd FileType python nnoremap <buffer> <F9> :w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
    autocmd FileType python inoremap <buffer> <F9> <esc>:w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
    autocmd FileType python nnoremap <buffer> <F5> :w<CR>:exec '!clear; python3 -i' shellescape(@%, 1)<CR>
    autocmd FileType python inoremap <buffer> <F5> <esc>:w<CR>:exec '!clear; python3 -i' shellescape(@%, 1)<CR>
    autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
    autocmd FileType python set foldmethod=syntax
augroup END

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

augroup markdown
    autocmd!
    autocmd FileType markdown onoremap ih :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rkvg_"<cr>
    autocmd FileType markdown onoremap ah :<c-u>execute "normal! ?^==\\+$\r:nohlsearch\rg_vk0"<cr>
augroup END
