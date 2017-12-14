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
augroup END

if exists('##OptionSet')
    if !exists('*execute')
        autocmd Cool OptionSet highlight let s:saveh = &highlight
    endif
    " toggle coolness when hlsearch is toggled
    autocmd Cool OptionSet hlsearch call <SID>PlayItCool(v:option_old, v:option_new)
endif

function! s:StartHL()
    if v:hlsearch && mode() is 'n'
        let patt = @/
        silent! if !search('\%#\zs'.patt,'cnW')
            call <SID>StopHL()
        elseif get(g:,'CoolTotalMatches') && exists('*reltimestr')
            exe "silent! norm! :let g:cool_char=nr2char(screenchar(screenrow(),1))\<cr>"
            if g:cool_char !~ '[/?]'
                return
            endif
            let [ws, now, noOf, pos] = [&wrapscan, reltime(), [0,0], winsaveview()]
            set nows
            let rpos = getpos('.')
            try
                let f = 0
                while f < 2
                    if reltimestr(reltime(now))[:-6] =~ '[1-9]'
                        " time >= 100ms
                        call winrestview(pos)
                        return
                    endif
                    try
                        let noOf[f]+=1
                        exe "norm! ".(f ? 'n' : 'N')
                    catch
                        call setpos('.',rpos)
                        norm! l
                        let f += 1
                    endtry
                endwhile
                call winrestview(pos)
                redraw|echo g:cool_char.@/ 'match' noOf[0] 'of' noOf[0] + noOf[1] - 1
            finally
                let &wrapscan = ws
            endtry
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

if !exists('*execute')
    let s:saveh = &highlight
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
        if !exists('*execute')
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
