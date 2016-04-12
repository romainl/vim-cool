" vim-cool - Disable hlsearch when you are done searching.
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.1
" License:	MIT License
" Location:	plugin/cool.vim
" Website:	https://github.com/romainl/vim-cool

if exists("g:loaded_cool") || v:version < 703 || &compatible
    finish
endif
let g:loaded_cool = 1

let s:save_cpo = &cpo
set cpo&vim

if &hlsearch
    nnoremap / :silent set hlsearch<CR>/
    nnoremap ? :silent set hlsearch<CR>?

    nnoremap <silent> n n:set hlsearch<CR>
    nnoremap <silent> N N:set hlsearch<CR>

    nnoremap <silent> * *:set hlsearch<CR>
    nnoremap <silent> # #:set hlsearch<CR>

    cnoremap <silent> <expr> <CR> <sid>Cool()

    autocmd! CursorMoved * silent call <sid>Cooler()

    function! s:Cool()
        let cmd = getcmdtype()
        if cmd == "/" || cmd == "?"
            return "\<CR>:set hlsearch\<CR>"
        else
            return "\<CR>"
        endif
    endfunction

    function! s:Cooler()
        if expand("<cword>") =~ @/
            set hlsearch
        else
            set nohlsearch
        endif
    endfunction
endif

let &cpo = s:save_cpo
