" paste-mode    adds a third mode (paste) to the insert key
" Author:       Mal Graty <madmalibu@gmail.com>
" HomePage:     http://github.com/mal/pastemode.vim
" Readme:       http://github.com/mal/pastemode.vim/blob/master/readme.md
" Version:      2.1

" only do this once
if exists('s:loaded_paste_mode_plugin')
    finish
endif
let s:loaded_paste_mode_plugin = 1

" attach an intercept to the insert key
fu s:attach()
    " only when in non-paste insert mode, and not already mapped
    if ! &paste && v:insertmode == 'i' && mapcheck('<insert>', 'i') == ''
        " side step <c-o> which would trigger autocmds
        imap <insert> <c-r>=<sid>intercept()<cr>
    endif
endf

" detach the intercept from the insert key
fu s:detach()
    " don't bother when not mapped
    if mapcheck('<insert>', 'i') != ''
        iunmap <insert>
    endif
endf

" paste on, numbers off, party time!
fu s:intercept()
    " done with the intercept for now
    call <sid>detach()
    set paste
    " cache number state before turning them off
    let w:number = &number
    set nonumber
    " hack to force the status line to update in insert mode
    echo
    " output will be printed, so make it blank
    return ''
endf

" leave insert mode, unless re-entering
fu s:leave()
    " cleanup intercept
    call <sid>detach()
    " hack: part two of avoiding replace paste mode
    if exists('w:insert') && w:insert
        startinsert
        let w:insert = 0
    endif
endf

" restore window settings
fu s:restore()
    " apply saved paste state
    if exists('w:paste') && w:paste
        " hack: part one of avoiding replace paste mode
        if v:insertmode == 'r'
            stopinsert
            let w:insert = 1
        endif
        set paste
    else
        " turn paste off before attempting attach
        set nopaste
        call <sid>attach()
    endif
    echo
endf

" save window settings
fu s:save()
    " save window paste state
    let w:paste = &paste
    " don't carry map over to other windows
    call <sid>detach()
endf

" update settings based on mode
fu s:update()
    " switch off paste when entering replace mode
    if v:insertmode == 'r'
        set nopaste
        " restore pre-paste number state
        if exists('w:number') && w:number
            set number
        endif
    else
        " entering insert mode, map intercept
        call <sid>attach()
    endif
endf

" define autocommands
au insertchange * call s:update()
au insertenter * call s:attach()
au insertleave * call s:leave()
au winenter * call s:restore()
au winleave * call s:save()
