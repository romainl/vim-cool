" vim-cool - Disable hlsearch when you are done searching.
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.2
" License:	MIT License
" Location:	plugin/cool.vim
" Website:	https://github.com/romainl/vim-cool

if exists("g:loaded_cool") || v:version < 703 || &compatible
    finish
endif
let g:loaded_cool = 1

let s:save_cpo = &cpo
set cpo&vim

augroup Cool
    autocmd!
    autocmd OptionSet hlsearch call <SID>PlayItCool(v:option_new)
augroup END

function! s:StartHL()
    let s:pos = match(getline('.'), @/, col('.') - 1) + 1
    if s:pos != col('.')
        call <SID>StopHL()
    endif
endfunction

function! s:StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        silent call feedkeys("\<Plug>(StopHL)", 'm')
    endif
endfunction

function! s:PlayItCool(hls)
    if a:hls == 1
        noremap  <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
        noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]

        autocmd Cool CursorMoved * call <SID>StartHL()
        autocmd Cool InsertEnter * call <SID>StopHL()
    else
        nunmap <expr> <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)

        autocmd! Cool CursorMoved
        autocmd! Cool InsertEnter
    endif
endfunction

if &hlsearch
    call <SID>PlayItCool(1)
endif

let &cpo = s:save_cpo
