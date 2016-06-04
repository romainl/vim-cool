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
    nnoremap / :silent nohlsearch<CR>/
    nnoremap ? :silent nohlsearch<CR>?

    nnoremap <silent> n n:set hlsearch<CR>
    nnoremap <silent> N N:set hlsearch<CR>

    nnoremap <silent> * *:set hlsearch<CR>
    nnoremap <silent> # #:set hlsearch<CR>

    nnoremap <silent> g* g*:set hlsearch<CR>
    nnoremap <silent> g# g#:set hlsearch<CR>

    cnoremap <silent> <expr> <CR> <sid>Cool()

    autocmd! CursorMoved * call <sid>Cooler()

    function! s:Cool()
        if getcmdtype() =~ '[/?]'
            return "\<CR>:set hlsearch\<CR>"
        else
            return "\<CR>"
        endif
    endfunction

    function! s:Cooler()
        let save_cursor = exists("*getcurpos") ? getcurpos() : getpos(".")
        if expand("<cword>") =~ @/
            set hlsearch
        else
            if &hlsearch
                set nohlsearch
            endif
        endif
        call setpos('.', save_cursor)
    endfunction
endif

let &cpo = s:save_cpo
