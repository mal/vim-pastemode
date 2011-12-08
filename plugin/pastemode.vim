"
" Paste Mode plugin for adding paste mode to the insert key
" Author: Mal Graty <madmalibu@gmail.com>
" Version: Vim 7 (may work with previous versions, but not tested)
" URL: https://github.com/mal/pastemode.vim
"

" Only do this when not done yet for this buffer
if exists("b:loaded_paste_mode_plugin")
    finish
endif
let b:loaded_paste_mode_plugin = 1

" map an intercept to the insert key
fu s:map()
    map! <insert> <c-o>:call <SID>toggle('map')<cr>
endf

" manage toggling of paste and insert modes
fu s:toggle(mode)

    " enable intercept when in non-paste insert mode
    "   n.b. insertenter occurs before v:insertmode is updated, so look for 'r' not 'i'
    if ( v:insertmode == 'i' || v:insertmode == 'r' && a:mode == 'enter' ) && ! &paste
        call <SID>map()
    endif

    " if we let enter continue it'll double fire the flip
    if a:mode == 'enter'
        return
    endif

    " we arrived via the intercept, nuke it
    if a:mode == 'map'
        iunmap <insert>
    endif

    let s:paste = &paste

    " entering or leaving paste mode, flip!
    if a:mode == 'map' || &paste
        set invpaste
    endif

endf

" map/hooks for paste mode
au insertchange * call <SID>toggle('change')
au insertenter * call <SID>toggle('enter')
