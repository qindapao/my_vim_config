
" =====================File: jump.vim {======================= 代码笔记跳转 ====

" ----------------------------------------------------------------------------

function! JumpToCode()
    " 获取当前光标下的行和列
    let l:line = getline('.')
    let l:col = col('.')

    " 查找所有匹配的路径和行号
    " [{[os/os_uname_a.sh:12]}]
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\[\{\[([^\[\]\{\};]*);(\d+)\]\}\]', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\[\{\[([^\[\]\{\};]*);(\d+)\]\}\]', l:start)
            let l:end = l:start + strlen(match_str)
            if l:col > l:start && l:col <= l:end
                let l:match = [l:start, l:end, match_str]
                break
            endif
            let l:start = l:end
        endif
    endwhile

    if empty(l:match)
        echo "光标不在有效的路径和行号范围内"
        return
    endif

    let l:matches_list = matchlist(match_str, '\v\[\{\[([^\[\]\{\};]*);(\d+)\]\}\]')
    let [ l:relative_path, l:line_number ] = [ l:matches_list[1], l:matches_list[2] ]

    " 获取到的链接有几种情况
    " 1. l:relative_path 为空
    "   表示锚点在当前文件内
    " 2. l:relative_path 为+xx/yy/zz.txt
    "   表示锚点在当前目录的子目录中
    " 3. l:relative_path 为xx/yy/zz.txt
    "   表示锚点和当前连接拥有相同的父目录xx,找到当前连接路径中的xx,然后解析出锚点链接
    if empty(l:relative_path)
        let l:full_path = CommonGetCurrentFileAndPath()
    elseif strpart(l:relative_path, 0, 1) == '+'
        let l:full_path = CommonGetCurrentPath() . '/' . strpart(l:relative_path, 1)
    else
        " 得到获取路径的顶级路径
        let father_dir_name = split(l:relative_path, '/')[0]
        let father_path = JumpFindCustomDir(father_dir_name)
        if father_path == ''
            echo "get father path is null"
            return
        endif
        let full_path = father_path . '/' . l:relative_path
    endif

    " 检查当前窗口布局并决定如何分屏
    if winnr('$') == 1
        " 只有一个窗口，直接垂直分屏
        execute 'vsplit ' . l:full_path
    else
        " 多个窗口，先切换到左边窗口
        execute 'wincmd h'
        " 切换到最上面的窗口
        execute 'wincmd t'
        " 在左边窗口中水平分屏
        execute 'split ' . l:full_path
    endif

    execute l:line_number
endfunction

" ----------------------------------------------------------------------------

" 把当前的相对路径和行号信息保存到系统剪切板中
" [{[os/os_uname_a.sh:12]}]
function! JumpRecordCodePathAndLineToSystemReg()
    " 计算相对路径
    let l:full_path = CommonGetCurrentFileAndPath()
    if empty(l:full_path)
        return
    endif

    let l:line_number = line('.')

    " 生成路径和行号字符串
    let l:result = '[{[' . l:full_path . ';' . l:line_number . ']}]'
    let @+ = l:result
endfunction


" ----------------------------------------------------------------------------

" :TODO: 其实这个也有缺陷,无法处理目录名和文件名都重复的情况
function! JumpFindCustomDir(target_path)
    let l:current_dir = expand('%:p:h')
    let l:current_dir = substitute(l:current_dir, '\\', '/', 'g')

    while l:current_dir != '/' && l:current_dir !~ '^[A-Za-z]:/$'
        let l:full_path = l:current_dir . '/' . a:target_path
        if filereadable(l:full_path)
            return l:current_dir
        endif
        let l:current_dir = fnamemodify(l:current_dir, ':h')
    endwhile
    return ''
endfunction


" ----------------------------------------------------------------------------

" 锚点的格式
" {[{id:这是一个锚点}]}
" 定义快捷方式在锚点上生成指向锚点的链接并保存到系统剪切板中
" [{[src/os/os_uname_a.sh:#这是一个锚点]}]
function! JumpRecordHunkToSystemReg()
    let l:line = getline('.')
    let l:col = col('.')
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\{\[\{id:([^\{\}\[\]]+)\}\]\}', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\{\[\{id:([^\{\}\[\]]+)\}\]\}', l:start)
            let l:end = l:start + strlen(match_str)
            if l:col > l:start && l:col <= l:end
                let l:match = [l:start, l:end, match_str]
                break
            endif
            let l:start = l:end
        endif
    endwhile

    if empty(l:match)
        echo "光标不在有效的锚点内"
        return
    endif

    let l:full_path = CommonGetCurrentFileAndPath()
    if empty(l:full_path)
        return
    endif

    let l:matches_list = matchlist(match_str, '\v\{\[\{id:([^\{\}\[\]]+)\}\]\}')
    let l:hunk_str = '[{[' . l:full_path . ';#' . l:matches_list[1] . ']}]'
    let @+ = l:hunk_str
endfunction

" ----------------------------------------------------------------------------

" 通过锚点链接跳转到锚点
function! JumpToHunkPoint()
    " 获取当前光标下的行和列
    let l:line = getline('.')
    let l:col = col('.')

    " 查找所有匹配的路径和锚点名
    " [[os/os_uname_a.sh:#我是一个锚点]]
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\[\{\[([^\[\]\{\};#]*);#([^\[\]\{\};#]+)\]\}\]', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\[\{\[([^\[\]\{\};#]*);#([^\[\]\{\};#]+)\]\}\]', l:start)
            let l:end = l:start + strlen(match_str)
            if l:col > l:start && l:col <= l:end
                let l:match = [l:start, l:end, match_str]
                break
            endif
            let l:start = l:end
        endif
    endwhile

    if empty(l:match)
        echo "光标不在有效的路径和行号范围内"
        return
    endif

    let l:matches_list = matchlist(match_str, '\v\[\{\[([^\[\]\{\};#]*);#([^\[\]\{\};#]+)\]\}\]')
    let [ l:relative_path, l:hunk_str ] = [ l:matches_list[1], '{[{id:' . l:matches_list[2] . '}]}' ]

    " 拼接完整路径
    if empty(l:relative_path)
        let l:full_path = CommonGetCurrentFileAndPath()
    elseif strpart(l:relative_path, 0, 1) == '+'
        let l:full_path = CommonGetCurrentPath() . '/' . strpart(l:relative_path, 1)
    else
        " 得到获取路径的顶级路径
        let father_dir_name = split(l:relative_path, '/')[0]
        let father_path = JumpFindCustomDir(l:relative_path)
        if father_path == ''
            echo "get father path is null"
            return
        endif
        let full_path = father_path . '/' . l:relative_path
    endif

    let cur_path = expand('%:p')
    let cur_path = substitute(cur_path, '\\', '/', 'g')

    " 先在文件中找到锚点字符串的行列值
    try
        let hunk_str = escape(hunk_str, '\\[\\]')
        " 搜索的时候就跳转到文件了,不需要单独打开文件
        if cur_path == l:full_path
            " 这里使用%的作用是防止重新打开文件
            silent execute 'vimgrep /' . l:hunk_str . '/ ' . '%'
        else
            silent execute 'vimgrep /' . l:hunk_str . '/ ' . l:full_path
        endif
        let result = getqflist({'items': 0}).items[0]    
    catch
        echo "没有找到匹配的锚点"
        return
    endtry

    call cursor(result.lnum, result.col)
endfunction

" ----------------------------------------------------------------------------

" 在当前位置插入一个hunk
function! JumpCreateNewHunkToSystemReg()
    let user_input = ''
    while 1
        let user_input = input('请输入设置勾子文本: ', user_input)
        let formatted_input = '{[{id:' . user_input . '}]}'

        " 完全按照字符串的字面意义进行解释
        let check_repeat = search('\V' . formatted_input, 'nw')

        if check_repeat > 0
            " 提示用户输入的内容重复
            echo ' 勾子重复，请重新输入。'
        else
            " 将格式化后的内容放入系统剪切板
            let @+ = formatted_input
            break
        endif
    endwhile
endfunction

" ----------------------------------------------------------------------------

" 在当前位置插入代码链接
function! JumpInsertCodePath()
    " 获取默认截切板寄存器中的内容
    let system_reg_str = getreg('+')
    let system_reg_list = matchlist(system_reg_str, '\v\[\{\[([^\[\]\{\};]+);(\d+)\]\}\]')
    " echo "system_reg_str:" . system_reg_str . ';' . "system_reg_list:" . string(system_reg_list) . ';'
    let [full_path_file, line_num] = [system_reg_list[1], system_reg_list[2]]
    let record_file = fnamemodify(full_path_file, ':t')
    let record_path = fnamemodify(full_path_file, ':h')

    let cur_path_file = CommonGetCurrentFileAndPath()

    let cur_file = fnamemodify(cur_path_file, ':t')
    let cur_path = fnamemodify(cur_path_file, ':h')

    " 如果文件路径相同,那么是当前文件
    " echo "full_path_file:" . full_path_file . ';' . 'cur_path_file:' . cur_path_file . ';'


    if full_path_file == cur_path_file
        let @+ = '[{[' . ';' . line_num . ']}]'
    " 如果链接路径是以当前路径开头的,那么链接路径是当前路径的子路径
    elseif strpart(record_path, 0, len(cur_path)) == cur_path
        let @+ = '[{[+' . strpart(full_path_file, len(cur_path)+1) . ';' . line_num . ']}]'
    else
        " 最复杂的情况
        " 比如这是需要链接到的目标地址: [{[D:/zim_book/项目管理/北辰项目/点灯.txt;18]}]
        " 我们当前所处的目录的完整地址: [{[D:/zim_book/项目管理/北辰项目/项目进度整理/重点工作/5902.txt;78]}]
        " 需要生成的链接为: [{[北辰项目/点灯.txt;18]}]
        let relative_path = ''
        let current_dir = cur_path

        while l:current_dir != '/' && l:current_dir !~ '^[A-Za-z]:/$'
            let rest_path = strpart(record_path, 0, len(current_dir))
            if rest_path == current_dir
                let rest_path_up = fnamemodify(rest_path, ':h')
                let relative_path = record_path[len(rest_path_up)+1:]
                break
            endif
            let current_dir = fnamemodify(current_dir, ':h')
        endwhile

        if l:relative_path == ''
            let l:relative_path = record_path
        endif

        let @+ = '[{[' . l:relative_path . '/' . record_file . ';' . line_num . ']}]'
    endif
endfunction


" ----------------------------------------------------------------------------

" 在当前位置插入hunk链接
function! JumpInsertHunkPath()
    " 获取默认截切板寄存器中的内容
    let system_reg_str = getreg('+')
    let system_reg_list = matchlist(system_reg_str, '\v\[\{\[([^\[\]\{\};#]*);#([^\[\]\{\};#]+)\]\}\]')

    let [full_path_file, hunk_str] = [system_reg_list[1], system_reg_list[2]]
    let record_file = fnamemodify(full_path_file, ':t')
    let record_path = fnamemodify(full_path_file, ':h')

    let cur_path_file = CommonGetCurrentFileAndPath()

    let cur_file = fnamemodify(cur_path_file, ':t')
    let cur_path = fnamemodify(cur_path_file, ':h')

    " 如果文件路径相同,那么是当前文件
    " echo "full_path_file:" . full_path_file . ';' . 'cur_path_file:' . cur_path_file . ';'


    if full_path_file == cur_path_file
        let @+ = '[{[' . ';#' . hunk_str . ']}]'
    " 如果链接路径是以当前路径开头的,那么链接路径是当前路径的子路径
    elseif strpart(record_path, 0, len(cur_path)) == cur_path
        let @+ = '[{[+' . strpart(full_path_file, len(cur_path)+1) . ';#' . hunk_str . ']}]'
    else
        " 最复杂的情况
        " 比如这是需要链接到的目标地址: [{[D:/zim_book/项目管理/北辰项目/点灯.txt;#hunk_str]}]
        " 我们当前所处的目录的完整地址: [{[D:/zim_book/项目管理/北辰项目/项目进度整理/重点工作/5902.txt;#hunk_str]}]
        " 需要生成的链接为: [{[北辰项目/点灯.txt;#hunk_str]}]
        let relative_path = ''
        let current_dir = cur_path

        while l:current_dir != '/' && l:current_dir !~ '^[A-Za-z]:/$'
            let rest_path = strpart(record_path, 0, len(current_dir))
            if rest_path == current_dir
                let rest_path_up = fnamemodify(rest_path, ':h')
                let relative_path = record_path[len(rest_path_up)+1:]
                break
            endif
            let current_dir = fnamemodify(current_dir, ':h')
        endwhile

        if l:relative_path == ''
            let l:relative_path = record_path
        endif

        let @+ = '[{[' . l:relative_path . '/' . record_file . ';#' . hunk_str . ']}]'
    endif
endfunction

" ----------------------------------------------------------------------------

" :TODO: 后续如果中括号和冒号不够防呆,可以使用另外的特殊的unicode字符替代,或者使用更多的边界字符防呆,不过目前这样就够
nnoremap <silent> <leader>jj :call JumpToCode()<CR>
nnoremap <silent> <leader>jl :call JumpRecordCodePathAndLineToSystemReg()<CR>
nnoremap <silent> <leader>jr :call JumpRecordHunkToSystemReg()<CR>
nnoremap <silent> <leader>jh :call JumpToHunkPoint()<CR>
nnoremap <silent> <leader>jn :call JumpCreateNewHunkToSystemReg()<CR>
nnoremap <silent> <leader>jc :call JumpInsertCodePath()<CR>
nnoremap <silent> <leader>jk :call JumpInsertHunkPath()<CR>
" 插入代码链接
" 插入锚点链接



" =====================File: jump.vim }======================= 代码笔记跳转 ====

