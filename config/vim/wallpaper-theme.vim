" Shared Vim/Neovim theme. It follows the selected fixed Kitty palette.
if exists('g:loaded_wallpaper_theme')
  finish
endif
let g:loaded_wallpaper_theme = 1

set termguicolors
set background=dark
syntax enable
filetype plugin indent on

function! s:ApplyKittyPalette() abort
  let l:palette_file = expand('~/.config/kitty/dynamic.conf')
  if !filereadable(l:palette_file)
    return
  endif

  let l:colors = {}
  for l:line in readfile(l:palette_file)
    let l:match = matchlist(l:line, '^\(background\|foreground\|selection_background\|active_border_color\|color[0-9]\+\)\s\+\(#\x\{6}\)')
    if !empty(l:match)
      let l:colors[l:match[1]] = l:match[2]
    endif
  endfor

  for l:required in ['background', 'foreground', 'selection_background', 'active_border_color', 'color0', 'color1', 'color2', 'color3', 'color4', 'color5', 'color6', 'color8']
    if !has_key(l:colors, l:required)
      return
    endif
  endfor

  execute 'highlight Normal guifg=' . l:colors.foreground . ' guibg=' . l:colors.background
  execute 'highlight NormalFloat guifg=' . l:colors.foreground . ' guibg=' . l:colors.background
  execute 'highlight EndOfBuffer guifg=' . l:colors.background . ' guibg=' . l:colors.background
  execute 'highlight LineNr guifg=' . l:colors.color8 . ' guibg=' . l:colors.background
  execute 'highlight CursorLineNr guifg=' . l:colors.color3 . ' guibg=' . l:colors.background . ' gui=bold'
  execute 'highlight CursorLine guibg=' . l:colors.color0
  execute 'highlight VertSplit guifg=' . l:colors.active_border_color . ' guibg=' . l:colors.background . ' gui=NONE'
  execute 'highlight VertSplitNC guifg=' . l:colors.active_border_color . ' guibg=' . l:colors.background . ' gui=NONE'
  execute 'highlight Visual guibg=' . l:colors.selection_background
  execute 'highlight Search guifg=' . l:colors.background . ' guibg=' . l:colors.color3
  execute 'highlight IncSearch guifg=' . l:colors.background . ' guibg=' . l:colors.color1
  execute 'highlight Pmenu guifg=' . l:colors.foreground . ' guibg=' . l:colors.color0
  execute 'highlight PmenuSel guifg=' . l:colors.background . ' guibg=' . l:colors.color4
  execute 'highlight Comment guifg=' . l:colors.color8 . ' gui=italic'
  execute 'highlight Constant guifg=' . l:colors.color3
  execute 'highlight String guifg=' . l:colors.color2
  execute 'highlight Character guifg=' . l:colors.color2
  execute 'highlight Number guifg=' . l:colors.color3
  execute 'highlight Boolean guifg=' . l:colors.color5
  execute 'highlight Identifier guifg=' . l:colors.color4
  execute 'highlight Function guifg=' . l:colors.color4 . ' gui=bold'
  execute 'highlight Statement guifg=' . l:colors.color5
  execute 'highlight PreProc guifg=' . l:colors.color6
  execute 'highlight Type guifg=' . l:colors.color3
  execute 'highlight Special guifg=' . l:colors.color1
  execute 'highlight Todo guifg=' . l:colors.background . ' guibg=' . l:colors.color3 . ' gui=bold'
  execute 'highlight Error guifg=' . l:colors.color1 . ' guibg=' . l:colors.background
  execute 'highlight DiagnosticError guifg=' . l:colors.color1
  execute 'highlight DiagnosticWarn guifg=' . l:colors.color3
  execute 'highlight DiagnosticInfo guifg=' . l:colors.color4
  execute 'highlight DiagnosticHint guifg=' . l:colors.color6
endfunction

augroup WallpaperTheme
  autocmd!
  autocmd VimEnter,FocusGained * call <SID>ApplyKittyPalette()
augroup END

call <SID>ApplyKittyPalette()
