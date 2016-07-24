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
    let s:CRmap = maparg('<CR>', 'c', 0, 1)
    let s:CRfunc = ""

    function! s:CRFUNC()
        return "\<CR>"
    endfunction

    if !empty(s:CRmap)
        if s:CRmap.expr == 1 && s:CRmap.rhs =~ '()$'
            let s:CRfunc = function(substitute(s:CRmap.rhs, '()$', '', ''))
        else
            let s:CRfunc = function('<sid>CRFUNC')
        endif
    else
        let s:CRfunc = function('<sid>CRFUNC')
    endif

    execute "nnoremap / :silent nohlsearch" . s:CRfunc() . "/"
    execute "nnoremap ? :silent nohlsearch" . s:CRfunc() . "?"

    execute "nnoremap <silent> n n:set hlsearch" . s:CRfunc()
    execute "nnoremap <silent> N N:set hlsearch" . s:CRfunc()

    execute "nnoremap <silent> * *:set hlsearch" . s:CRfunc()
    execute "nnoremap <silent> # #:set hlsearch" . s:CRfunc()

    execute "nnoremap <silent> g* g*:set hlsearch" . s:CRfunc()
    execute "nnoremap <silent> g# g#:set hlsearch" . s:CRfunc()

    cnoremap <silent> <expr> <CR> <sid>Cool()

    autocmd! CursorMoved * silent! call <sid>Cooler()

    function! s:Cool()
        if getcmdtype() =~ '[/?]'
            return s:CRfunc() . ":set hlsearch\<CR>"
        else
            return s:CRfunc()
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
