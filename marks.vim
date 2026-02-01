
" =====================File: marks.vim {======================= 自定义书签 =============================================

let g:marks_comments = {}
let g:marks_comments_file_path = ''

" ----------------------------------------------------------------------------

" 加载全局标记注释
function! MarksLoadComments()
    " 如果当前viminfo并不是默认的,那么全局注释文件也需要更换
    let g:marks_comments_file_path = expand('~/.vim/mark_comments/' . fnamemodify(g:viminfo_file_path, ':t') . 'global_mark_comments_')

    echom g:marks_comments_file_path

    if filereadable(g:marks_comments_file_path)
        let g:marks_comments = eval(join(readfile(g:marks_comments_file_path), "\n"))
    endif
endfunction

" ----------------------------------------------------------------------------

" 保存全局标记注释
function! MarksSaveGlobalComments()
    let l:dirpath = expand('~/.vim/mark_comments/')
    let l:filepath = expand(l:dirpath . 'marks_comments')
    " 检查并创建目录
    if !isdirectory(l:dirpath)
        call mkdir(l:dirpath, 'p')
    endif

    if empty(g:marks_comments)
        if filereadable(g:marks_comments_file_path)
            call delete(g:marks_comments_file_path)
        endif
    else
        call writefile(split(string(g:marks_comments), "\n"), g:marks_comments_file_path)
    endif
endfunction

" ----------------------------------------------------------------------------

" 添加标记注释
function! MarksAddComment(mark, comment)
    if a:mark =~# '[A-Z]'
        let g:marks_comments[a:mark] = a:comment
    else
        let b:marks_file_comments[a:mark] = a:comment
    endif
    call CommonUploadDynamicPopupWin()
endfunction

" ----------------------------------------------------------------------------

" 删除标记注释
function! MarksDeleteComment(mark)
    if a:mark =~# '[A-Z]'
        if has_key(g:marks_comments, a:mark)
            call remove(g:marks_comments, a:mark)
        endif
    else
        if has_key(b:marks_file_comments, a:mark)
            call remove(b:marks_file_comments, a:mark)
        endif
    endif
    call CommonUploadDynamicPopupWin()
endfunction

" ----------------------------------------------------------------------------

" 保存文件标记注释
function! MarksSaveFileComments()
    let l:filepath = expand('%:p')
    let l:comment_file = substitute(l:filepath, '[\\/:]', '-', 'g')
    let l:dirpath = expand('~/.vim/mark_comments/')
    if !isdirectory(l:dirpath)
        call mkdir(l:dirpath, 'p')
    endif

    let l:file_name = expand(l:dirpath . l:comment_file . '_mark_comments')
    if empty(b:marks_file_comments)
        if filereadable(l:file_name)
            call delete(l:file_name)
        endif
    else
        call writefile(split(string(b:marks_file_comments), "\n"), l:file_name)
    endif
endfunction

" ----------------------------------------------------------------------------

" 加载文件标记注释
function! MarksLoadFileComments()
    let l:filepath = expand('%:p')
    let l:comment_file = substitute(l:filepath, '[\\/:]', '-', 'g')
    let l:file_name = expand('~/.vim/mark_comments/' . l:comment_file . '_mark_comments')
    if filereadable(l:file_name)
        let b:marks_file_comments = eval(join(readfile(l:file_name), "\n"))
    else
        let b:marks_file_comments = {}
    endif
endfunction

" ----------------------------------------------------------------------------

" :TODO: 所有需要映射的文件用一个windows下的批处理脚本来处理
" :TODO: 目前不确定我自定义的补全是否会和coc还有completor的补全相冲突

" :TODO: 自己写一个插件,在弹出窗口中显示小写字母标记和大写字母标记[marker]的上下文,并且自动更新,可以手动切换这个弹出窗口的显示与关闭,最好是还可以重命令,并且可以持久化保存弹出窗口中的名字相关的映射,这样下次打开还能使用
" :TODO: 待实现标记窗口的上下文
" 利用弹出窗口自己设计的标记系统 {
" 标记的格式
" 标记 行 列 文件/文本
function! MarksSort()
    redir => l:marks
    silent marks
    redir END

    let l:lines = split(l:marks, '\n')
    call filter(l:lines, 'v:val =~ "^\\s\\+[a-zA-Z]"')
    call map(l:lines, 'split(v:val)')
    " 如果这些标记包含注释也要显示出来
    for l:line in l:lines
        let l:mark = l:line[0]
        let l:line[1] = printf('%-5s', l:line[1])
        let l:line[2] = printf('%-5s', l:line[2])

        if l:mark =~# '[A-Z]'
            let l:comment = get(g:marks_comments, l:mark, '')
        else
            let l:comment = get(b:marks_file_comments, l:mark, '')
        endif

        let l:comment = printf('%-10s', l:comment)
        call insert(l:line, l:comment, 1)
    endfor
    call sort(l:lines, 'MarksSortByLine')

    " return join(map(copy(l:lines), 'join(v:val, " ")'), "\n")
    return map(copy(l:lines), 'join(v:val, " ")')
endfunction

" ----------------------------------------------------------------------------

function! MarksDelete(marks)
    let l:marks = split(a:marks)
    for mark in l:marks
        execute 'delmarks' mark
        " 删除标记的同时也删除它的注释
        call MarksDeleteComment(mark)
    endfor
    call CommonUploadDynamicPopupWin()
endfunction

" ----------------------------------------------------------------------------

" 定义添加标记并调用自定义函数的函数
function! MarksAddOrRemove(mark)
    let lnum = line('.')
    let col = col('.')
    let pos = getpos("'" . a:mark)[1]
    execute 'delmarks ' . a:mark
    " 删除标记的同时也删除它的注释
    call MarksDeleteComment(a:mark)
    if pos != lnum
        call setpos("'" . a:mark, [0, lnum, col, 0])
    endif
    call CommonUploadDynamicPopupWin()
endfunction

" ----------------------------------------------------------------------------

function! MarksEnableMappings()
    for char in range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z'))
        execute 'nnoremap <silent> m' . nr2char(char) . ' :call MarksAddOrRemove("' . nr2char(char) . '")<CR>'
    endfor
endfunction

" ----------------------------------------------------------------------------

function! MarksDisableMappings()
    for char in range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z'))
        let key = 'm' . nr2char(char)
        if !empty(maparg(key, 'n'))
            execute 'nunmap ' . key
        endif
    endfor
endfunction


" ----------------------------------------------------------------------------

function! MarksUpdate(type)
    let marks_dict = {
        \ 'n': map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)'),
        \ 'N': map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)')
        \ }
    if has_key(marks_dict, a:type)
        let marks = marks_dict[a:type]
    else
        echo "Invalid type. Use 'n' for lowercase and 'N' for uppercase."
        return
    endif

    " :TODO: 一个循环后最大标记永远为z,这里该如何处理?用全局变量又不太好,暂时先手动清理吧
    " 获取当前最大的标记
    let max_mark = ''
    for mark in marks
       if !empty(getpos("'" . mark)[1])
            let max_mark = mark
        endif
    endfor

    " 计算下一个标记
    if max_mark == ''
        let next_mark = marks[0]
    else
        let next_index = (index(marks, max_mark) + 1) % len(marks)
        let next_mark = marks[next_index]
    endif

    " 设置下一个标记
    execute 'mark ' . next_mark
    " 更新标记列表
    call CommonUploadDynamicPopupWin()
endfunction


" ----------------------------------------------------------------------------

function! MarksStopPopUpAutoCmd()
    " " 清除autocmd事件
    " augroup DynamicPopup
    "     autocmd!
    " augroup END

    " 关闭弹出窗口
    if !exists("b:common_dynamic_content_win")
        let b:common_dynamic_content_win = -1
    endif
    if b:common_dynamic_content_win != -1
        call popup_close(b:common_dynamic_content_win)
        let b:common_dynamic_content_win = -1
    endif
endfunction

" ----------------------------------------------------------------------------

" Autocmd的实现 {
function! MarksStartAutoCmd()
    if !exists("b:common_dynamic_content_win")
        let b:common_dynamic_content_win = -1
    endif
    " 如果前面已经有一个需要先关闭
    call MarksStopPopUpAutoCmd()

    " 创建一个空的弹出窗口
    let opts = { 'line': 'cursor',
        \ 'col': 'cursor',
        \ 'padding': [0,1,0,1],
        \ 'wrap': v:false,
        \ 'border': [],
        \ 'close': 'none',
        \ 'highlight': 'Pmenu',
        \ 'resize': 1,
        \ 'zindex': 100,
        \ 'maxheight': 20,
        \ 'maxwidth': 80,
        \ 'title': 'tips',
        \ 'dragall': 1,
        \ 'scrollbar': 1}
    let b:common_dynamic_content_win = popup_create([''], opts)

    " " 设置autocmd事件
    " augroup DynamicPopup
    "     autocmd!
    "     autocmd CursorMoved * call CommonUploadDynamicPopupWin()
    " augroup END

    " 手动打开
    call CommonUploadDynamicPopupWin()

endfunction


" ----------------------------------------------------------------------------

function! MarksSortByLine(mark1, mark2)
    return a:mark1[1] - a:mark2[1]
endfunction

" ----------------------------------------------------------------------------

" viminfo 设置规则
" set viminfo=%,<800,'10,/50,:100,h,f0,n~/.vim/cache/.viminfo
"             | |    |   |   |    | |  + viminfo file path
"             | |    |   |   |    | + file marks 0-9,A-Z 0=NOT stored
"             | |    |   |   |    + disable 'hlsearch' loading viminfo
"             | |    |   |   + command-line history saved
"             | |    |   + search history saved
"             | |    + files marks saved
"             | + lines saved each register (new name for ", vi6.2)
"             + save/restore buffer list
function! SetProjectViminfo()
    " 先恢复默认
    set viminfo='800,<50,s10,h,rA:,rB:
    execute 'set viminfo+=n' . '~/.vim/default_viminfo'
    execute 'silent! rviminfo ' . '~/.vim/default_viminfo'
    let g:viminfo_file_path = '~/.vim/default_viminfo'

    " 获取项目根目录
    let l:project_root = finddir('.git', ';')
    if empty(l:project_root)
        let l:project_root = finddir('.hg', ';')
    endif
    if empty(l:project_root)
        let l:project_root = finddir('.svn', ';')
    endif
    if empty(l:project_root)
        let l:project_root = findfile('Makefile', ';')
    endif
    if empty(l:project_root)
        let l:project_root = findfile('package.json', ';')
    endif

    " echom l:project_root

    if !empty(l:project_root)
        let l:project_root = fnamemodify(l:project_root, ':p:h')
    endif

    echom l:project_root

    " 如果找到了项目根目录，设置 viminfo 文件路径
    if !empty(l:project_root)
        let l:dirpath = '~/.vim/viminfo/'
        if !isdirectory(expand(l:dirpath))
            call mkdir(expand(l:dirpath), 'p')
        endif

        let l:viminfo_file = substitute(l:project_root, '[\\/:]', '-', 'g')
        let l:viminfo_path = l:dirpath . 'viminfo_' . l:viminfo_file
        let g:viminfo_file_path = l:viminfo_path
        set viminfo='800,<50,s10,h,rA:,rB:
        execute 'set viminfo+=n' . l:viminfo_path

        " 重新加载viminfo内容
        execute 'silent! rviminfo ' . l:viminfo_path
    endif

    " viminfo更新后需要改变全局标记的文件
    call MarksLoadComments()
endfunction


" ----------vim-bookmarks 书签插件配置 }----------------------------------------

" --------------------- 自动命令 ---------------------------------------------------------------------------------------

autocmd VimEnter * call SetProjectViminfo() " 每次启动 Vim 时调用 SetProjectViminfo 函数
autocmd VimLeavePre * call MarksSaveGlobalComments()
                                            " 在Vim退出时保存全局标记注释(:TODO:这里要判断下是不是最后一个实例,只有最后一个实例才能保存)
autocmd BufEnter * if &buftype == '' | call MarksLoadFileComments() | endif
                                            " 在进入buffer时加载文件标记注释
autocmd BufLeave * if &buftype == '' | call MarksSaveFileComments() | endif
                                            " 在离开buffer时保存文件标记注释
autocmd VimLeavePre * call MarksSaveFileComments()
                                            " 在Vim退出之前保存所有文件标记注释
" " 在标签页切换时保存和加载文件标记注释
" autocmd TabLeave * call MarksSaveFileComments()
" autocmd TabEnter * call MarksLoadFileComments()
" :TODO: 当前配置中自动命令太多了,屏蔽m快捷键映射和NERD_tree的相关操作,也许还有更好的实现方式
autocmd BufEnter * if ! bufname('%') =~ 'NERD_tree' | call MarksEnableMappings() | endif
autocmd BufEnter * if bufname('%') =~ 'NERD_tree' | call MarksDisableMappings() | endif
autocmd BufEnter * if &buftype == '' | call CommonUploadDynamicPopupWin()
                                            " 进入 buffer 的时候更新标记

" --------------------- 按键绑定 ---------------------------------------------------------------------------------------

nnoremap <leader>svm :call MarksSaveGlobalComments()<cr> \| :call SetProjectViminfo()<cr>
                                            " marks: 重置当前环境的 viminfo(切换新项目时)
nnoremap <silent> <leader>ama :call MarksAddComment(input('Mark: '), input('Comment: '))<CR>
                                            " marks：添加标记注释
nnoremap <silent> <leader>amx :call MarksDeleteComment(input('Mark: '))<CR>
                                            " marks：删除标记注释
nnoremap <silent> <leader>smm :call MarksDelete(input('Enter marks to delete (space-separated): '))<CR>
                                            " marks：一键清除所有的小写和大写字母标记
nnoremap <silent> <leader>smd :call MarksDelete(join(map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)'), ' '))<cr>
                                            " marks: 删除当前文件中所有的小写字母 marks 标记
nnoremap <silent> <leader>smD :call MarksDelete(join(map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)'), ' '))<cr>
                                            " marks: 删除当前文件中所有的大写字母 marks 标记
nnoremap <silent> <leader>smn :call MarksUpdate('n')<cr>
                                            " marks: 添加下一个小写字母 marks 标记
nnoremap <silent> <leader>smN :call MarksUpdate('N')<cr>
                                            " marks: 添加下一个大写字母 marks 标记
nnoremap <silent> <leader>smx :call MarksStopPopUpAutoCmd()<cr>
                                            " marks: 关闭显示当前文件所有marks标记
nnoremap <silent> <leader>smt :call MarksStartAutoCmd()<cr>
                                            " marks: 显示当前文件所有marks标记
nnoremap <silent> <leader>smu :call CommonUploadDynamicPopupWin()<cr>
                                            " marks: 更新显示当前文件所有marks标记
nnoremap <silent> <leader>sms :call PopupMenuShowKeyBindings('and', 'auto', ':MarksSort')<cr>
                                            " marks: 静态显示当前文件所有marks标记

" ----------vim-bookmarks 书签插件配置 {----------------------------------------
let g:bookmark_save_per_working_dir = 0
" 这里不能设置自动保存，不然会在很多目录保存书签，目前不知道原因
let g:bookmark_auto_save = 1

" 不要使用默认的按键映射
let g:bookmark_no_default_key_mappings = 1
nnoremap <Leader>bt <Plug>BookmarkToggle| " 书签: 切换书签打开与关闭
nnoremap <Leader>bi <Plug>BookmarkAnnotate| " 书签: 创建一个注释书签
nnoremap <Leader>ba <Plug>BookmarkShowAll| " 书签: 显示所有的书签
nnoremap <Leader>bn <Plug>BookmarkNext| " 书签: 跳转到下一个书签
nnoremap <Leader>bp <Plug>BookmarkPrev| " 书签: 跳转到上一个书签
nnoremap <Leader>bc <Plug>BookmarkClear| " 书签: 删除当前书签
nnoremap <Leader>bx <Plug>BookmarkClearAll| " 书签: 删除所有书签

" these will also work with a [count] prefix
nnoremap <Leader>bk <Plug>BookmarkMoveUp| " 书签: 当前书签行上移
nnoremap <Leader>bj <Plug>BookmarkMoveDown| " 书签: 当前书签行下移
nnoremap <Leader>bl <Plug>BookmarkMoveToLine| " 书签: 书签移动到某一行

" =====================File: marks.vim }======================= 自定义书签 =============================================

