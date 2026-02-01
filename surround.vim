
" =====================File: surround.vim {======================= 编辑内容环绕 ========================================

function! SurroundWith(symbol, visual, fill_char) range
    let l:offset = 0
    " 获取选定区域中的最小缩进
    let l:min_indent = matchstr(getline(a:firstline), '^\s*')
    for i in range(a:firstline, a:lastline)
        let l:current_line = getline(i)
        let l:current_indent = matchstr(l:current_line, '^\s*')
        " 如果一行不是空行并且不只包含空格TAB(空字符)
        if l:current_line =~ '\S'
            if len(l:current_indent) < len(l:min_indent)
                let l:min_indent = l:current_indent
            endif
        endif
    endfor

    if a:visual == 'v'
        " 在选定区域的前后添加空格
        let l:start_pos = getpos("'<")
        let l:end_pos = getpos("'>")
        let l:first_line = getline(l:start_pos[1])
        let l:last_line = getline(l:end_pos[1])

        if g:surround_saved_cursor_pos[1] == l:start_pos[1]
            let l:offset = len(a:symbol[0]) + len(a:fill_char)
        endif

        if l:start_pos[1] == l:end_pos[1]
            if l:start_pos[2] == 1
                call setline(l:start_pos[1], a:symbol[0] . a:fill_char . l:first_line[l:start_pos[2]-1:l:end_pos[2]-2] . a:fill_char . a:symbol[1] . l:first_line[l:end_pos[2]-1:])
            else
                call setline(l:start_pos[1], l:first_line[:l:start_pos[2]-2] . a:symbol[0] . a:fill_char . l:first_line[l:start_pos[2]-1:l:end_pos[2]-2] . a:fill_char . a:symbol[1] . l:first_line[l:end_pos[2]-1:])
            endif
        else
            if l:start_pos[2] == 1
                call setline(l:start_pos[1], a:symbol[0] . a:fill_char . l:first_line[l:start_pos[2]-1:])
            else
                call setline(l:start_pos[1], l:first_line[:l:start_pos[2]-2] . a:symbol[0] . a:fill_char . l:first_line[l:start_pos[2]-1:])
            endif

            if l:end_pos[2] == 1
                call setline(l:end_pos[1], a:fill_char . a:symbol[1] . l:last_line[l:end_pos[2]-1:])
            else
                call setline(l:end_pos[1], l:last_line[:l:end_pos[2]-2] . a:fill_char . a:symbol[1] . l:last_line[l:end_pos[2]-1:])
            endif
        endif
    else
        " 在选定区域的上方和下方分别添加一行
        execute (a:firstline - 1) . 's/$/\r' . l:min_indent . a:symbol[0] . '/'
        execute (a:lastline + 2) . 's/^/' . l:min_indent . a:symbol[1] . '\r/'
    endif

    call cursor(g:surround_saved_cursor_pos[1], g:surround_saved_cursor_pos[2] + l:offset)
endfunction

nnoremap <silent> v :let g:surround_saved_cursor_pos = getpos('.')<CR>v|        " 进入可是模式记录坐标
nnoremap <silent> V :let g:surround_saved_cursor_pos = getpos('.')<CR>V|        " 进入可是模式记录坐标

vnoremap <silent> S( :call SurroundWith('()', visualmode(), ' ')<CR>|           " 编辑: 小括号包围有空格
vnoremap <silent> S{ :call SurroundWith('{}', visualmode(), ' ')<CR>|           " 编辑: 大括号包围有空格
vnoremap <silent> S) :call SurroundWith('()', visualmode(), '')<CR>|            " 编辑: 小括号包围无空格
vnoremap <silent> S} :call SurroundWith('{}', visualmode(), '')<CR>|            " 编辑: 大括号包围无空格

vnoremap <silent> S* :call SurroundWith(['**', '**'], visualmode(), '')<CR>|    " 编辑: 双*包围无空格(加粗)
vnoremap <silent> S~ :call SurroundWith(['~~', '~~'], visualmode(), '')<CR>|    " 编辑: 双~包围无空格(删除)
vnoremap <silent> S_ :call SurroundWith(['__', '__'], visualmode(), '')<CR>|    " 编辑: 双_包围无空格(高亮)
vnoremap <silent> S/ :call SurroundWith(['//', '//'], visualmode(), '')<CR>|    " 编辑: 双/包围无空格(斜体)
vnoremap <silent> S'' :call SurroundWith(["''", "''"], visualmode(), '')<CR>|   " 编辑: 双'包围无空格(内联代码)

" =====================File: surround.vim {======================= 编辑内容环绕 ========================================

