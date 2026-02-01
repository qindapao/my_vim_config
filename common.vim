
" =====================File: common.vim {======================= 公共函数区域 ==

" ----------------------------------------------------------------------------

function! CommonTrimString(s)
    return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" ----------------------------------------------------------------------------

" 获取选择模式下当前行选择的文本
function! CommonGetVisualLine()
    let line = getline('.')
    let start = getpos("'<")[2] - 1
    let end = getpos("'>")[2] - 2
    return line[start:end]
endfunction

" ----------------------------------------------------------------------------

function! CommonUploadDynamicPopupWin()
    if !exists("b:common_dynamic_content_win")
        let b:common_dynamic_content_win = -1
    endif
    if b:common_dynamic_content_win != -1
        let dynamic_info_list = MarksSort()
        call popup_settext(b:common_dynamic_content_win, dynamic_info_list)
    endif
endfunction

" ----------------------------------------------------------------------------

function! CommonBashANSIQuote(s)
    let b = '$'
    let b .= "'"
    let i = 0
    let len = strlen(a:s)
    while i < len
        let c = a:s[i]
        let ord = char2nr(c)
        if ord == 27
            let b .= '\E'
        elseif ord == 7
            let b .= '\a'
        elseif ord == 8
            let b .= '\b'
        elseif ord == 9
            let b .= '\t'
        elseif ord == 10
            let b .= '\n'
        elseif ord == 11
            let b .= '\v'
        elseif ord == 12
            let b .= '\f'
        elseif ord == 13
            let b .= '\r'
        elseif ord == 39
            let b .= "\\'"
        elseif ord == 92
            let b .= '\\'
        else
            if ord < 32 || ord == 127
                let b .= printf('\%03o', ord)
            else
                let b .= c
            endif
        endif
        let i += 1
    endwhile
    let b .= "'"
    return b
endfunction

" ----------------------------------------------------------------------------

" :/<C-r>=CommonBuildLooseRegex("你好世界")<CR>
" :echo CommonBuildLooseRegex("你好世界")
" \V你\s\*好\s\*世\s\*界
function! CommonBuildLooseRegex(keyword)
    let chars = split(a:keyword, '\zs')
    let pattern = '\V' . join(chars, '\s\*')
    return pattern
endfunction

" ----------------------------------------------------------------------------

" 获取可视模式选中的文本（支持单行/多行精确列）
function! CommonGetVisualSelection()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]

    " Single row selection: intercept directly on this row by column
    if lnum1 == lnum2
        let line = getline(lnum1)
        return line[col1 - 1 : col2 - 2]
    endif

    " Multi-line selection: first take the entire paragraph,
    " then trim the beginning and end
    let lines = getline(lnum1, lnum2)
    if empty(lines)
        return ''
    endif

    " Crop first and last row
    let lines[0]  = lines[0][col1 - 1 :]
    let lines[-1] = lines[-1][: col2 - 2]

    return join(lines, "\n")
endfunction

" ----------------------------------------------------------------------------

function! CommonCheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" ----------------------------------------------------------------------------

function! CommonGetLineContentLast ()
    " 获取当前行的内容
    let line = getline('.')
    " 使用空格分割行内容
    let fields = split(line)
    " 返回最后一个域的内容
    return fields[-1]
endfunction

" ----------------------------------------------------------------------------

function! CommonRemoveLastChar(str)
    if len(a:str) > 0
        let l:width = strchars(a:str) - 1
        let l:result = strcharpart(a:str, 0, l:width)
        return l:result
    else
        return a:str
    endif
endfunction

" ------弹出窗口----------------------------------------------------------------

" 一个简单的弹出窗口只是为了用户帮助信息(只显示信息不获取焦点,屏幕右上角)
function! CommonShowPopup(contentList)
    let options = {
    \ 'line': 1,
    \ 'col': winwidth(0) - 30,
    \ 'minwidth': 30,
    \ 'minheight': len(a:contentList),
    \ 'padding': [0,1,0,1],
    \ 'border': [],
    \ 'close': 'click',
    \ 'focusable': 0,
    \ }
    let winid = popup_create(a:contentList, options)
    return winid
endfunction

" ------------------------------------------------------------------------------

function! CommonGetCurrentPath()
    " 获取当前文件的绝对路径
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')
    let l:path_only = fnamemodify(l:absolute_path, ':h')
    return l:path_only
endfunction

" ----------------------------------------------------------------------------

function! CommonGetCurrentFileAndPath()
    " 获取当前文件的绝对路径和行号
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')
    return l:absolute_path
endfunction

" ----------------------------------------------------------------------------

function! CommonIsAbsolutePath(path)
    " Unix absolute path: /foo/bar
    if a:path =~? '^/'
        return 1
    endif

    " Windows UNC path: \\server\share
    if a:path =~? '^\\\\'
        return 1
    endif

    " Windows drive letter: C:\foo or C:/foo
    if a:path =~? '^[A-Za-z]:[\\/]'
        return 1
    endif

    return 0
endfunction

" ----------------------------------------------------------------------------

" 当前只支持.git目录和.root文件
function! CommonFindRootDir()
    let l:current_dir = expand('%:p:h')
    let l:current_dir = substitute(l:current_dir, '\\', '/', 'g')

    while l:current_dir != '/' && l:current_dir !~ '^[A-Za-z]:/$'
        if isdirectory(l:current_dir . '/.git') || filereadable(l:current_dir . '/.root')
            return l:current_dir
        endif
        let l:current_dir = fnamemodify(l:current_dir, ':h')
    endwhile
    return ''
endfunction

" ----------------------------------------------------------------------------

function! CommonGetRelationPath()
    " 获取当前文件的绝对路径和行号
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')

    " 查找项目根目录
    let l:root_dir = CommonFindRootDir()
    if l:root_dir == ''
        echo "未找到项目根目录"
        return ''
    endif

    " 计算相对路径
    let l:relative_path = absolute_path[len(l:root_dir)+1:]
    return l:relative_path
endfunction

" ----------------------------------------------------------------------------

" =====================File: common.vim }======================= 公共函数区域 ==

