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
    " toggle coolness when hlsearch is toggled
    autocmd OptionSet hlsearch call <SID>PlayItCool(v:option_old, v:option_new)
augroup END

if !exists('*execute')
    let s:saveh = &highlight
    autocmd Cool OptionSet highlight let s:saveh = &highlight
endif

function! s:StartHL()
    if v:hlsearch && mode() is 'n'
        silent! if !search('\%#\zs'.@/,'cnW')
            call <SID>StopHL()
        elseif exists('*reltimestr')
            exe "silent! norm! :let g:cool_char=nr2char(screenchar(screenrow(),1))\<cr>"
            if g:cool_char =~ '[/?]'
                let [now, noOf, pos] = [reltime(), [0,0], getpos('.')]
                for b in [0,1]
                    while search(@/, 'Wb'[:b])
                        if 0.1 <= eval(reltimestr(reltime(now))[:-6])
                            " time >= 100ms
                            call setpos('.',pos)
                            return
                        endif
                        let noOf[!b] += 1
                    endwhile
                    call setpos('.',pos)
                endfor
                redraw|echo g:cool_char.@/ 'match' noOf[0] + 1 'of' noOf[0] + noOf[1] + 1
            endif
        endif
    endif
endfunction

function! s:StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        silent call feedkeys("\<Plug>(StopHL)", 'm')
    endif
endfunction

if exists('s:saveh')
    " toggle highlighting, a workaround for :nohlsearch in autocmds
    function! s:AuNohlsearch()
        noautocmd set highlight+=l:-
        autocmd Cool Insertleave *
                    \ noautocmd let &highlight = s:saveh | autocmd! Cool InsertLeave *
        return ''
    endfunction
endif

function! s:PlayItCool(old, new)
    if a:old == 0 && a:new == 1
        " nohls --> hls
        "   set up coolness
        noremap <silent> <Plug>(StopHL) :<C-U>nohlsearch<cr>
        if exists('s:saveh')
            noremap! <expr> <Plug>(StopHL) <SID>AuNohlsearch()
        else
            noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
        endif

        autocmd Cool CursorMoved * call <SID>StartHL()
        autocmd Cool InsertEnter * call <SID>StopHL()
    elseif a:old == 1 && a:new == 0
        " hls --> nohls
        "   tear down coolness
        nunmap <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)

        autocmd! Cool CursorMoved
        autocmd! Cool InsertEnter
    else
        " nohls --> nohls
        "   do nothing
        return
    endif
endfunction

" play it cool
call <SID>PlayItCool(0, &hlsearch)

let &cpo = s:save_cpo
