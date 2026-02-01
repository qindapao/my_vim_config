
" =====================File: font.vim {======================= 字体配置 ================================================

function! FontPreserveWindowSize(delta)
    let l:decimalpat = '[0-9]\+\(\.[0-9]*\)\?'
    let l:fontpat_unix = '^\(\(-[^-]\+\)\{6}-\)\(' . l:decimalpat . '\)'
    let l:fontpat_win32 = '\(:h\)\(' . l:decimalpat . '\)\(:\|,\|$\)'

    let l:guifont = &guifont
    let l:parts = split(l:guifont, ':')
    let l:guifont_size_str = l:parts[1]

    let l:guifont_size_list = split(l:guifont_size_str, 'h')
    " split函数会默认忽略空元素 let l:guifont_size_list = split(l:guifont_size_str, 'h', 1) 这样才会保留
    let l:guifont_size = str2float(l:guifont_size_list[0])

    let l:new_font_size = l:guifont_size + a:delta
    if l:new_font_size < 1
        let l:new_font_size = 1
    endif

    if has("unix")
        let guifont = substitute(&guifont, l:fontpat_unix,
                               \ '\1' . l:new_font_size, "")
    elseif has("win32")
        let guifont = substitute(&guifont, l:fontpat_win32,
                               \ '\1' . l:new_font_size, "")
    endif
    let &guifont = guifont
endfunction

" 调整字体大小的时候不要重新计算窗口大小
set guioptions+=k


" ----------------------------------------------------------------------------

" set guifont=sarasa\ mono\ sc:h13
" set guifont=Yahei\ Fira\ Icon\ Hybrid:h11
" set guifont=微软雅黑\ PragmataPro\ Mono:h8
" 这个字体某些方向符号无法显示
" set guifont=Fira\ Code:h8
function! FontGuiSet()
    let candidates = [
            \ 'vimio mono:h8',
            \ 'Maple Mono Normal NL:h8',
            \ 'Maple Mono NL NF CN:h8'
            \ ]
    for font_iter in candidates
        if !empty(getfontname(font_iter))
            execute 'set guifont=' . substitute(font_iter, ' ', '\\ ', 'g')
            break
        endif
    endfor
endfunction

" ----------------------------------------------------------------------------

" 一定要在 GUI 完成后再调用（GUIEnter）
augroup GuiFontSetup
    autocmd!
    autocmd GUIEnter * call FontGuiSet()
augroup END

" ----------------------------------------------------------------------------

" 使用小数步进值
nnoremap <silent> <C-ScrollWheelDown> :call FontPreserveWindowSize(-0.5)<CR>|   " font: 减小字体大小
nnoremap <silent> <C-ScrollWheelUp> :call FontPreserveWindowSize(0.5)<CR>|      " font: 增加字体大小
nnoremap <leader><C-t> :setlocal guifont=Yahei\ Fira\ Icon\ Hybrid:h|           " font: 设置另外一种字体


" =====================File: font.vim }======================= 字体配置 ================================================

