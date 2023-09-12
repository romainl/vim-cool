" vim-cool - Disable hlsearch when you are done searching.
" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.2
" License:	MIT License
" Location:	plugin/cool.vim
" Website:	https://github.com/romainl/vim-cool

if exists("g:loaded_cool") || v:version < 704 || &compatible
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
        autocmd Cool OptionSet highlight let <SID>saveh = &highlight
    endif
    " toggle coolness when hlsearch is toggled
    autocmd Cool OptionSet hlsearch call <SID>PlayItCool(v:option_old, v:option_new)
endif

" Inputs are 1-based (row, col) coordinates into lines.
" Returns the corresponding zero-based offset into lines->join("\n")
"
" These functions (s:PositionToOffset and s:OffsetToPosition) are taken from
" this workaround to vim's incorrect :goto and line2byte() results when
" text_props are present:
" https://github.com/google/vim-codefmt/pull/145
"
" Referring to this bug:
" https://github.com/vim/vim/issues/5930
function! s:PositionToOffset(row, col, lines) abort
    let l:offset = a:col - 1 " 1-based to 0-based
    if a:row > 1
        for l:line in a:lines[0 : a:row - 2] " 1-based to 0-based, exclude current
            let l:offset += len(l:line) + 1 " +1 for newline
        endfor
    endif
    return l:offset
endfunction
" Input is zero-based offset into lines->join("\n")
" Returns the 1-based [row, col] coordinates into lines.
function! s:OffsetToPosition(offset, lines) abort
    let l:lines_consumed = 0
    let l:chars_left = a:offset
    for l:line in a:lines
        let l:line_len = len(l:line) + 1 " +1 for newline
        if l:chars_left < l:line_len
            break
        endif
        let l:chars_left -= l:line_len
        let l:lines_consumed += 1
    endfor
    return [l:lines_consumed + 1, l:chars_left + 1] " 0-based to 1-based
endfunction

function! s:StartHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    endif
    let g:cool_is_searching = 1
    let [pos, rpos] = [winsaveview(), getpos('.')]

    " :goto line2byte() is buggy when text properties are present:
    " https://github.com/vim/vim/issues/5930
    if !has('textprop') || empty(prop_list(line('.')))
        silent! exe "keepjumps go".(line2byte('.')+col('.')-(v:searchforward ? 2 : 0))
    else
        let lines = getline(1, line('$'))
        let offset = s:PositionToOffset(line('.'), col('.'), lines)
        let [new_line, new_col] = s:OffsetToPosition(offset - (v:searchforward ? 1 : -1), lines)
        call cursor(new_line, new_col)
    endif

    try
        silent keepjumps norm! n
        if getpos('.') != rpos
            throw 0
        endif
    catch /^\%(0$\|Vim\%(\w\|:Interrupt$\)\@!\)/
        call <SID>StopHL()
        return
    finally
        call winrestview(pos)
    endtry
    if !get(g:,'cool_total_matches') || !exists('*reltimestr')
        return
    endif
    exe "silent! norm! :let g:cool_char=nr2char(screenchar(screenrow(),1))\<cr>"
    let cool_char = remove(g:,'cool_char')
    if cool_char !~ '[/?]'
        return
    endif
    let [f, ws, now, noOf] = [0, &wrapscan, reltime(), [0,0]]
    set nowrapscan
    try
        while f < 2
            if reltimestr(reltime(now))[:-6] =~ '[1-9]'
                " time >= 100ms
                return
            endif
            let noOf[v:searchforward ? f : !f] += 1
            try
                silent exe "keepjumps norm! ".(f ? 'n' : 'N')
            catch /^Vim[^)]\+):E38[45]\D/
                call setpos('.',rpos)
                let f += 1
            endtry
        endwhile
    finally
        call winrestview(pos)
        let &wrapscan = ws
    endtry
    redraw|echo cool_char.@/ 'match' noOf[0] 'of' noOf[0] + noOf[1] - 1
endfunction

function! s:StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        let g:cool_is_searching = 0
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

            " If no "execute()", ":tnoremap" isn't probably implemented too.
        else
            noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
            if exists(':tnoremap')
                tnoremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
            endif
        endif

        autocmd Cool CursorMoved * call <SID>StartHL()
        autocmd Cool InsertEnter * call <SID>StopHL()
    elseif a:old == 1 && a:new == 0
        " hls --> nohls
        "   tear down coolness
        nunmap <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)
        if exists(':tunmap')
            tunmap <Plug>(StopHL)
        endif

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
