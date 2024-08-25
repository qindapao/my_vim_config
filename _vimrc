" VIM使用最大原则(只要功能够用就不要折腾,不要轻易更新.时间要花在对的事情上)
"       o                                  
"       o                ooooooooo         
"       o      ooooo     o       o         
"      oooooo  o   o     o       o         
"      o  o    o   o     o       o         
"     o   o    o   o     o       o         
"         o    o   o     ooooooooo         
"         o    o   o         o             
"     oooooooo o   o         o             
"         o    o   o     o   o             
"        o o   o   o     o   oooooo        
"        o o   o   o     o   o             
"       o   o  ooooo    o o  o             
"       o   o  o   o    o  o o             
"      o    o          o    ooooooooo      
"     o               o                    
" :TODO: 文件中的替换操作或者别的需要传入参数的操作可能因为转义字符出错,暂时没处理,如果遇到问题可以在这方面排查
" 按键组
"
" 按键组->补全
" 按键组->标签导航
" 按键组->书签
" 按键组->命令
" 按键组->高亮
" 按键组->窗口管理
" 按键组->目录树
" 按键组->跳转
" 按键组->markdown
" 按键组->git
" 按键组->und
" 按键组->搜索
" 按键组->编辑
" 按键组->zim
" 按键组->终端
" 按键组->多标签
" 按键组->文件
" 按键组->辅助
" 按键组->quickfix
" 按键组->locallist
" 按键组->构建
" 按键组->lint
" 按键组->项目
" 按键组->调试
" 按键组->替换
" 备注: 为了防止映射的关键字和文件中别的注释冲突,所以比如"搜索"这种关键字在某些地方的注释中变成了"搜 索"，中间用一个空格区分开了。其它的关键字也类似。

" Vim with all enhancements
source $VIMRUNTIME/vimrc_example.vim

" Remap a few keys for Windows behavior
source $VIMRUNTIME/mswin.vim

" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
    set diffexpr=MyDiff()
endif
function MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg1 = substitute(arg1, '!', '\!', 'g')
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg2 = substitute(arg2, '!', '\!', 'g')
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let arg3 = substitute(arg3, '!', '\!', 'g')
    if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
            if empty(&shellxquote)
                let l:shxq_sav = ''
                set shellxquote&
            endif
            let cmd = '"' . $VIMRUNTIME . '\diff"'
        else
            let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
    else
        let cmd = $VIMRUNTIME . '\diff'
    endif
    let cmd = substitute(cmd, '!', '\!', 'g')
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
    if exists('l:shxq_sav')
        let &shellxquote=l:shxq_sav
    endif
endfunction

function! GitDiff(spec)
    vertical new
    setlocal bufhidden=wipe buftype=nofile nobuflisted noswapfile
    let cmd = "++edit #"
    if len(a:spec)
        let cmd = printf('!git -C %s show %s:./%s', shellescape(expand('#:p:h'), 1), a:spec, shellescape(expand('#:t'), 1))
    endif
    execute "read " . cmd
    silent 0d_
    diffthis
    wincmd p
    diffthis
endfunction
command! -nargs=? Diff call GitDiff(<q-args>)

function! TrimString(s)
    return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

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
"

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
    call LoadGlobalMarkComments()
endfunction

" 每次启动 Vim 时调用 SetProjectViminfo 函数
autocmd VimEnter * call SetProjectViminfo()


" 以下函数的来源 https://github.com/youngyangyang04/PowerVim/blob/master/.vimrc
" usage :call GenMarkdownSectionNum    给markdown/zimwiki 文件生成目录编号
" 如果要在某些脚本代码中写注释,那么使用#----这种格式来过滤
function! GenSectionNum(file_type)
    if &ft != a:file_type
        echohl Error
        echo "filetype is not " . a:file_type
        echohl None
        return
    endif

    if a:file_type == 'markdown'
        let fit_patter = '^\(#\+\) \?\([0-9.]\+ \)\? *\(.*\)'
    elseif a:file_type == 'zim'
        let fit_patter = '^\(=\+\) \?\([0-9.]\+ \)\? *\(.*\)'
    else
        echohl Error
        echo "filetype is not surport."
        return
    endif

    let lvl = []
    let sect = []
    let out = ""
    for i in range(1, line('$'), 1)
        let line = getline(i)
        if a:file_type == 'markdown'
            let heading_lvl = strlen(substitute(line, '^\(#*\).*', '\1', ''))
            " 如果格式是#-那么直接跳过(短杠可能有无数个,并且后面可能还有别的字符)
            if line =~ '^#\+-\+.*'
                continue
            endif
        elseif a:file_type == 'zim'
            let heading_lvl = 7 - strlen(substitute(line, '^\(=*\).*', '\1', ''))
        endif

        if heading_lvl < 2
            if heading_lvl == 1
                " 顶级标签可能不只一个
                let lvl = []
                let sect = []
            endif
            continue
        endif
        " there should be only 1 H1, topmost, on a conventional web page
        " we should generate section numbers begin with the first heading level 2
        if len(lvl) == 0
            if heading_lvl != 2 " count from level 2
                echohl Error
                echo "subsection must have parent section, ignore illegal heading line at line " . i
                echohl None
                continue
            endif
            call add(sect, 1)
            call add(lvl, heading_lvl)
        else
            if lvl[-1] == heading_lvl
                let sect[-1] = sect[-1] + 1
            elseif lvl[-1] > heading_lvl " pop all lvl less than heading_lvl from tail
                while len(lvl) != 0 && lvl[-1] > heading_lvl
                    call remove(lvl, -1)
                    call remove(sect, -1)
                endwhile
                let sect[-1] = sect[-1] + 1
            elseif lvl[-1] < heading_lvl
                if heading_lvl - lvl[-1] != 1
                    echohl Error
                    echo "subsection must have parent section, ignore illegal heading line at line " . i
                    echohl None
                    continue
                endif
                call add(sect, 1)
                call add(lvl, heading_lvl)
            endif
        endif

        let cur_sect = ""
        for j in sect
            let cur_sect = cur_sect . "." . j
        endfor
        let cur_sect = cur_sect[1:]
        let out = out . " " . cur_sect
        call setline(i, substitute(line, fit_patter, '\1 ' . cur_sect . ' \3', line))
    endfor
    " echo lvl sect out
    echo out
endfunc

" 获取选择模式下当前行选择的文本
function! GetVisualLine()
    let line = getline('.')
    let start = getpos("'<")[2] - 1
    let end = getpos("'>")[2] - 2
    return line[start:end]
endfunction

" 替换函数
function! MyReplaceWord(now_mode)
    if a:now_mode == 'n'
        let old_word = expand("<cword>")
    elseif a:now_mode == 'v'
        let old_word = GetVisualLine()
    endif
    let new_word = input("Replace " . old_word . " with: ")
    execute '%s/' . old_word . '/' . new_word . '/gc | update'
endfunction

" range 标识的函数才能在可视选择范围内执行
function! VisualReplaceWord() range
    let old_word = escape(getreg('"'), '/\&')
    " 设置默认值并且有机会可以修改默认pattern
    let old_word = input("old_patter: ", old_word)
    let new_word = input("Replace " . old_word . " with: ")
    execute "'<,'>s/" . old_word . "/" . new_word . "/gc | update"
endfunction

" 括号自动配对
runtime macros/matchit.vim
" :TODO: GUI VIM中设置垂直和水平的滚动条的宽度(目前没有找到方法,可能要通过windows系统设置)

" VisualBlock弹出窗口的显示模式(cover overlay)
let g:visual_block_popup_types = ['cover', 'overlay']
let g:visual_block_popup_types_index = 0

function! SwitchVisualBlockPopupType()
    let g:visual_block_popup_types_index = (g:visual_block_popup_types_index + 1) % len(g:visual_block_popup_types)

    " 更新弹出窗口
    call UpdateVisualBlockPopup()
endfunction

" vim enters visual mode and selects an area the same size as the x register
" ctrl j k h l move this selection area
function! VisualBlockMove(direction)
    " 移动光标
    if a:direction != 'null'
        execute 'silent! normal! 1' . a:direction
    endif

    call UpdateVisualBlockPopup()
endfunction

function! VisualBlockMouseMoveStart()
    let g:save_ctrl_mouseleft = maparg('<C-LeftMouse>', 'n')
    let g:save_ctrl_mouseright = maparg('<C-RightMouse>', 'n')

    nnoremap <silent> <C-LeftMouse> :call PasteVisualXreg(1)<CR>
    nnoremap <silent> <C-RightMouse> :call PasteVisualXreg(0)<CR>

    set mouse=n
    augroup VisualBlockMouseMove
        autocmd!
        autocmd CursorMoved * call UpdateVisualBlockPopup()
    augroup END

    call UpdateVisualBlockPopup()
endfunction

function! VisualBlockMouseMoveCancel()
    if exists('g:save_ctrl_mouseleft')
        execute 'nnoremap <silent> <C-LeftMouse> ' . g:save_ctrl_mouseleft
    endif

    if exists('g:save_ctrl_mouseright')
        " :TODO: 目前发现这里没有被正常还原成以前的操作
        execute 'nnoremap <silent> <C-RightMouse> ' . g:save_ctrl_mouseright
    endif

    augroup VisualBlockMouseMove
        autocmd!
    augroup END
    set mouse=a

    " 这里直接关闭弹出窗口
    call CloseVisualBlockPopWin()
endfunction

function! GetRegContent(reg_name)
    let regcontent = getreg(a:reg_name)
    let attempts = 0
    while empty(regcontent) && attempts < 20
        sleep 1m
        let regcontent = getreg(a:reg_name)
        let attempts += 1
    endwhile
    echo "read reg: " . a:reg_name . "times: " . attempts . ';' 
    return regcontent
endfunction

function! UpdateVisualBlockPopup()
    " 获取寄存器内容和类型
    " 由于当前使用的是系统剪切板会比较慢,所以增加一个延时让弹窗稳定
    " 使用系统寄存器虽然可能慢,但是可以跨vim实体复制粘贴非常方便
    " 后面如果对速度敏感那么可以考虑使用别的寄存器
    " 也有可能是弹窗无法响应太快的请求,所以这里让更新慢一些
    let regcontent = GetRegContent('+')

    let l:new_text = split(regcontent, "\n")
    let mask = []
    " 空格透明
    if g:visual_block_popup_types[g:visual_block_popup_types_index] == 'overlay'
        " 得到最长行(使用copy保证不修改原始列表)
        let l:max_display_length = max(map(copy(l:new_text), 'strdisplaywidth(v:val)'))
        " 行不够的补空格
        for i in range(0, len(l:new_text)-1)
            let l:line_length = strdisplaywidth(l:new_text[i])
            if l:line_length < l:max_display_length
                let l:new_text[i] .= repeat(' ', l:max_display_length - l:line_length)
            endif
        endfor 

        for i in range(len(l:new_text))
            let line = l:new_text[i]
            let j = 0
            for char in split(line, '\zs')
                if char == ' '
                    call add(mask, [j + 1, j + 1, i + 1, i + 1])
                endif
                let j += strdisplaywidth(char)
            endfor
        endfor
    endif

    if exists('g:visual_block_popup_id') && g:visual_block_popup_id != 0
        try
            let l:pos = popup_getpos(g:visual_block_popup_id)
            if empty(l:pos)
                throw 'Popup closed'
            endif
        catch
            " 弹出窗口不存在
            let g:visual_block_popup_id = 0
        endtry
    endif

    if exists('g:visual_block_popup_id') && g:visual_block_popup_id != 0
        " 更新弹出窗口的文本
        call popup_settext(g:visual_block_popup_id, l:new_text)

        " 更新弹出窗口的位置
        call popup_move(g:visual_block_popup_id, {
            \ 'line': 'cursor',
            \ 'col': 'cursor'
            \ })

        " 更新弹出窗口的透明掩码和其他属性
        call popup_setoptions(g:visual_block_popup_id, {
            \ 'mask': mask,
            \ 'highlight': 'MyVirtualText',
            \ 'moved': 'any',
            \ 'zindex': 100
            \ })
    else
        let g:visual_block_popup_id = popup_create(l:new_text, {
            \ 'line': 'cursor',
            \ 'col': 'cursor',
            \ 'zindex': 100,
            \ 'highlight': 'MyVirtualText',
            \ 'moved': 'any',
            \ 'mask': mask
            \ })
    endif
endfunction

function! PasteVisualXreg(is_space_replace)
    " 获取寄存器中的数据
    let regtype = getregtype('+')
    let regcontent = getreg('+')
    let blockwidth = str2nr(regtype[1:])
    let blockheight = len(split(regcontent, "\n"))
    let reg_text = split(regcontent, "\n")

    " 空元素用一个空格填充
    for i in range(len(reg_text))
        if empty(reg_text[i])
            let reg_text[i] = ' '
        endif
    endfor

    " 得到基于物理行列的字符数组,如果是宽字符,那么放置两份,但是合并的时候只取一份
    " 这是一个二维数组,第一维是行,第二维是每行的字符
    " 另外一个二维数组，对应起来记录每个字符的物理长度
    let reg_x_chars = []
    let reg_x_phy_lens = []
    let row_chars = []
    let row_phy_lens = []
    let start_row = line('.')
    let col = virtcol('.')
    for i in range(len(reg_text))
        let row = start_row + i
        let [chars_arr, index] = ProcessLine(row, col)

        if i == 0
            " 这里如果发生了空格填充那么需要把光标位置填充正确
            call SetLineStr(chars_arr, row, row, len(join(chars_arr[0:index], '')))
        endif

        let reg_line = reg_text[i]
        let j = 0
        for char in split(reg_line, '\zs')
            let char_phy_len = strdisplaywidth(char)
            if len(reg_x_chars) <= i
                call add(reg_x_chars, [])
                call add(reg_x_phy_lens, [])
            endif

            if char_phy_len == 2
                call extend(reg_x_chars[i], [char, ''])
                call extend(reg_x_phy_lens[i], [2, 0])
            else
                call extend(reg_x_chars[i], [char])
                call extend(reg_x_phy_lens[i], [1])
            endif
            let j += char_phy_len
        endfor

        let k = 0
        let k_index = index
        while 1
            " 如果覆盖层字符不是空格就覆盖
            if reg_x_chars[i][k] == ' '
                if a:is_space_replace
                    if k_index >= len(chars_arr)
                        call add(chars_arr, reg_x_chars[i][k])
                    else
                        let chars_arr[k_index] = reg_x_chars[i][k]
                    endif
                else
                    if k_index >= len(chars_arr)
                        call add(chars_arr, reg_x_chars[i][k])
                    endif
                endif
            else
                if k_index >= len(chars_arr)
                    call add(chars_arr, reg_x_chars[i][k])
                else
                    let chars_arr[k_index] = reg_x_chars[i][k]
                endif
            endif

            let k += 1
            if k >= j
                break
            endif
            let k_index += 1
        endwhile

        " 重新设置该行
        call setline(row, join(chars_arr, ''))
    endfor
endfunction

function CloseVisualBlockPopWin()
    if exists('g:visual_block_popup_id') && g:visual_block_popup_id != 0
        call popup_close(g:visual_block_popup_id)
    endif
endfunction

function! CloseHiddenBuffers()

    let open_buffers = []

    for i in range(tabpagenr('$'))
        call extend(open_buffers, tabpagebuflist(i + 1))
    endfor

    for num in range(1, bufnr("$") + 1)
        if buflisted(num) && index(open_buffers, num) == -1 && getbufvar(num, "&buftype") !=#'terminal'
            " 这里使用bdelete命令比较安全,如果后面想换成bw命令也是可以的
            exec "bdelete ".num
        endif
    endfor
endfunction

au BufEnter * call CloseHiddenBuffers()

function! AddBufferBr()
    " 因为airline的原因,下面两个参数会默认被设置为空,所以需要显示要自己重新设置下
    let g:bufferline_active_buffer_left = '['
    let g:bufferline_active_buffer_right = ']'
endfunction

function DisplayHTML()
    if &filetype == 'html'
        execute 'w'
        silent execute '!chrome' expand('%:p')
    endif
endfunction

" 设置多个omni函数的范例
function! OmniFuncPython(findstart, base)
    let l:res1 = python3complete#Complete(a:findstart, a:base)
    " 目前这个gtagsomnicomplete相当若,作用不是很大
    let l:res2 = gtagsomnicomplete#Complete(a:findstart, a:base)
    let l:res3 = OmniCompleteCustom(a:findstart, a:base)

    " 打印两个函数的返回结果
    " echom 'python3complete#Complete returns: ' . string(l:res1)
    " echom ' gtagsomnicomplete#Complete returns: ' . string(l:res2)
    " 3是列表 0是数字

    if ((type(l:res1) == 3 && empty(l:res1)) || type(l:res1) == 0) && (type(l:res2) == 3 && !empty(l:res2))
        return l:res2+l:res3
    elseif ((type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0) && (type(l:res1) == 3 && !empty(l:res1))
        return l:res1+l:res3
    elseif ((type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0) && ((type(l:res1) == 3 && empty(l:res1)) || type(l:res1) == 0)
        return l:res3
    else
        return l:res1 + l:res2 + l:res3
    endif
endfunction

function! OmniFuncShell(findstart, base)
    " 目前这个gtagsomnicomplete相当若,作用不是很大
    let l:res2 = gtagsomnicomplete#Complete(a:findstart, a:base)
    let l:res3 = OmniCompleteCustom(a:findstart, a:base)

    if (type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0
        return l:res3
    else
        return l:res2 + l:res3
    endif
endfunction


function! DeleteTerminalBuffers()
    for l:bufnr in range(1, bufnr('$'))
        if buflisted(l:bufnr) && getbufvar(l:bufnr, '&buftype') == 'terminal'
            execute 'bdelete!' l:bufnr
        endif
    endfor
endfunction

" 禁用关闭按钮，这样关闭按钮就不会覆盖我定义的标签页的样式
function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " 响应鼠标事件
        let s .= '%' . (i+1) . 'T'

        let s .= ' ' . (i + 1) . ' '
        let bufnr = tabpagebuflist(i+1)[tabpagewinnr(i+1) - 1]
        let filename = fnamemodify(bufname(bufnr), ':t')
        if strchars(filename) > 13
            let filename = strcharpart(filename, 0, 13) . '..'
        endif

        let s .= filename
        if getbufvar(bufnr, "&modified")
            let s .= ' +'
        endif

        let s .= ' |'
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    return s
endfunction



" 打开git远端上的分支
" function GitGetCurrentBranchRemoteUrl()

"     let remote_branch_info = system('git.exe rev-parse --abbrev-ref --symbolic-full-name @{upstream}')
"     let [remote_name, branch_name] = split(remote_branch_info, '/')

"     let init_addr = system('git.exe config --get remote.origin.url')
"     let middle_info = substitute(init_addr, 'xx.yy.com:2222', 'xx.yy.com', 'g')
"     let middle_info = split(middle_info, '@')[1]
"     let middle_info = split(middle_info, '.git')[0]

"     let get_adr = 'http://' . middle_info . '/file?ref=' . branch_name

"     silent execute '!chrome' get_adr
"     " 下面这种方式避免命令执行黑框弹出
"     call job_start(['chrome', get_adr])
" endfunction


" below are my personal settings
" 基本设置区域 {

" 交换文件放置到固定的目录中去
set directory^=$HOME/.vim/swap//

nnoremap <leader>dbt :call DeleteTerminalBuffers()<cr>| " 终端: 删除所有的终端buffer

nnoremap <leader>pwd :pwd<cr>| " 目录树: 显示当前目录

set guioptions-=e

" 禁用鼠标防止产生异常字符
set mouse-=a

set tabline=%!MyTabLine()



set autochdir

" 设置vim的窗口分割竖线的形状
set fillchars=vert:▒

if has('termguicolors')
    set termguicolors
endif

if has('gui_running')
    " 目前这里无法回到上次的中文输入法,不知道原因
    set imactivatekey=C
    inoremap <silent> <ESC> <ESC>: set iminsert=2<CR>
endif



" 设置默认的终端为bash
let g:terminal_cwd = 1
" 当前wsl下的免密输入已经搞定,所以就使用wsl下的环境
let g:terminal_shell = 'bash'


filetype plugin indent on                                                        " 打开文件类型检测
set history=1000
let mapleader="\\"
" txt文本不允许vim自动换行 https://superuser.com/questions/905012/stop-vim-from-automatically-tw-78-line-break-wrapping-text-files
au! vimrcEx filetype text

set nu                                                                           " 打开当前行号显示
set rnu                                                                          " 打开相对行号

set nocompatible

set ruler

set colorcolumn=81,121

set nowrap

" 开启命令行的自动补全
set wildmenu

" 设置文件的编码顺序
set fileencoding=utf-8
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,cp936,gb18030,big5,latin1


" 如果是markdown文件设置wrap
autocmd filetype markdown set wrap

" 设置标签页的显示格式
set guitablabel=%N%M%t
" 切换标签页快捷方式
noremap <silent> tn :tabnew<CR>| " 多标签: 创建新标签页
noremap <silent> tc :tabclose<CR>| " 多标签: 关闭当前标签页
noremap <silent> tC :q!<CR> " 多标签: 强制关闭当前标签页
noremap <silent> to :tabonly<CR>| " 多标签: 只保留当前标签页
nnoremap <Tab> gt<cr>| " 多标签: 向前切换标签页
nnoremap <S-Tab> gT<cr>| " 多标签: 向后切换标签页
:nn <M-1> 1gt| " 多标签: 切换到第1个标签页
:nn <M-2> 2gt| " 多标签: 切换到第2个标签页
:nn <M-3> 3gt| " 多标签: 切换到第3个标签页
:nn <M-4> 4gt| " 多标签: 切换到第4个标签页
:nn <M-5> 5gt| " 多标签: 切换到第5个标签页
:nn <M-6> 6gt| " 多标签: 切换到第6个标签页
:nn <M-7> 7gt| " 多标签: 切换到第7个标签页
:nn <M-8> 8gt| " 多标签: 切换到第8个标签页
:nn <M-9> 9gt| " 多标签: 切换到第9个标签页
:nn <M-0> :tablast<CR>| " 多标签: 切换到最后一个标签页

nnoremap <silent> <leader>new :new<cr>| " 文件: 创建一个新文件
nnoremap <silent> <leader>enew :enew<cr>| " 文件: 创建一个新文件并编辑

" 替换保持列的位置不变
nnoremap gR R
nnoremap R gR

set scrolloff=3

" search highlight
set hlsearch| " 高亮: 设置搜索高亮
noremap <silent> <leader>noh :nohlsearch<CR>| " 高亮: 取消搜索高亮
noremap <silent> # :nohlsearch<CR>| " 高亮: 取消搜索高亮


set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                                                                    " 用空格替换TAB
" perl格式的文件,TAB就是TAB, 不要替换
autocmd filetype perl setlocal noexpandtab

" 设置星号不要自动跳转,只高亮
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>| " 搜索: 搜索并高亮当前单词
" :TODO: 这里使用了默认的寄存器，如果后续有干扰，需要保持默认寄存器干净，可能需要修改这里
xnoremap <silent> * y:let @/='\V'.escape(@", '/\')<CR>:let old_pos = getpos(".")<CR>:set hls<CR>:call setpos('.', old_pos)<CR>| " 搜索: 可视模式搜索并高亮当前单词


" 星号切换打开和关闭高亮(暂时不使用)
" nnoremap <silent> * :if &hlsearch \| let @/= '\<' . expand('<cword>') . '\>' \| set nohls \| else \| let @/= '\<' . expand('<cword>') . '\>' \| set hls \| endif <cr>

set cursorline                                                                   " highlight current line

nnoremap <silent> <leader>scsc :set cursorcolumn<cr>| " 辅助: 高亮当前列
nnoremap <silent> <leader>sncsc :set nocursorcolumn<cr>| " 辅助: 取消高亮当前列

" cursor not blinking
set guicursor+=a:blinkon0

" set guifont=sarasa\ mono\ sc:h13
" set guifont=Yahei\ Fira\ Icon\ Hybrid:h11
" set guifont=微软雅黑\ PragmataPro\ Mono:h8
" 这个字体某些方向符号无法显示
set guifont=Fira\ Code:h8
" set guifont=Microsoft\ YaHei\ Mono:h8
" set guifont=PragmataPro\ Mono:h8
" set guifont=PragmataPro:h8



set noundofile
set nobackup
set guioptions+=b                                                                " 添加水平滚动条
" 打开右侧滚动条
set guioptions+=r
" 隐藏左侧滚动条
set guioptions-=L

nnoremap <leader><leader>o o<Esc>| " 编辑: 下面插入一行保持普通模式(不能设置为oo,会导致严重延迟)
nnoremap <leader>O O<Esc>| " 编辑: 上面插入一行保持普通模式(不能设置为OO,会导致严重延迟)
" 由于环境变量的问题,下面这行暂时不使用
" command -nargs=1 Sch noautocmd vimgrep /<args>/gj `git ls-files` | cw            " 搜索git关注的文件 :Sch xx
nnoremap <silent> <leader>. :cd %:p:h<CR>:pwd<CR>| " 文件: 把目录切换到当前文件所在目录

set autoread                                                                     " 自动加载文件变化

" 折叠配置区域
" set foldenable                                                                   " 开始折叠
" 不要折叠代码
set nofen
set foldmethod=indent                                                            " 设置缩进折叠
setlocal foldlevel=3                                                             " 设置折叠层数为
set foldlevelstart=99                                                            " 打开文件是默认不折叠代码


set guioptions-=T                                                                " 禁用工具栏
set guioptions-=m                                                                " 禁用菜单栏

" 打开某个目录下面的文件执行vimgrep忽略设置,这样每个项目可以独立
autocmd BufNewFile,BufRead E:/code/P5-App-Asciio* set wildignore=t/**,xt/**,*.tmp,test.c

" 编辑vim配置文件
nnoremap <Leader>ver :e $MYVIMRC<CR>| " 辅助: 编辑当前的vim配置文件
nnoremap <Leader>veon :set ve=all<CR>| " 辅助: 打开虚拟文本编辑模式
nnoremap <Leader>veof :set ve=<CR>| " 辅助: 关闭虚拟文本编辑模式


nnoremap <Leader>vr :source $MYVIMRC<CR>| " 辅助: 重新加载vim配置文件

" 映射命令行历史操作,这个注释不能写到映射后面
cnoremap <c-j> <down>| " 命令: 命令行历史记录下翻页
cnoremap <c-k> <up>| " 命令: 命令行历史记录上翻页

nnoremap <leader>lv :lv /<c-r>=expand("<cword>")<cr>/%<cr>:lw<cr>| " 搜索: 在location window(本地列表)列出搜索结果

nnoremap <leader><leader><space> :%s/\s\+$//e<CR>| " 编辑: 移除文件中所有行尾的空白字符
iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>| " 编辑: 在插入模式下快速插入当前日期(需要按两个TAB键触发)

" nnoremap <silent> <leader>exp :silent !explorer %:p:h<CR><CR>| " 文件: 外部文件浏览器中打开当前文件所在目录
" 用下面的方式避免黑框弹出
nnoremap <silent> <leader>exp :silent !start explorer %:p:h<CR><CR>| " 文件: 外部文件浏览器中打开当前文件所在目录

" 某些插件可能需要手动指定python3库的地址,不过大多情况下这个值是默认的并不需要设置，只有出问题才需要设置
" set pythonthreedll = D:\python\python38.dll

" 设置grep默认显示行号
set grepprg=grep\ -n

" Quickfix窗口按键映射
nnoremap <leader>qo :copen<CR>| " quickfix: 打开快速修复窗口
nnoremap <leader>qc :cclose<CR>| " quickfix: 关闭快速修复窗口
nnoremap <leader>qn :cnext<CR>| " quickfix: 跳转到下一个快速修复项目
nnoremap <leader>qp :cprev<CR>| " quickfix: 跳转到上一个快速修复项目

" 本地列表映射
nnoremap <leader>lo :lopen<CR>| " locallist: 打开本地窗口
nnoremap <leader>lc :lclose<CR>| " locallist: 关闭本地窗口
nnoremap <leader>ln :lnext<CR>| " locallist: 跳转到本地窗口的下一个项目
nnoremap <leader>lp :lprev<CR>| " locallist: 跳转到本地窗口的上一个项目

" 窗口操作
" 之所以绑定两个字母为了快速响应
nnoremap <silent> <leader>cw :close<CR>| " 关闭当前窗口
nnoremap <silent> <leader>ss :split<CR>| " 纵向分屏
nnoremap <silent> <leader>vv :vsplit<CR>| " 横向分屏
nnoremap <silent> <leader>ow :only<CR>| " 只保留当前窗口

function! SetLineStr(line_list, line, jumpline, jumpcol)
    let line_str = join(a:line_list, '')
    call setline(a:line, line_str)
    " 这里设置的是直接列
    call cursor(a:jumpline, a:jumpcol)
endfunction


let g:draw_smartline_all_ascii_chars = {
    \ '-': 1, '|': 1, '+': 1, '.': 1, "'": 1, '^': 1, 'v': 1, '<': 1, '>': 1, ')': 1
    \ }

let g:draw_smartline_all_cross_chars = {
    \ '-': 1, '|': 1, '+': 1, '.': 1, "'": 1, '^': 1, 'v': 1, '<': 1, '>': 1,
    \ '─': 1, '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╮': 1, '╯': 1, '╰': 1,
    \ '━': 1, '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┓': 1, '┛': 1, '┗': 1,
    \ '═': 1, '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╗': 1, '╝': 1, '╚': 1,
    \ '╫': 1, '╪': 1, '╨': 1, '╧': 1, '╥': 1, '╤': 1, '╢': 1, '╡': 1, '╟': 1, '╞': 1, '╜': 1,
    \ '╛': 1, '╙': 1, '╘': 1, '╖': 1, '╕': 1, '╓': 1, '╒': 1,
    \ '┍': 1, '┎': 1, '┑': 1, '┒': 1, '┕': 1, '┖': 1, '┙': 1, '┚': 1,
    \ '┝': 1, '┞': 1, '┟': 1, '┠': 1, '┡': 1, '┢': 1,
    \ '┥': 1, '┦': 1, '┧': 1, '┨': 1, '┩': 1, '┪': 1,
    \ '┭': 1, '┮': 1, '┯': 1, '┰': 1, '┱': 1, '┲': 1,
    \ '┵': 1, '┶': 1, '┷': 1, '┸': 1, '┹': 1, '┺': 1,
    \ '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1,
    \ '╄': 1, '╅': 1, '╆': 1, '╇': 1, '╈': 1, '╉': 1, '╊': 1,
    \ '┌': 1, '┐': 1, '└': 1, '┘': 1, '┅': 1, '┄': 1, '┆': 1, '┇': 1, ')': 1, '❫': 1, '⟫': 1, '▲': 1, '▼': 1, '◀': 1, '▶': 1,
    \ '△': 1, '▽': 1, '◁': 1, '▷': 1
    \ }

let g:unicode_cross_chars = [
    \ {
    \ '─': 1, '┼': 1, '├': 1, '┬': 1, '┴': 1, '╭': 1, '╰': 1, '╫': 1, '╨': 1, '╥': 1, '╟': 1, '╙': 1, '╓': 1, '┎': 1, '┖': 1, '┞': 1, '┟': 1, '┠': 1, '┭': 1, '┰': 1, '┱': 1, '┵': 1, '┸': 1, '┹': 1, '┽': 1, '╀': 1, '╁': 1, '╂': 1, '╃': 1, '╅': 1, '╉': 1, '┌': 1, '└': 1, '┄': 1, '<': 1
    \ },
    \ {
    \ '═': 1, '╬': 1, '╠': 1, '╦': 1, '╩': 1, '╔': 1, '╚': 1, '╪': 1, '╧': 1, '╤': 1, '╞': 1, '╘': 1, '╒': 1, '◁': 1
    \ },
    \ {
    \ '━': 1, '╋': 1, '┣': 1, '┳': 1, '┻': 1, '┏': 1, '┗': 1, '┍': 1, '┕': 1, '┝': 1, '┡': 1, '┢': 1, '┮': 1, '┯': 1, '┲': 1, '┶': 1, '┷': 1, '┺': 1, '┾': 1, '┿': 1, '╄': 1, '╆': 1, '╇': 1, '╈': 1, '╊': 1, '┅': 1, '◀': 1
    \ },
    \ {
    \ '─': 1, '┼': 1, '┤': 1, '┬': 1, '┴': 1, '╮': 1, '╯': 1, '╫': 1, '╨': 1, '╥': 1, '╢': 1, '╜': 1, '╖': 1, '┒': 1, '┚': 1, '┦': 1, '┧': 1, '┨': 1, '┮': 1, '┰': 1, '┲': 1, '┶': 1, '┸': 1, '┺': 1, '┾': 1, '╀': 1, '╁': 1, '╂': 1, '╄': 1, '╆': 1, '╊': 1, '┐': 1, '┘': 1, '┄': 1, '>': 1
    \ },
    \ {
    \ '═': 1, '╬': 1, '╣': 1, '╦': 1, '╩': 1, '╗': 1, '╝': 1, '╪': 1, '╧': 1, '╤': 1, '╡': 1, '╛': 1, '╕': 1, '▷': 1 
    \ },
    \ {
    \ '━': 1, '╋': 1, '┫': 1, '┳': 1, '┻': 1, '┓': 1, '┛': 1, '┑': 1, '┙': 1, '┥': 1, '┩': 1, '┪': 1, '┭': 1, '┯': 1, '┱': 1, '┵': 1, '┷': 1, '┹': 1, '┽': 1, '┿': 1, '╃': 1, '╅': 1, '╇': 1, '╈': 1, '╉': 1, '┅': 1, '▶': 1
    \ },
    \ {
    \ '│': 1, '┼': 1, '┤': 1, '├': 1, '┬': 1, '╭': 1, '╮': 1, '╪': 1, '╤': 1, '╡': 1, '╞': 1, '╕': 1, '╒': 1, '┍': 1, '┑': 1, '┝': 1, '┞': 1, '┡': 1, '┥': 1, '┦': 1, '┩': 1, '┭': 1, '┮': 1, '┯': 1, '┽': 1, '┾': 1, '┿': 1, '╀': 1, '╃': 1, '╄': 1, '╇': 1, '┌': 1, '┐': 1, '┆': 1, ')': 1, '^': 1
    \ },
    \ {
    \ '║': 1, '╬': 1, '╣': 1, '╠': 1, '╦': 1, '╔': 1, '╗': 1, '╫': 1, '╥': 1, '╢': 1, '╟': 1, '╖': 1, '╓': 1, '⟫': 1, '△': 1
    \ },
    \ {
    \ '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┳': 1, '┏': 1, '┓': 1, '┎': 1, '┒': 1, '┟': 1, '┠': 1, '┢': 1, '┧': 1, '┨': 1, '┪': 1, '┰': 1, '┱': 1, '┲': 1, '╁': 1, '╂': 1, '╅': 1, '╆': 1, '╈': 1, '╉': 1, '╊': 1, '┇': 1, '❫': 1, '▲': 1
    \ },
    \ {
    \ '│': 1, '┼': 1, '┤': 1, '├': 1, '┴': 1, '╯': 1, '╰': 1, '╪': 1, '╧': 1, '╡': 1, '╞': 1, '╛': 1, '╘': 1, '┕': 1, '┙': 1, '┝': 1, '┟': 1, '┢': 1, '┥': 1, '┧': 1, '┪': 1, '┵': 1, '┶': 1, '┷': 1, '┽': 1, '┾': 1, '┿': 1, '╁': 1, '╅': 1, '╆': 1, '╈': 1, '└': 1, '┘': 1, '┆': 1, ')': 1, 'v': 1
    \ },
    \ {
    \ '║': 1, '╬': 1, '╣': 1, '╠': 1, '╩': 1, '╝': 1, '╚': 1, '╫': 1, '╨': 1, '╢': 1, '╟': 1, '╜': 1, '╙': 1, '⟫': 1, '▽': 1
    \ },
    \ {
    \ '┃': 1, '╋': 1, '┫': 1, '┣': 1, '┻': 1, '┛': 1, '┗': 1, '┖': 1, '┚': 1, '┞': 1, '┠': 1, '┡': 1, '┦': 1, '┨': 1, '┩': 1, '┸': 1, '┹': 1, '┺': 1, '╀': 1, '╂': 1, '╃': 1, '╄': 1, '╇': 1, '╉': 1, '╊': 1, '┇': 1, '❫': 1, '▼': 1
    \ }
    \ ]

let g:left_thin_index    = 0
let g:left_double_index  = 1
let g:left_bold_index    = 2
let g:right_thin_index   = 3
let g:right_double_index = 4
let g:right_bold_index   = 5
let g:up_thin_index      = 6
let g:up_double_index    = 7
let g:up_bold_index      = 8
let g:down_thin_index    = 9
let g:down_double_index  = 10
let g:down_bold_index    = 11

let g:left_index_map = {g:left_thin_index: 1, g:left_double_index: 1, g:left_bold_index: 1}
let g:right_index_map = {g:right_thin_index: 1, g:right_double_index: 1, g:right_bold_index: 1}
let g:up_index_map = {g:up_thin_index: 1, g:up_double_index: 1, g:up_bold_index: 1}
let g:down_index_map = {g:down_thin_index: 1, g:down_double_index: 1, g:down_bold_index: 1}

" Arranging them in order can reduce logical judgment. Because calculations are done sequentially
" 1. First are cross,
" 2. then are corner missing
" 3. and finally are two corners missing.
" Therefore, the order of functions in the array cannot be disrupted
let g:draw_smartline_normal_char_func = [
    \ ['+',  "SceneCross",     []                                  ],
    \ ['.',  "SceneDot",       []                                  ],
    \ ["'", "SceneApostrophe", []                                  ],
    \ ['┽' , "SceneUnicode" , [g:left_bold_index   , g:right_thin_index   , g:up_thin_index   , g:down_thin_index   ]],
    \ ['┾' , "SceneUnicode" , [g:left_thin_index   , g:right_bold_index   , g:up_thin_index   , g:down_thin_index   ]],
    \ ['┿' , "SceneUnicode" , [g:left_bold_index   , g:right_bold_index   , g:up_thin_index   , g:down_thin_index   ]],
    \ ['╀' , "SceneUnicode" , [g:left_thin_index   , g:right_thin_index   , g:up_bold_index   , g:down_thin_index   ]],
    \ ['╁' , "SceneUnicode" , [g:left_thin_index   , g:right_thin_index   , g:up_thin_index   , g:down_bold_index   ]],
    \ ['╂' , "SceneUnicode" , [g:left_thin_index   , g:right_thin_index   , g:up_bold_index   , g:down_bold_index   ]],
    \ ['╃' , "SceneUnicode" , [g:left_bold_index   , g:right_thin_index   , g:up_bold_index   , g:down_thin_index   ]],
    \ ['╄' , "SceneUnicode" , [g:left_thin_index   , g:right_bold_index   , g:up_bold_index   , g:down_thin_index   ]],
    \ ['╅' , "SceneUnicode" , [g:left_bold_index   , g:right_thin_index   , g:up_thin_index   , g:down_bold_index   ]],
    \ ['╆' , "SceneUnicode" , [g:left_thin_index   , g:right_bold_index   , g:up_thin_index   , g:down_bold_index   ]],
    \ ['╇' , "SceneUnicode" , [g:left_bold_index   , g:right_bold_index   , g:up_bold_index   , g:down_thin_index   ]],
    \ ['╈' , "SceneUnicode" , [g:left_bold_index   , g:right_bold_index   , g:up_thin_index   , g:down_bold_index   ]],
    \ ['╉' , "SceneUnicode" , [g:left_bold_index   , g:right_thin_index   , g:up_bold_index   , g:down_bold_index   ]],
    \ ['╊' , "SceneUnicode" , [g:left_thin_index   , g:right_bold_index   , g:up_bold_index   , g:down_bold_index   ]],
    \ ['╫' , "SceneUnicode" , [g:left_thin_index   , g:right_thin_index   , g:up_double_index , g:down_double_index ]],
    \ ['╪' , "SceneUnicode" , [g:left_double_index , g:right_double_index , g:up_thin_index   , g:down_thin_index   ]],
    \ ['┼' , "SceneUnicode" , [g:left_thin_index   , g:right_thin_index   , g:up_thin_index   , g:down_thin_index   ]],
    \ ['╋' , "SceneUnicode" , [g:left_bold_index   , g:right_bold_index   , g:up_bold_index   , g:down_bold_index   ]],
    \ ['╬' , "SceneUnicode" , [g:left_double_index , g:right_double_index , g:up_double_index , g:down_double_index ]],
    \ ['┵' , "SceneUnicode" , [g:left_bold_index    , g:right_thin_index   , g:up_thin_index     ]],
    \ ['┶' , "SceneUnicode" , [g:left_thin_index    , g:right_bold_index   , g:up_thin_index     ]],
    \ ['┷' , "SceneUnicode" , [g:left_bold_index    , g:right_bold_index   , g:up_thin_index     ]],
    \ ['┸' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:up_bold_index     ]],
    \ ['┹' , "SceneUnicode" , [g:left_bold_index    , g:right_thin_index   , g:up_bold_index     ]],
    \ ['┺' , "SceneUnicode" , [g:left_thin_index    , g:right_bold_index   , g:up_bold_index     ]],
    \ ['┭' , "SceneUnicode" , [g:left_bold_index    , g:right_thin_index   , g:down_thin_index   ]],
    \ ['┮' , "SceneUnicode" , [g:left_thin_index    , g:right_bold_index   , g:down_thin_index   ]],
    \ ['┯' , "SceneUnicode" , [g:left_bold_index    , g:right_bold_index   , g:down_thin_index   ]],
    \ ['┰' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:down_bold_index   ]],
    \ ['┱' , "SceneUnicode" , [g:left_bold_index    , g:right_thin_index   , g:down_bold_index   ]],
    \ ['┲' , "SceneUnicode" , [g:left_thin_index    , g:right_bold_index   , g:down_bold_index   ]],
    \ ['┥' , "SceneUnicode" , [g:left_bold_index    , g:up_thin_index      , g:down_thin_index   ]],
    \ ['┦' , "SceneUnicode" , [g:left_thin_index    , g:up_bold_index      , g:down_thin_index   ]],
    \ ['┧' , "SceneUnicode" , [g:left_thin_index    , g:up_thin_index      , g:down_bold_index   ]],
    \ ['┨' , "SceneUnicode" , [g:left_thin_index    , g:up_bold_index      , g:down_bold_index   ]],
    \ ['┩' , "SceneUnicode" , [g:left_bold_index    , g:up_bold_index      , g:down_thin_index   ]],
    \ ['┪' , "SceneUnicode" , [g:left_bold_index    , g:up_thin_index      , g:down_bold_index   ]],
    \ ['┝' , "SceneUnicode" , [g:right_bold_index   , g:up_thin_index      , g:down_thin_index   ]],
    \ ['┞' , "SceneUnicode" , [g:right_thin_index   , g:up_bold_index      , g:down_thin_index   ]],
    \ ['┟' , "SceneUnicode" , [g:right_thin_index   , g:up_thin_index      , g:down_bold_index   ]],
    \ ['┠' , "SceneUnicode" , [g:right_thin_index   , g:up_bold_index      , g:down_bold_index   ]],
    \ ['┡' , "SceneUnicode" , [g:right_bold_index   , g:up_bold_index      , g:down_thin_index   ]],
    \ ['┢' , "SceneUnicode" , [g:right_bold_index   , g:up_thin_index      , g:down_bold_index   ]],
    \ ['╨' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:up_double_index   ]],
    \ ['╧' , "SceneUnicode" , [g:left_double_index  , g:right_double_index , g:up_thin_index     ]],
    \ ['╥' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:down_double_index ]],
    \ ['╤' , "SceneUnicode" , [g:left_double_index  , g:right_double_index , g:down_thin_index   ]],
    \ ['╢' , "SceneUnicode" , [g:left_thin_index    , g:up_double_index    , g:down_double_index ]],
    \ ['╡' , "SceneUnicode" , [g:left_double_index  , g:up_thin_index      , g:down_thin_index   ]],
    \ ['╟' , "SceneUnicode" , [g:right_thin_index   , g:up_double_index    , g:down_double_index ]],
    \ ['╞' , "SceneUnicode" , [g:right_double_index , g:up_thin_index      , g:down_thin_index   ]],
    \ ['┤' , "SceneUnicode" , [g:left_thin_index    , g:up_thin_index      , g:down_thin_index   ]],
    \ ['├' , "SceneUnicode" , [g:right_thin_index   , g:up_thin_index      , g:down_thin_index   ]],
    \ ['┬' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:down_thin_index   ]],
    \ ['┴' , "SceneUnicode" , [g:left_thin_index    , g:right_thin_index   , g:up_thin_index     ]],
    \ ['┫' , "SceneUnicode" , [g:left_bold_index    , g:up_bold_index      , g:down_bold_index   ]],
    \ ['┣' , "SceneUnicode" , [g:right_bold_index   , g:up_bold_index      , g:down_bold_index   ]],
    \ ['┳' , "SceneUnicode" , [g:left_bold_index    , g:right_bold_index   , g:down_bold_index   ]],
    \ ['┻' , "SceneUnicode" , [g:left_bold_index    , g:right_bold_index   , g:up_bold_index     ]],
    \ ['╣' , "SceneUnicode" , [g:left_double_index  , g:up_double_index    , g:down_double_index ]],
    \ ['╠' , "SceneUnicode" , [g:right_double_index , g:up_double_index    , g:down_double_index ]],
    \ ['╦' , "SceneUnicode" , [g:left_double_index  , g:right_double_index , g:down_double_index ]],
    \ ['╩' , "SceneUnicode" , [g:left_double_index  , g:right_double_index , g:up_double_index   ]],
    \ ['╜' , "SceneUnicode" , [g:left_thin_index    , g:up_double_index   ]],
    \ ['╛' , "SceneUnicode" , [g:left_double_index  , g:up_thin_index     ]],
    \ ['╙' , "SceneUnicode" , [g:right_thin_index   , g:up_double_index   ]],
    \ ['╘' , "SceneUnicode" , [g:right_double_index , g:up_thin_index     ]],
    \ ['╖' , "SceneUnicode" , [g:left_thin_index    , g:down_double_index ]],
    \ ['╕' , "SceneUnicode" , [g:left_double_index  , g:down_thin_index   ]],
    \ ['╓' , "SceneUnicode" , [g:right_thin_index   , g:down_double_index ]],
    \ ['╒' , "SceneUnicode" , [g:right_double_index , g:down_thin_index   ]],
    \ ['┍' , "SceneUnicode" , [g:right_bold_index   , g:down_thin_index   ]],
    \ ['┎' , "SceneUnicode" , [g:right_thin_index   , g:down_bold_index   ]],
    \ ['┑' , "SceneUnicode" , [g:left_bold_index    , g:down_thin_index   ]],
    \ ['┒' , "SceneUnicode" , [g:left_thin_index    , g:down_bold_index   ]],
    \ ['┕' , "SceneUnicode" , [g:right_bold_index   , g:up_thin_index     ]],
    \ ['┖' , "SceneUnicode" , [g:right_thin_index   , g:up_bold_index     ]],
    \ ['┙' , "SceneUnicode" , [g:left_bold_index    , g:up_thin_index     ]],
    \ ['┚' , "SceneUnicode" , [g:left_thin_index    , g:up_bold_index     ]],
    \ ['╭' , "SceneUnicode" , [g:right_thin_index   , g:down_thin_index   ]],
    \ ['╮' , "SceneUnicode" , [g:left_thin_index    , g:down_thin_index   ]],
    \ ['╯' , "SceneUnicode" , [g:left_thin_index    , g:up_thin_index     ]],
    \ ['╰' , "SceneUnicode" , [g:right_thin_index   , g:up_thin_index     ]],
    \ ['┏' , "SceneUnicode" , [g:right_bold_index   , g:down_bold_index   ]],
    \ ['┓' , "SceneUnicode" , [g:left_bold_index    , g:down_bold_index   ]],
    \ ['┛' , "SceneUnicode" , [g:left_bold_index    , g:up_bold_index     ]],
    \ ['┗' , "SceneUnicode" , [g:right_bold_index   , g:up_bold_index     ]],
    \ ['╔' , "SceneUnicode" , [g:right_double_index , g:down_double_index ]],
    \ ['╗' , "SceneUnicode" , [g:left_double_index  , g:down_double_index ]],
    \ ['╝' , "SceneUnicode" , [g:left_double_index  , g:up_double_index   ]],
    \ ['╚' , "SceneUnicode" , [g:right_double_index , g:up_double_index   ]]
    \ ]

let g:SmartDrawLines = [['-', '|'], ['─', '│'], ['━', '┃'], ['═', '║'], ['┅', '┇'], ['┄', '┆']]
let g:SmartDrawLineIndex = 0

" 交叉策略字典(比如+将会显示成)左小括号)
let g:use_cross_mode_rules = [
    \ {
    \ },
    \ {
    \ '+' : ')',
    \ '┼' : ')',
    \ '╋' : '❫',
    \ '╬' : '⟫',
    \ '╫' : '⟫',
    \ '╪' : ')',
    \ '┽' : ')',
    \ '┾' : ')',
    \ '┿' : ')',
    \ '╀' : ')',
    \ '╁' : ')',
    \ '╂' : '❫',
    \ '╃' : ')',
    \ '╄' : ')',
    \ '╅' : ')',
    \ '╆' : ')',
    \ '╇' : ')',
    \ '╈' : ')',
    \ '╉' : '❫',
    \ '╊' : '❫'
    \ },
    \ {
    \ '╭' : '┌',
    \ '╰' : '└',
    \ '╯' : '┘',
    \ '╮' : '┐'
    \ }
    \ ]
let g:use_cross_mode_index = 0

function! SwitchSmartLineCrossType()
    let g:use_cross_mode_index = (g:use_cross_mode_index + 1) % len(g:use_cross_mode_rules)
    echo "now index: " . g:use_cross_mode_index
endfunction


function! SwitchSmartDrawLine(is_just_show)
    if !a:is_just_show
        let g:SmartDrawLineIndex = (g:SmartDrawLineIndex + 1) % len(g:SmartDrawLines)
    endif
    echo "now line type:" . string(g:SmartDrawLines[g:SmartDrawLineIndex])
endfunction

" 获取当前光标下的线形并且切换到它
function! SwitchSmartDrawLineFromCharUnderCursor()
    let smart_char_to_index = {'-': 0, '|': 0, '─': 1, '│': 1, '━': 2, '┃': 2, '═': 3, '║': 3, '┅': 4, '┇': 4, '┄': 5, '┆': 5}
    let current_char = matchstr(getline('.'), '\%' . col('.') . 'c.')

    if has_key(smart_char_to_index, current_char)
        let g:SmartDrawLineIndex = smart_char_to_index[current_char]
    endif
    echo "now line type:" . string(g:SmartDrawLines[g:SmartDrawLineIndex])
endfunction

function! CopyCharUnderCursor()
    " 复制当前光标下的字符
    let current_char = matchstr(getline('.'), '\%' . col('.') . 'c.')
    let @+ = current_char
endfunction

function! ReplaceCharUnderCursor(direction)
    " 获取当前行的内容
    let l:line = getline('.')
    let cursor_char = matchstr(l:line, '\%' . col('.') . 'c.')

    let reg_content = getreg('+')
    let cleaned_reg_content = substitute(reg_content, '\s\+', '', 'g')

    if exists("g:replace_char_under_cursor_chars")
        " 检查寄存器的内容是否有变更
        let prev_content = join(g:replace_char_under_cursor_chars['value'], '')

        if cleaned_reg_content != prev_content
            " 更新保存的内容
            let g:replace_char_under_cursor_chars['value'] = split(cleaned_reg_content, '\zs')
            let g:replace_char_under_cursor_chars['index'] = 0
        else
            " 更新index
            let g:replace_char_under_cursor_chars['index'] = (g:replace_char_under_cursor_chars['index']+1) % len(g:replace_char_under_cursor_chars['value'])
        endif
    else
        let g:replace_char_under_cursor_chars = {'index': 0, 'value': []}
        let g:replace_char_under_cursor_chars['value'] = split(cleaned_reg_content, '\zs')
    endif

    let now_char_index = g:replace_char_under_cursor_chars['index']
    let now_char = g:replace_char_under_cursor_chars['value'][now_char_index]

    " 替换目标位置的字符
    execute "normal! r" . now_char

    " 获取替换后字符的宽度
    let new_char_width = strdisplaywidth(now_char)
    let cursor_char_width = strdisplaywidth(cursor_char)
    if cursor_char_width == 0
        let cursor_char_width = 1
    endif

    " 如果替换的是宽字符，删除多余的空格
    if cursor_char_width != new_char_width
        if new_char_width > 1
            " 尝试向右移动光标
            " 向右移动光标并删除字符
            execute "normal! l"
            execute "normal! x"
            " " 向左移动光标还原位置
            execute "normal! h"

            if a:direction == 'l'
                execute "normal! l"
            elseif a:direction == 'h'
                execute "normal! hh"
            elseif a:direction == 'j'
                execute "normal! j"
            elseif a:direction == 'k'
                execute "normal! k"
            endif
        else
            " 替换后还要增加一个空格
             call feedkeys("a \<Esc>h", 'n')
        endif
    else
        if a:direction == 'l'
            execute "normal! l"
        elseif a:direction == 'h'
            execute "normal! h"
        elseif a:direction == 'j'
            execute "normal! j"
        elseif a:direction == 'k'
            execute "normal! k"
        endif

    endif
endfunction


function! SceneUnicode(up, down, left, right, char_category_indexs)
    for char_index in a:char_category_indexs
        if has_key(g:left_index_map, char_index)
            if ! has_key(g:draw_smartline_all_cross_chars, a:left)
                return 0
            endif
            if ! has_key(g:unicode_cross_chars[char_index], a:left)
                return 0
            endif
        elseif has_key(g:right_index_map, char_index)
            if ! has_key(g:draw_smartline_all_cross_chars, a:right)
                return 0
            endif
            if ! has_key(g:unicode_cross_chars[char_index], a:right)
                return 0
            endif
        elseif has_key(g:up_index_map, char_index)
            if ! has_key(g:draw_smartline_all_cross_chars, a:up)
                return 0
            endif
            if ! has_key(g:unicode_cross_chars[char_index], a:up)
                return 0
            endif
        else
            if ! has_key(g:draw_smartline_all_cross_chars, a:down)
                return 0
            endif
            if ! has_key(g:unicode_cross_chars[char_index], a:down)
                return 0
            endif
        endif
    endfor

    return 1
endfunction

" 绘制加号的场景
function! SceneCross(up, down, left, right, char_category_indexs)
    " 检查参数是否定义
    if a:up == '' || a:down == '' || a:left == '' || a:right == ''
        return 0
    endif

    " 定义有效字符的字典
    let valid_chars = {
    \ 'up': {'|': 1, '.': 1, "'": 1, '+': 1, '^': 1, ')': 1},
    \ 'down': {'|': 1, '.': 1, "'": 1, '+': 1, 'v': 1, ')': 1},
    \ 'left': {'-': 1, '.': 1, "'": 1, '+': 1, '<': 1},
    \ 'right': {'-': 1, '.': 1, "'": 1, '+': 1, '>': 1}
    \ }

    " 返回结果
    return has_key(valid_chars['up'], a:up) && has_key(valid_chars['down'], a:down) && has_key(valid_chars['left'], a:left) && has_key(valid_chars['right'], a:right)
endfunction

" 绘制点号的场景
function! SceneDot(up, down, left, right, char_category_indexs)
    " 检查参数是否定义并满足条件
    if ( a:up == '|' || a:up == ')' ) && ( a:down == '|' || a:down == ')' ) && a:left == '-' && a:right == '-'
        return 0
    endif

    " 检查左下或右下是否满足条件
    return ((a:left == '-' && ( a:down == '|' || a:down == ')' )) || (a:right == '-' && ( a:down == '|' || a:down == ')' )))
endfunction

" 绘制单引号的场景
function! SceneApostrophe(up, down, left, right, char_category_indexs)
    if ((( a:up == '|' || a:up == ')' ) && a:right == '-') && ( a:down != '|' && a:down != ')' ))
        return 1
    endif

    return (( a:up == '|' || a:up == ')' ) && a:left == '-' && !(( a:down == '|' || a:down == ')' ) || ( a:right == '|' || a:right == ')' )))
endfunction

function! GetDoubleWidthCharCols(row, ...)
    let l:cols = []
    let l:col = 1
    let l:line = get(a:, 1, getline(a:row))
    let l:len = len(l:line)

    " 使用正则表达式匹配宽度为 2 的字符
    let l:pattern = '[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE30-\uFE4F\uFF00-\uFF60\uFFE0-\uFFE6]'

    while l:col <= l:len
        " 查找下一个匹配的字符位置
        let l:pos = matchstrpos(l:line, l:pattern, l:col - 1)
        if empty(l:pos) || l:pos[1] == -1
            break
        endif

        " 这里必须加1才是正式的字节列
        call add(l:cols, virtcol([a:row, l:pos[1]+1]))

        " :TODO: 这里的3写死了,后面可以改成len(pos[0])
        " 更新当前列位置，跳过匹配的字符
        let l:col = l:pos[1] + 3
    endwhile
    
    return l:cols
endfunction



" 这个是ProcessLine的低效率版本
" function! ProcessLine(row, ...)
"     " vim中virtcol返回的是显示列,考虑制表符和多字节字符的实际显示宽度
"     " col返回的是基于字节的列
"     " virtcol2col 虚拟列转换成字节列
"     if a:row < 0
"         return [[], 0]
"     endif

"     let line_str = getline(a:row)
"     " 获取传入的phy_col参数，如果未传入则使用virtcol('.')
"     let phy_col = get(a:, 1, virtcol('.'))

"     let line_chars_array = []
"     let real_phy_width = virtcol([a:row, '$'])-1
"     " virtcol([a:row, '$']) - 1 和 strdisplaywidth(line_str) 的执行效率谁更高并不一定
"     " 目前并没有测试
"     let max_width = max([phy_col, real_phy_width])
"     call extend(line_chars_array, repeat([' '], max_width))
"     let char_list = split(line_str, '\zs')
"     let total_phy_len = 0

"     for char in char_list
"         " 大部分的字符都是空格,所以空格特殊处理提速
"         if char == ' '
"             let total_phy_len += 1
"         else
"             " 放到两个长度数组中
"             let line_chars_array[total_phy_len] = char
"             let total_phy_len += 1

"             if strdisplaywidth(char) == 2
"                 let line_chars_array[total_phy_len] = ''
"                 let total_phy_len += 1
"             endif
"         endif
"     endfor

"     " phy_col 从 1开始 而数组索引从0开始
"     return [line_chars_array, phy_col - 1]
" endfunction



function! ProcessLine(row, ...)
    " vim中virtcol返回的是显示列,考虑制表符和多字节字符的实际显示宽度
    " col返回的是基于字节的列
    " virtcol2col 虚拟列转换成字节列
    if a:row < 0
        return [[], 0]
    endif

    let line_str = getline(a:row)
    " 获取传入的phy_col参数，如果未传入则使用virtcol('.')
    let phy_col = get(a:, 1, virtcol('.'))

    " virtcol([a:row, '$']) - 1 和 strdisplaywidth(line_str) 的执行效率谁更高并不一定
    " 目前并没有测试
    let real_phy_width = virtcol([a:row, '$'])-1
    let max_width = max([phy_col, real_phy_width])

    let line_chars_array = split(line_str, '\zs')

    for insert_index in GetDoubleWidthCharCols(a:row, line_str)
        " 这里必须减1才是真实的数组索引
        call insert(line_chars_array, '', insert_index-1)
    endfor

    call extend(line_chars_array, repeat([' '], max_width-real_phy_width))
    return [line_chars_array, phy_col - 1]
endfunction

" :TODO: 如果以后发现除 . '  以外的比较适合的连接字符，可以根据最近的三个坐标的
" 方位来确定斜线和直线或者斜线和斜线的交叉字符，就像自动箭头的实现原理一样
" 不过可能过于复杂，当时不以实现
" 绘制斜线(直接简单的实现)
function! DrawSmartLineSlash(direction)
    if a:direction == 'u'
        normal! h
        normal! k
        normal! r\
    elseif a:direction == 'n'
        normal! h
        normal! j
        normal! r/
    elseif a:direction == 'i'
        normal! l
        normal! k
        normal! r/
    elseif a:direction == 'm'
        normal! l
        normal! j
        normal! r\
    endif
endfunction

function! SmartDrawLinesRecordPrePosition()
    if exists("g:current_cursor_pos")
        let g:prev_cursor_pos = copy(g:current_cursor_pos)
    endif
    let g:current_cursor_pos = [line('.'), virtcol('.')]
endfunction


" 记录上一个移动的位置用于判断箭头的方向和类型
function! DrawSmartLineAutoGroupSet()
    augroup DrawSmartLineAutoGroup
        autocmd!
        autocmd CursorMoved * call SmartDrawLinesRecordPrePosition()
    augroup END
endfunction

function! DrawSmartLineAutoGroupClear()
    augroup DrawSmartLineAutoGroup
        autocmd!
    augroup END
endfunction



" 绘制线并且决定边界字符
" :TODO: 绘画模式无法处理有制表符的情况,如果文本中有需要先删除
function! DrawSmartLineLeftRight(direction)
    " let start_time = reltime()
    call DrawSmartLineAutoGroupSet()
    let row = line('.')
    " :TODO: 不支持阿拉伯语言或者其它语言中的0宽度字符

    let [line_chars_array, index] = ProcessLine(row)

    if strdisplaywidth(line_chars_array[index]) == 0
        " 中文先替换成两个空格
        let line_chars_array[index-1] = ' '
        let line_chars_array[index] = ' '
        if a:direction == 'l'
            let index -= 1
        endif
    endif

    let [up_line_chars_array, up_index] = ProcessLine(row-1)
    let [down_line_chars_array, down_index] = ProcessLine(row+1)

    let col = len(join(line_chars_array[0:index], ''))

    " 获取前一个字符的上下左右
    if a:direction == 'l'
        let pre_right = g:SmartDrawLines[g:SmartDrawLineIndex][0]
        let pre_left = (index>1)?get(line_chars_array, index-2, ''):''
        let pre_up = (up_index>0)?get(up_line_chars_array, up_index-1, ''):''
        let pre_down = (down_index>0)?get(down_line_chars_array, down_index-1, ''):''
    elseif a:direction == 'h'
        let pre_left = g:SmartDrawLines[g:SmartDrawLineIndex][0]
        let pre_right = get(line_chars_array, index+2, '')
        let pre_up = get(up_line_chars_array, up_index+1, '')
        let pre_down = get(down_line_chars_array, down_index+1, '')
    endif

    let pre_index = index + (a:direction == 'l' ? -1 : 1)
    if pre_index >= 0 && pre_index < len(line_chars_array)
        let pre_char = line_chars_array[index+(a:direction=='l'?-1:1)]
        if has_key(g:draw_smartline_all_cross_chars, pre_char)
            for table_param in g:draw_smartline_normal_char_func
                if call(table_param[1], [pre_up, pre_down, pre_left, pre_right, table_param[2]])
                    if has_key(g:use_cross_mode_rules[g:use_cross_mode_index], table_param[0])
                        let line_chars_array[pre_index] = g:use_cross_mode_rules[g:use_cross_mode_index][table_param[0]]
                    else
                        let line_chars_array[pre_index] = table_param[0]
                    endif
                    call SetLineStr(line_chars_array, row, row, col)
                    break
                endif
            endfor
        endif
    endif

    " 获取当前字符的上下左右
    let left = (index>0)?get(line_chars_array, index-1, ''):''
    let right = get(line_chars_array, index+1, '')
    let up = get(up_line_chars_array, up_index, '')
    let down = get(down_line_chars_array, down_index, '')

    let entered_if = 0
    for table_param in g:draw_smartline_normal_char_func
        if call(table_param[1], [up, down, left, right, table_param[2]])
            if has_key(g:use_cross_mode_rules[g:use_cross_mode_index], table_param[0])
                let line_chars_array[index] = g:use_cross_mode_rules[g:use_cross_mode_index][table_param[0]]
            else
                let line_chars_array[index] = table_param[0]
            endif
            let entered_if = 1
            break
        endif
    endfor

    if entered_if == 0
        let line_chars_array[index] = g:SmartDrawLines[g:SmartDrawLineIndex][0]
    endif

    let col = len(join(line_chars_array[0:index], ''))

    call SetLineStr(line_chars_array, row, row, (a:direction=='l')?col+1:col-len(line_chars_array[index]))
    " let elapsed_time = reltimefloat(reltime(start_time)) * 1000
    " echo "left right执行时间: " . elapsed_time . " ms"
endfunction

function! DrawSmartLineEraser(direction, ...)

    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    " 默认情况下橡皮擦替换成空格,如果传入一个字符,那么使用传入的字符
    let replace_char = get(a:, 3, ' ')

    let [line_chars_arr, index] = ProcessLine(row, virtcol)
    let [up_line_chars_arr, up_index] = ProcessLine(row-1, virtcol)
    let [down_line_chars_arr, down_index] = ProcessLine(row+1, virtcol)

    let index_char_phylen = strdisplaywidth(line_chars_arr[index])
    if index_char_phylen == 2
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index] = replace_char
        else
            let line_chars_arr[index] = repeat(replace_char, 2)
        endif
    elseif index_char_phylen == 1
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index] = replace_char
            let line_chars_arr[index+1] = ''
        else
            let line_chars_arr[index] = replace_char
        endif
    elseif index_char_phylen == 0
        if strdisplaywidth(replace_char) == 2
            let line_chars_arr[index-1] = replace_char
        else
            let line_chars_arr[index-1] = repeat(replace_char, 2)
        endif
    endif

    call setline(row, join(line_chars_arr, ''))

    if a:direction != 'null'
        let [line_chars_arr, index] = ProcessLine(row, virtcol)
        let [up_line_chars_arr, up_index] = ProcessLine(row-1, virtcol)
        let [down_line_chars_arr, down_index] = ProcessLine(row+1, virtcol)
        let col = len(join(line_chars_arr[0:index], ''))

        if a:direction == 'l'
            call cursor(row, col+1)
        elseif a:direction == 'h'
            call cursor(row, col-1)
        elseif a:direction == 'j'
            let next_col = len(join(down_line_chars_arr[0:down_index], ''))
            call cursor(row+1, next_col)
        elseif a:direction == 'k'
            let next_col = len(join(up_line_chars_arr[0:up_index], ''))
            call cursor(row-1, next_col)
        endif
    endif
endfunction

function! DrawSmartLineUpDown(direction)
    " let start_time = reltime()
    call DrawSmartLineAutoGroupSet()
    let row = line('.')

    let [line_chars_array, index] = ProcessLine(row)

    if strdisplaywidth(line_chars_array[index]) == 0
        let line_chars_array[index-1] = ' '
        let line_chars_array[index] = ' '

        if exists("g:prev_cursor_pos")
            let cur_col = virtcol('.')
            let [prev_row, prev_col] = g:prev_cursor_pos
            if prev_col != cur_col
                let index -= 1
                " 并且修复当前列(这个实现非常的奇怪,所以最好还是手动先删除中文字符)
                " 这就是为了阻止SmartDrawLinesRecordPrePosition获取current_cursor_pos
                let g:current_cursor_pos = copy(g:prev_cursor_pos)
            endif
        endif
    endif


    let [up1_line_chars_array, up1_index] = ProcessLine(row-1)
    let [up2_line_chars_array, up2_index] = ProcessLine(row-2)
    let [down1_line_chars_array, down1_index] = ProcessLine(row+1)
    let [down2_line_chars_array, down2_index] = ProcessLine(row+2)

    " 获取前一个字符的上下左右
    if a:direction == 'j'
        let pre_down = g:SmartDrawLines[g:SmartDrawLineIndex][1]
        let pre_up = get(up2_line_chars_array, up2_index, '')
        let pre_left = (up1_index>0)?get(up1_line_chars_array, up1_index-1, ''):''
        let pre_right = get(up1_line_chars_array, up1_index+1, '')
    elseif a:direction == 'k'
        let pre_down = get(down2_line_chars_array, down2_index, '')
        let pre_up = g:SmartDrawLines[g:SmartDrawLineIndex][1]
        let pre_left = (index>0)?get(down1_line_chars_array, down1_index-1, ''):''
        let pre_right = get(down1_line_chars_array, down1_index+1, '')
    endif

    if a:direction == 'j'
        let pre_char = get(up1_line_chars_array, up1_index, '')
    else
        let pre_char = get(down1_line_chars_array, down1_index, '')
    endif

    if has_key(g:draw_smartline_all_cross_chars, pre_char)

        let entered_if = 0
        for table_param in g:draw_smartline_normal_char_func
            if call(table_param[1], [pre_up, pre_down, pre_left, pre_right, table_param[2]])
                if has_key(g:use_cross_mode_rules[g:use_cross_mode_index], table_param[0])
                    let result_char = g:use_cross_mode_rules[g:use_cross_mode_index][table_param[0]]
                else
                    let result_char = table_param[0]
                endif
                let entered_if = 1
                break
            endif
        endfor

        if entered_if == 1
            if a:direction == 'j'
                if row > 0
                    let up1_line_chars_array[up1_index] = result_char
                    call SetLineStr(up1_line_chars_array, row-1, row, len(join(up1_line_chars_array[0:up1_index], '')))
                endif
            else
                let down1_line_chars_array[down1_index] = result_char
                call SetLineStr(down1_line_chars_array, row+1, row, len(join(down1_line_chars_array[0:down1_index], '')))
            endif
        endif
    endif

    " 取当前字符的上下左右
    let down = get(down1_line_chars_array, down1_index, '')
    let up = get(up1_line_chars_array, up1_index, '')
    let left = (index>0)?get(line_chars_array, index-1, ''):''
    let right = get(line_chars_array, index+1, '')

    let entered_if = 0
    for table_param in g:draw_smartline_normal_char_func
        if call(table_param[1], [up, down, left, right, table_param[2]])
            if has_key(g:use_cross_mode_rules[g:use_cross_mode_index], table_param[0])
                let line_chars_array[index] = g:use_cross_mode_rules[g:use_cross_mode_index][table_param[0]]
            else
                let line_chars_array[index] = table_param[0]
            endif
            let entered_if = 1
            break
        endif
    endfor

    if entered_if == 0
        let line_chars_array[index] = g:SmartDrawLines[g:SmartDrawLineIndex][1]
    endif

    if a:direction == 'j'
        let next_col = len(join(down1_line_chars_array[0:down1_index], ''))
        let set_row = row+1
    else
        let next_col = len(join(up1_line_chars_array[0:up1_index], ''))
        let set_row = row-1
    endif

    call SetLineStr(line_chars_array, row, set_row, next_col)
    " let elapsed_time = reltimefloat(reltime(start_time)) * 1000
    " echo "up down执行时间: " . elapsed_time . " ms"
endfunction
" 进入可视模式前记录光标位置
augroup VisualModeMappings
    autocmd!
    autocmd ModeChanged *:[vV\x16]* let g:initial_pos_before_enter_visual = [line('.'), virtcol('.')]
augroup END

function! VisualReplaceToSpace()
    " 重新选择可视选框
    execute "normal! gv"
    " call feedkeys("r ")
    " 先替换所有的字符为空格(feedkeys不会立即生效,normal!才会立即生效)
    execute "normal! r "
endfunction

function! VisualReplaceChar() range
    let [line_start, col_start] = [g:initial_pos_before_enter_visual[0], g:initial_pos_before_enter_visual[1]]
    let [start_chars_arr, start_index] = ProcessLine(line_start, col_start)

    let char = getreg('+')
    let char = empty(char) ? ' ' : strcharpart(char, 0, 1)

    " 获取当前选中的文本范围
    execute "normal! gv"
    " 进入命令模式并执行替换操作
    if strdisplaywidth(char) == 2
        execute "normal! :s/\\%V  /" . char . "/g\<CR>"
    elseif strdisplaywidth(char) == 1 && len(char) != 1
        execute "normal! :s/\\%V /" . char . "/g\<CR>"
    else
        execute "normal! :s/\\%V /" . '\' . char . "/g\<CR>"
    endif
    
    let [start_chars_arr, start_index] = ProcessLine(line_start, col_start)
    let col_byte_start = len(join(start_chars_arr[0:start_index], ''))
    call cursor(line_start, col_byte_start)
endfunction


function! TraverseRectangle()
    " 获取可视块选择的起始和结束位置
    let [line_start, col_start] = [g:initial_pos_before_enter_visual[0], g:initial_pos_before_enter_visual[1]]
    
    let line_left = line("'<")
    let line_right = line("'>")
    let line_end = (line_left==line_start)?line_right:line_left

    let col_left= virtcol("'<")
    let col_right = virtcol("'>")
    let col_end = (col_left==col_start)?col_right:col_left

    let [start_chars_arr, start_index] = ProcessLine(line_start, col_start)
    let col_byte_start = len(join(start_chars_arr[0:start_index], ''))
    call cursor(line_start, col_byte_start)

    " 向下
    if col_start == col_end && line_start < line_end
        for col in range(line_start, line_end - 1)
            call DrawSmartLineUpDown('j')
        endfor
        call DrawSmartLineUpDown('k')
        call DrawSmartLineUpDown('j')
    " 向上
    elseif col_start == col_end && line_start > line_end
        for col in range(line_end, line_start - 1)
            call DrawSmartLineUpDown('k')
        endfor
        call DrawSmartLineUpDown('j')
        call DrawSmartLineUpDown('k')
    " 向右
    elseif line_start == line_end && col_start < col_end
        for col in range(col_start, col_end - 2)
            call DrawSmartLineLeftRight('l')
        endfor
        call DrawSmartLineLeftRight('h')
        call DrawSmartLineLeftRight('l')
    " 向左
    elseif line_start == line_end && col_start > col_end
        for col in range(col_end, col_start - 2)
            call DrawSmartLineLeftRight('h')
        endfor
        call DrawSmartLineLeftRight('l')
        call DrawSmartLineLeftRight('h')
    " 矩形向右
    elseif line_start < line_end && col_start < col_end
        " 右下左上
        for col in range(col_start, col_end - 2)
            call DrawSmartLineLeftRight('l')
        endfor
        for col in range(line_start, line_end - 1)
            call DrawSmartLineUpDown('j')
        endfor
        for col in range(col_start, col_end - 2)
            call DrawSmartLineLeftRight('h')
        endfor
        for col in range(line_start, line_end - 1)
            call DrawSmartLineUpDown('k')
        endfor
        call DrawSmartLineLeftRight('l')
        call DrawSmartLineLeftRight('h')
    else
        " 左上右下
        for col in range(col_end, col_start - 2)
            call DrawSmartLineLeftRight('h')
        endfor
        for col in range(line_end, line_start - 1)
            call DrawSmartLineUpDown('k')
        endfor
        for col in range(col_end, col_start - 2)
            call DrawSmartLineLeftRight('l')
        endfor
        for col in range(line_end, line_start - 1)
            call DrawSmartLineUpDown('j')
        endfor
        call DrawSmartLineLeftRight('h')
        call DrawSmartLineLeftRight('l')
    endif
endfunction
                                        
                                        
function! SmartDrawLinesGetArrowChar(pre_char, direction)
    let arrow_char_map = {
                \ 'up': {
                \ '-': ''  , '|': '^' , '+': '^' , '.': ''  , "'": ''  , '^': '^' , 'v': ''  , '<': ''  , '>': ''  ,
                \ '─': ''  , '│': '^'  , '┼': '^' , '┤': '^' , '├': '^' , '┬': ''  , '┴': '^' , '╭': ''  , '╮': ''  , '╯': '^' , '╰': '^' ,
                \ '━': ''  , '┃': '▲' , '╋': '▲' , '┫': '▲' , '┣': '▲' , '┳': ''  , '┻': '▲' , '┏': ''  , '┓': ''  , '┛': '▲' , '┗': '▲' ,
                \ '═': ''  , '║': '△' , '╬': '△' , '╣': '△' , '╠': '△' , '╦': ''  , '╩': '△' , '╔': ''  , '╗': ''  , '╝': '△' , '╚': '△' ,
                \ '╫': '△' , '╪': '^' , '╨': '△' , '╧': '^' , '╥': ''  , '╤': ''  , '╢': '△' , '╡': '^' , '╟': '△' , '╞': '^' , '╜': '△' ,
                \ '╛': '^' , '╙': '△' , '╘': '^' , '╖': ''  , '╕': ''  , '╓': ''  , '╒': ''  ,
                \ '┍': ''  , '┎': ''  , '┑': ''  , '┒': ''  , '┕': '^' , '┖': '▲' , '┙': '^' , '┚': '▲' ,
                \ '┝': '^' , '┞': '▲' , '┟': '^' , '┠': '▲' , '┡': '▲' , '┢': '^' ,
                \ '┥': '^' , '┦': '▲' , '┧': '^' , '┨': '▲' , '┩': '▲' , '┪': '^' ,
                \ '┭': ''  , '┮': ''  , '┯': ''  , '┰': ''  , '┱': ''  , '┲': ''  ,
                \ '┵': '^' , '┶': '^' , '┷': '^' , '┸': '▲' , '┹': '▲' , '┺': '▲' ,
                \ '┽': '^' , '┾': '^' , '┿': '^' , '╀': '▲' , '╁': '^' , '╂': '▲' , '╃': '▲' ,
                \ '╄': '▲' , '╅': '^' , '╆': '^' , '╇': '▲' , '╈': '^' , '╉': '▲' , '╊': '▲' ,
                \ '┌': ''  , '┐': ''  , '└': '^' , '┘': '^' , '┅': ''  , '┄': ''  , '┆': '^' , '┇': '▲' , ')': '^' , '❫': '▲' , '⟫': '△'
                \ },
                \   'down': {
                \ '-': '', '|': 'v', '+': 'v', '.': '', "'": '', '^': '', 'v': 'v', '<': '', '>': '',
                \ '─': '', '│': 'v', '┼': 'v', '┤': 'v', '├': 'v', '┬': 'v', '┴': '', '╭': 'v', '╮': 'v', '╯': '', '╰': '',
                \ '━': '', '┃': '▼', '╋': '▼', '┫': '▼', '┣': '▼', '┳': '▼', '┻': '', '┏': '▼', '┓': '▼', '┛': '', '┗': '',
                \ '═': '', '║': '▽', '╬': '▽', '╣': '▽', '╠': '▽', '╦': '▽', '╩': '', '╔': '▽', '╗': '▽', '╝': '', '╚': '',
                \ '╫': '▽', '╪': 'v', '╨': '', '╧': '', '╥': '▽', '╤': 'v', '╢': '▽', '╡': 'v', '╟': '▽', '╞': 'v', '╜': '',
                \ '╛': '', '╙': '', '╘': '', '╖': '▽', '╕': 'v', '╓': '▽', '╒': 'v',
                \ '┍': 'v', '┎': '▼', '┑': 'v', '┒': '▼', '┕': '', '┖': '', '┙': '', '┚': '',
                \ '┝': 'v', '┞': 'v', '┟': '▼', '┠': '▼', '┡': 'v', '┢': '▼',
                \ '┥': 'v', '┦': 'v', '┧': '▼', '┨': '▼', '┩': 'v', '┪': '▼',
                \ '┭': 'v', '┮': 'v', '┯': 'v', '┰': '▼', '┱': '▼', '┲': '▼',
                \ '┵': '', '┶': '', '┷': '', '┸': '', '┹': '', '┺': '',
                \ '┽': 'v', '┾': 'v', '┿': 'v', '╀': 'v', '╁': 'v', '╂': '▼', '╃': 'v',
                \ '╄': 'v', '╅': '▼', '╆': '▼', '╇': 'v', '╈': '▼', '╉': '▼', '╊': '▼',
                \ '┌': 'v', '┐': 'v', '└': '', '┘': '', '┅': '', '┄': '', '┆': 'v', '┇': '▼', ')': 'v', '❫': '▼', '⟫': '▽'
                \ }, 
                \   'left': {
                \ '-': '<', '|': '', '+': '<', '.': '', "'": '', '^': '', 'v': '', '<': '<', '>': '',
                \ '─': '<', '│': '', '┼': '<', '┤': '<', '├': '', '┬': '<', '┴': '<', '╭': '', '╮': '<', '╯': '<', '╰': '',
                \ '━': '◀', '┃': '', '╋': '◀', '┫': '◀', '┣': '', '┳': '◀', '┻': '◀', '┏': '', '┓': '◀', '┛': '◀', '┗': '',
                \ '═': '◁', '║': '', '╬': '◁', '╣': '◁', '╠': '', '╦': '◁', '╩': '◁', '╔': '', '╗': '◁', '╝': '◁', '╚': '',
                \ '╫': '<', '╪': '◁', '╨': '<', '╧': '◁', '╥': '<', '╤': '◁', '╢': '<', '╡': '◁', '╟': '', '╞': '', '╜': '<',
                \ '╛': '◁', '╙': '', '╘': '', '╖': '<', '╕': '◁', '╓': '', '╒': '',
                \ '┍': '', '┎': '', '┑': '◀', '┒': '<', '┕': '', '┖': '', '┙': '◀', '┚': '<',
                \ '┝': '', '┞': '', '┟': '', '┠': '', '┡': '', '┢': '',
                \ '┥': '◀', '┦': '<', '┧': '<', '┨': '<', '┩': '◀', '┪': '◀',
                \ '┭': '◀', '┮': '<', '┯': '◀', '┰': '<', '┱': '◀', '┲': '<',
                \ '┵': '◀', '┶': '<', '┷': '◀', '┸': '<', '┹': '◀', '┺': '<',
                \ '┽': '◀', '┾': '<', '┿': '◀', '╀': '<', '╁': '<', '╂': '<', '╃': '◀',
                \ '╄': '<', '╅': '◀', '╆': '<', '╇': '◀', '╈': '◀', '╉': '◀', '╊': '<',
                \ '┌': '', '┐': '<', '└': '', '┘': '<', '┅': '◀', '┄': '<', '┆': '', '┇': '', ')': '', '❫': '', '⟫': ''
                \ },
                \   'right': {
                \ '-': '>', '|': '', '+': '>', '.': '', "'": '', '^': '', 'v': '', '<': '', '>': '>',
                \ '─': '>', '│': '', '┼': '>', '┤': '', '├': '>', '┬': '>', '┴': '>', '╭': '>', '╮': '', '╯': '', '╰': '>',
                \ '━': '▶', '┃': '', '╋': '▶', '┫': '', '┣': '▶', '┳': '▶', '┻': '▶', '┏': '▶', '┓': '', '┛': '', '┗': '▶',
                \ '═': '▷', '║': '', '╬': '▷', '╣': '', '╠': '▷', '╦': '▷', '╩': '▷', '╔': '▷', '╗': '', '╝': '', '╚': '▷',
                \ '╫': '>', '╪': '▷', '╨': '>', '╧': '▷', '╥': '>', '╤': '▷', '╢': '', '╡': '', '╟': '>', '╞': '▷', '╜': '',
                \ '╛': '', '╙': '>', '╘': '▷', '╖': '', '╕': '', '╓': '>', '╒': '▷',
                \ '┍': '▶', '┎': '>', '┑': '', '┒': '', '┕': '▶', '┖': '>', '┙': '', '┚': '',
                \ '┝': '▶', '┞': '>', '┟': '>', '┠': '>', '┡': '▶', '┢': '▶',
                \ '┥': '', '┦': '', '┧': '', '┨': '', '┩': '', '┪': '',
                \ '┭': '>', '┮': '▶', '┯': '▶', '┰': '>', '┱': '>', '┲': '▶',
                \ '┵': '>', '┶': '▶', '┷': '▶', '┸': '>', '┹': '>', '┺': '▶',
                \ '┽': '>', '┾': '▶', '┿': '▶', '╀': '>', '╁': '>', '╂': '>', '╃': '>',
                \ '╄': '▶', '╅': '>', '╆': '▶', '╇': '▶', '╈': '▶', '╉': '>', '╊': '▶',
                \ '┌': '>', '┐': '', '└': '>', '┘': '', '┅': '▶', '┄': '>', '┆': '', '┇': '', ')': '', '❫': '', '⟫': ''
                \ }
                \ }
    return get(get(arrow_char_map, a:direction, {}), a:pre_char, '')
endfunction

" 绘图自动增加箭头功能
function! SmartDrawLinesAutoAddArrow()
    " 失效位置记录组
    call DrawSmartLineAutoGroupClear()
    " 判断移动的方向
    if !exists("g:prev_cursor_pos")
        return
    endif

    let [row, col] = [line('.'), virtcol('.')]
    let [pre_row, pre_col] = g:prev_cursor_pos

    if pre_row == row && col > pre_col
        let direction = 'right'
    elseif pre_row == row && col < pre_col
        let direction = 'left'
    elseif pre_col == col && row > pre_row
        let direction = 'down'
        " 为了和左右的策略保持一致
        let row -= 1
    elseif pre_col == col && row < pre_row
        " 为了和左右的策略保持一致
        let direction = 'up'
        let row += 1
    else
        return
    endif

    " 获取上一个位置的字符
    let [chars_array, index] = ProcessLine(pre_row, pre_col)
    let pre_char = chars_array[index]
    let arraw_char = SmartDrawLinesGetArrowChar(pre_char, direction)
    if empty(arraw_char)
        return
    endif
    let [cur_chars_array, cur_index] = ProcessLine(row, col)
    let cur_chars_array[index] = arraw_char
    let jumpcol = len(join(cur_chars_array[0:index], ''))
    call SetLineStr(cur_chars_array, row, row, jumpcol)
endfunction


" There is a space after the mapping below. In visual mode,
" a region is cut and saved in the x register, and all characters in the
" original region are replaced with spaces.
vnoremap xc "+ygvgr| " 辅助: 基于绘图的替换
vnoremap xx "+ygvgr | " 辅助: 基于绘图的剪切
vnoremap xy "+y| " 辅助: 基于绘图的复制

nnoremap <silent>sv :call VisualBlockMove("null")<cr>| " 辅助: 基于绘图的选择
nnoremap <silent> <C-j> :call VisualBlockMove("j")<cr>| " 辅助: 基于绘图的移动
nnoremap <silent> <C-k> :call VisualBlockMove("k")<cr>| " 辅助: 基于绘图的移动
nnoremap <silent> <C-h> :call VisualBlockMove("h")<cr>| " 辅助: 基于绘图的移动
nnoremap <silent> <C-l> :call VisualBlockMove("l")<cr>| " 辅助: 基于绘图的移动

vnoremap <silent>sw <Esc>:call TraverseRectangle()<cr>| " 辅助: 矩形绕行


" 切换绘制的线形并且打印出来

nnoremap <silent> sl :call SwitchSmartDrawLine(0)<CR>| " 辅助: 绘图循环改变线形
nnoremap <silent> ss :call SwitchSmartDrawLine(1)<CR>| " 辅助: 绘图显示当前线形
nnoremap <silent> su :call SwitchSmartDrawLineFromCharUnderCursor()<CR>| " 辅助: 绘图根据当前光标下字符改变线形
nnoremap <silent> sy :call CopyCharUnderCursor()<CR>| " 辅助: 绘图复制当前光标下的字符
nnoremap <silent> sp :call ReplaceCharUnderCursor('n')<CR>| " 辅助: 绘图粘贴当前光标下的字符
vnoremap <silent> sr :<C-u>call VisualReplaceToSpace()<cr> \| :call VisualReplaceChar()<cr>| " 辅助: 绘图可视区域替换当前光标下的字符


" 切换智能绘图交叉模式策略
nnoremap <silent> sx :call SwitchSmartLineCrossType()<CR>| " 辅助: 切换绘图的交叉模式


nnoremap <silent> sg :call SwitchDefineSmartDrawGraphSet(1)<CR>| " 辅助: 切换保存形状的函数集

nnoremap <silent> sf :call SwitchSmartDrawLev1Index(1)<CR>| " 辅助: 切换保存形状的大类正向
nnoremap <silent> sb :call SwitchSmartDrawLev1Index(-1)<CR>| " 辅助: 切换保存形状的大类反向
nnoremap <silent> so :call VisualBlockMouseMoveStart()<CR>| " 辅助: 绘图鼠标预览模式开启
nnoremap <silent> sq :call VisualBlockMouseMoveCancel()<CR>| " 辅助: 绘图鼠标预览模式取消
" 鼠标指针不能行到图形上,不然会导致不能响应命令
nnoremap <silent> <M-ScrollWheelDown> :call SwitchSmartDrawLev2Index(1)<CR>| " 辅助: 切换保存形状的小类正向
nnoremap <silent> <M-ScrollWheelUp> :call SwitchSmartDrawLev2Index(-1)<CR>| " 辅助: 切换保存形状的小类反向
nnoremap <silent> <M-u> :call SwitchSmartDrawLev2Index(1)<CR>| " 辅助: 切换保存形状的小类正向
nnoremap <silent> <M-y> :call SwitchSmartDrawLev2Index(-1)<CR>| " 辅助: 切换保存形状的小类反向
nnoremap <silent> <M-t> :call SwitchSmartDrawLev2Index(0)<CR>| " 辅助: 切换保存形状的小类反向
let g:switch_smart_draw_lev2_step_index = 0
nnoremap <silent> sk :let g:switch_smart_draw_lev2_step_index = !g:switch_smart_draw_lev2_step_index<CR>| " 辅助: 切换保存形状的小类步长索引(决定某些形状的长宽的)


nnoremap <silent> <C-S-Right> :call ReplaceCharUnderCursor('l')<CR>| " 辅助: 绘图粘贴当前光标下的字符，并向右移动
nnoremap <silent> <C-S-Left> :call ReplaceCharUnderCursor('h')<CR>| " 辅助: 绘图粘贴当前光标下的字符，并向左移动
nnoremap <silent> <C-S-Up> :call ReplaceCharUnderCursor('k')<CR>| " 辅助: 绘图粘贴当前光标下的字符，并向上移动
nnoremap <silent> <C-S-Down> :call ReplaceCharUnderCursor('j')<CR>| " 辅助: 绘图粘贴当前光标下的字符，并向下移动


" 绘制一条线，智能决定边界
nnoremap <silent> <M-l> :call DrawSmartLineLeftRight('l')<CR>| " 辅助: 绘图右线绘制
nnoremap <silent> <M-h> :call DrawSmartLineLeftRight('h')<CR>| " 辅助: 绘图左线绘制
nnoremap <silent> <M-j> :call DrawSmartLineUpDown('j')<CR>| " 辅助: 绘图下线绘制
nnoremap <silent> <M-k> :call DrawSmartLineUpDown('k')<CR>| " 辅助: 绘图上线绘制
nnoremap <silent> sa :call SmartDrawLinesAutoAddArrow()<CR>| " 辅助: 绘图智能增加箭头

" 橡皮擦功能
nnoremap <silent> <C-M-l> :call DrawSmartLineEraser('l')<CR>| " 辅助: 绘图右边橡皮擦
nnoremap <silent> <C-M-h> :call DrawSmartLineEraser('h')<CR>| " 辅助: 绘图左边橡皮擦
nnoremap <silent> <C-M-j> :call DrawSmartLineEraser('j')<CR>| " 辅助: 绘图下边橡皮擦
nnoremap <silent> <C-M-k> :call DrawSmartLineEraser('k')<CR>| " 辅助: 绘图上边橡皮擦

nnoremap <silent> <C-M-Space> :call PasteVisualXreg(1)<CR>| " 辅助: 基于绘图的粘贴完全覆盖
nnoremap <silent> <C-S-Space> :call PasteVisualXreg(0)<CR>| " 辅助: 基于绘图的粘贴但是忽略空格
nnoremap <silent> st :call SwitchVisualBlockPopupType()<CR>| " 辅助: 绘图更改弹出窗口类型

" 斜线(M-U O M I)
nnoremap <silent> <m-U> :call DrawSmartLineSlash('u')<cr>
nnoremap <silent> <m-N> :call DrawSmartLineSlash('n')<cr>
nnoremap <silent> <m-I> :call DrawSmartLineSlash('i')<cr>
nnoremap <silent> <m-M> :call DrawSmartLineSlash('m')<cr>





" :TODO: 基于范围绘制一个圆(如果选择区域不满足要求按照最小规则生成一个,自动重新选择区域并且生成)
" :TODO: 圆的实现和其它图形的实现都不用使用标准的算法，直接在图形库中写死即可
" 键就是宽和高,然后可以分类，有圆有三角形还可以有五角星等等
" 使用弹出窗口空格为空的预览效果即可。

" 设置html的自动补全(使用vim内置的补全插件)ctrl-x-o触发
" 位于autoload目录下(这个目录下可能还有不少好东西)
autocmd filetype html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd filetype css setlocal omnifunc=csscomplete#CompleteCSS
autocmd filetype javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd filetype xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd filetype zim setlocal omnifunc=OmniCompleteCustom


" C语言的编译和调试
" 打开termdebug
packadd termdebug
nnoremap <leader><leader>m :make<cr>| " 构建: 执行make命令
" 在vim中执行make不是执行make命令,而是执行makeprg的命令,不要混淆
" 增加告警显示和gdb的调试支持
set makeprg=gcc\ -g\ -Wall\ -o\ %<\ %

" 快速编译当前源文件为可执行文件(支持gdb调试和告警信息显示)(直接用vim的make命令更好,这里没有必要)
" nnoremap <leader>cfe :!gcc.exe -g -Wall %:p -o %:p:r.exe<CR>
" nnoremap <leader>cfe :terminal gcc.exe -g -Wall %:p -o %:p:r.exe<CR>


" 设置conceallevel的收缩级别
nnoremap <leader>cc0 :set conceallevel=0<cr>| " 辅助: 设置conceallevel级别0
nnoremap <leader>cc2 :set conceallevel=2<cr>| " 辅助: 设置conceallevel级别2

" 设置虚拟文本
nnoremap <leader>vea :set ve=all<cr>| " 辅助: 设置虚拟文本
nnoremap <leader>ven :set ve=<cr>| " 辅助: 取消设置虚拟文本

" 设置平滑滚动(vim9.1新增),不过目前没看出来效果是啥
set smoothscroll

" 关闭预览窗口(主要是自定义补全不冲突)
set completeopt-=preview

" 设置打开和关闭语法高亮快捷键
" :TODO: 不知道从哪个配置开始NERDTree的显示不正常,需要先关闭语法高亮然后再打开语法高亮才能正常(默认会显示多余的^G字符,有空再定位吧,可能是哪个设置导致的)
" 定位方法是回退当前配置的git前面的提交,一直回退到不出问题的vimrc的版本
nnoremap <silent> <leader>sof :syntax off<cr>| " 辅助: 取消语法高亮(提高效率)
nnoremap <silent> <leader>son :syntax on<cr>| " 辅助: 取消语法高亮(增加可读性)

nnoremap <leader>swa yiw/\<<C-R>"\>| " 搜索: 当前文件当前光标下单词全词自动搜索
nnoremap <leader>swm /\<\><Left><Left>| " 搜索: 当前文件全词手动搜索

" 设置vim等待某些事件的刷新事件(默认是4000ms)[ :TODO: 这个设置可能比较危险,目前还不确定有什么副作用]
set updatetime=100

" 自动创建注释
set formatoptions+=ro


" 基本设置区域 }

" 加载插件前指定coc配置文件路径不使用默认的
let g:coc_config_home = $VIM


" 插件 {
call plug#begin('~/.vim/plugged')

" 这个补全插件的位置最好放置到最前面,目前不直到原因
Plug 'qindapao/gtagsomnicomplete', {'branch': 'for_use'}                       " gtags完成插件
" Plug 'qindapao/vim-guifont'                                                    " 灵活设置字体大小
Plug 'qindapao/nerdtree'                                                       " 文件管理器
Plug 'qindapao/nerdtree-git-plugin'                                            " nerdtree中显示git变化
Plug 'qindapao/vim-surround'                                                   " 单词包围
Plug 'qindapao/vim-repeat'                                                     " vim重复插件,可以重复surround的内容
" 暂时用不着
" Plug 'WolfgangMehner/bash-support'                                           " bash开发支持
Plug 'qindapao/auto-pairs'                                                     " 插入模式下自动补全括号
Plug 'qindapao/ale'                                                            " 异步语法检查和自动格式化框架
" 如果编辑挂载的远程文件,下面这个插件会导致很卡
Plug 'qindapao/vim-airline'                                                    " 漂亮的状态栏
Plug 'qindapao/tabular'                                                        " 自动对齐插件
" 下面两个插件任选其一
" Plug 'qindapao/indentLine'                                                    " 对齐参考线插件
Plug 'qindapao/vim-indent-guides'                                              " 使用高亮而不是字符来对齐参考线
Plug 'qindapao/vim-fugitive'                                                   " vim的git集成插件
Plug 'qindapao/vim-rhubarb'                                                    " 用于打开gi的远程
" 这个插件功能和vim-flog重复,先屏蔽
" Plug 'junegunn/gv.vim'                                                         " git树显示插件
Plug 'qindapao/vim-flog'                                                       " 显示漂亮的git praph插件
" 如果编辑挂载的远程文件,下面这个插件会导致很卡
Plug 'qindapao/vim-gitgutter'                                                  " git改变显示插件
Plug 'qindapao/vimcdoc'                                                        " vim的中文文档
if expand('%:e') ==# 'txt' || expand('%:e') ==# 'md'
    " 这里要注意下,这个插件会导致preview预览涂鸦窗口无法关闭,影响自定义补全
    Plug 'qindapao/completor.vim'                                              " 主要是用它的中文补全功能
else
    " 这里必须使用realese分支,不能用master分支,master分支需要自己编译
    Plug 'qindapao/coc.nvim', {'branch': 'release'}
endif
Plug 'qindapao/vim-gutentags'                                                  " gtags ctags自动生成插件
Plug 'qindapao/gutentags_plus'                                                 " 方便自动化管理tags插件
Plug 'qindapao/tagbar'                                                         " 当前文件的标签浏览器
Plug 'qindapao/vim-bookmarks'                                                  " vim的书签插件
" 另外一个标记管理器(这个是标记并不是书签,书签是持久化的,这个不是,并且只能字母,所以需要和书签配合起来使用)
" 不是很好用,直接屏蔽
" Plug 'Yilin-Yang/vim-markbar'
Plug 'qindapao/vim-highlighter'                                                " 多高亮标签插件

Plug 'qindapao/vim-table-mode'                                                 " 表格模式编辑插件
Plug 'qindapao/LeaderF'                                                        " 模糊搜 索插件
Plug 'qindapao/ctrlsf.vim'                                                     " 全局搜 索替换插件
" 有ctrlsf插件够用,这个功能重复
" Plug 'brooth/far.vim'                                                          " 另外一个全局替换插件
Plug 'qindapao/vim-terminal-help'                                              " 终端帮助插件
" Plug 'easymotion/vim-easymotion'                                               " 快速移动插件
Plug 'qindapao/vim9-stargate'
" 高亮当前行的跳转关键字,用处不大
" Plug 'unblevable/quick-scope'
" Plug 'justinmk/vim-sneak'                                                      " 双字符移动插件
Plug 'qindapao/vim-rainbow'                                                    " 彩虹括号
Plug 'qindapao/vim-commentary'                                                 " 简洁注释
" 按照插件的说明来安装,安装的时候需要稍微等待一些时间,让安装钩子执行完毕
Plug 'qindapao/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" 这个插件暂时不要,默认的无法高亮就很好,这个反而弄得乱七八糟,这个插件还有个问题是,git对比的时候也弄得乱七八糟,所以先直接禁用掉
Plug 'qindapao/vim-markdown'                                                   " markdown 增强插件
Plug 'qindapao/img-paste.vim', {'branch': 'for_zim'}                           " markdown 直接粘贴图片
Plug 'qindapao/vim-markdown-toc'                                               " 自动设置标题

" 这个也没啥用,先禁用掉
" Plug 'fholgado/minibufexpl.vim'                                                " buffer窗口
" 最强大的文档插件,暂时屏蔽
" Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'qindapao/vim-startify'                                                   " vim的开始页
Plug 'qindapao/vim-lastplace'                                                  " 打开文件的上次位置
Plug 'qindapao/diffchar.vim'                                                   " 更明显的对比
" Plug 'terryma/vim-multiple-cursors'                                            " vim的多光标插件
Plug 'qindapao/vim-visual-multi'                                               " 这个插件比上面插件更轻便更快
" qindapao/colorizer这个插件的性能特别低!暂时不要打开,会导致gvim在处理大文件时候拆分窗口和TAB标签页的处理都非常缓慢
" 暂时可以先屏蔽,等需要显示颜色的时候打开
" Plug 'qindapao/vim-coloresque'                                                 " 这个也是颜色显示插件但是没有性能问题
Plug 'qindapao/vim-indent-object'                                              " 基于缩进的文本对象，用于python等语言
Plug 'qindapao/vim-paragraph-motion'                                           " 增强{  }段落选择的功能,可以用全空格行作为段落
" 这个插件的语法高亮需要说明下,可能是受默认的txt文件的语法高亮的影响
" 所以它的语法高亮的优先级并不高,需要先关闭所有的语法高亮，然后单独打开
" syntax off
" syntax on
" 依次要执行上面两条指令
Plug 'qindapao/vim-zim', {'branch': 'syntax_dev'}                              " 使用我稍微修改过的分支

" 并不需要
" Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
" 用处不大,暂时屏蔽
" Plug 'mbbill/undotree'
Plug 'qindapao/vim-signature'
" 状态栏不需要显示buffer名字
" Plug 'bling/vim-bufferline'
Plug 'qindapao/QFGrep'                                                         " Quickfix窗口过滤
Plug 'qindapao/traces.vim'                                                     " 搜 索效果显示
" Plug 'qindapao/vim-visual-star-search'                                         " 增强星号搜 索
" 暂时用不上先屏蔽
" Plug 'hari-rangarajan/CCTree'                                                  " C语言的调用树
" 使用下面这个rooter是对的,另外的一个rooter会造成set autochdir命令失效
Plug 'qindapao/vim-rooter'                                                     " root目录设置插件
" 画图插件,用处不大
" Plug 'vim-scripts/DrawIt'                                                      " 文本图绘制
" 画图插件,用处不大
" Plug 'yoshi1123/vim-linebox'                                                   " 可以画unicode方框图和线条
" 中文处理有问题,屏蔽
" Plug 't9md/vim-textmanip'                                                      " 可视模式的文本移动和替换
" 画盒子的插件,用处不大
" Plug 'GCRev/vim-box-draw'                                                      " 好看的unicode盒子，可以交叉
" Plug 'rhysd/clever-f.vim'                                                      " 聪明的f,这样就不用逗号和分号来重复搜 索字符,它们可以用作别的映射
" 当前这个插件会导致编辑txt和zim文件变得很卡,所以只用于特定的编程语言
" 太卡了先注释吧，编程的时候再放出来(这个很卡的的插件要放出来，不然TAB键无法生效?)
" Plug 'qindapao/ultisnips', { 'for': ['python', 'c', 'sh', 'perl'] }
Plug 'qindapao/vim-snippets'                                                   " 拥有大量的现成代码片段
" Plug 'artur-shaik/vim-javacomplete2'                                           " javac语义补全
Plug 'qindapao/vim-expand-region'                                              " vim的扩展选区插件
" 并不需要
Plug 'qindapao/vimspector'                                                     " 调试插件
" Plug 'github/copilot.vim'                                                    " 智能补全,只是尝试下功能
Plug 'qindapao/winresizer'                                                     " 调整窗口



" 主题相关
" Plug 'chiendo97/intellij.vim'                                                  " jetBrain的主题
" Plug 'cormacrelf/vim-colors-github'                                            " github 主题
" Plug 'jsit/toast.vim'                                                          " toast 主题
" Plug 'rakr/vim-one'                                                            " vim-one主题
Plug 'qindapao/vim', { 'as': 'catppuccin' }                                    " catppuccin 主题
" Plug 'muellan/am-colors'                                                       " 主题插件
" Plug 'NLKNguyen/papercolor-theme'                                              " 主题插件
" Plug 'scwood/vim-hybrid'                                                       " 主题插件
" Plug 'yous/vim-open-color'                                                     " vim的主题
" Plug 'pbrisbin/vim-colors-off'                                                 " 最简单的主题,所有的高亮基本关闭
" Plug 'preservim/vim-colors-pencil'                                             " 铅笔主题插件
" Plug 'humanoid-colors/vim-humanoid-colorscheme'                                " 高对对比度插件
" Plug 'jonathanfilip/vim-lucius'                                                " 高对比度主题
Plug 'qindapao/photon.vim'                                                       " 一个极简的漂亮主题
Plug 'qindapao/Lightning', {'branch': 'qq_modify'}

call plug#end()
" 插件 }

" 插件配置 {
" vim-expand-region {
" + " 辅助:vim-expand-region 普通模式下扩大选区
" _ " 辅助:vim-expand-region 普通模式下缩小选区
" 扩大选区
nnoremap <M-i> <Plug>(expand_region_expand)| " 编辑: 普通模式下扩大选区
vnoremap <M-i> <Plug>(expand_region_expand)| " 编辑: 可视模式下扩大选区

" 缩小选区
nnoremap <M-o> <Plug>(expand_region_shrink)| " 编辑: 普通模式下缩小选区
vnoremap <M-o> <Plug>(expand_region_shrink)| " 编辑: 可视模式下缩小选区
" vim-expand-region }

" table-mode {
noremap <leader>tm :TableModeToggle<CR>| " 辅助: 表格编辑模式
let g:table_mode_corner='|'

" table-mode }

" dense-analysis/ale {
" 开启或者关闭ALE
" :ALEToggle
" 禁用ALE
" :ALEDisable
" 保存的时候不要自动检查
let g:ale_lint_on_save = 0
" 手动关闭ale(大部分的卡顿都是这里造成的,包括打开md文件)
nnoremap <leader>aleof :ALEDisable<cr>| " lint: 关闭ale的语法检查
" 手动打开ale
nnoremap <leader>aleon :ALEEnable<cr>| " lint: 打开ale的语法检查
" }

" 注意coc.nvim插件也有语法检查功能(某些情况下也需要关闭,比如调试)
" 关闭
" :CocCommand eslint.disable
" 打开
" :CocCommand eslint.enable
" 如果上面的命令没有效果，可以直接关闭coc整个插件
" :CocDisable
" 要重新打开,使用
" CocEnable


" 设置格式化器
let g:ale_fixers = {
\   'sh': ['shfmt'],
\}
" 定制错误和告警标签
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
" 修改回显的格式
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" 在airline中显示错误消息
let g:airline#extensions#ale#enabled = 1
" 让浮动窗口的边框更好看
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
" 禁用ale的虚拟文本行
let g:ale_virtualtext_cursor = 0
" 保存的时候不要自动检查
let g:ale_lint_on_save = 0
" 不保存历史记录
let g:ale_history_enabled = 0











" " vim_signify的配置 git显示插件
" set updatetime=100                                     "设置异步的刷新时间
" map <Leader>d :SignifyHunkDiff<CR>                     " 显示git差异



" java检查相关设置
" 指定javac使用的编码防止乱码,但是发现配置了并没有作用
let g:ale_java_javac_options = '-encoding utf8 -verbose'
" 不确定是否需要手动设置
" let g:ale_java_javac_classpath = 'src:lib/foo.jar:lib/bar.jar'
" 暂时不知道-cp "lib/*"的含义
" let g:ale_java_javac_options = '-encoding utf8 -cp "lib/*"'
let g:ale_java_javac_classpath = '.'
" let g:ale_java_javac_executable = 'C:\Program Files\Java\jdk-18.0.2\bin\javac.exe'
" 当前使用coc的这个版本的javac.exe才没有中文乱码问题,使用系统默认的还有问题(上面这个)
" 应该是因为jdk的版本和工具的版本必须一致,当前我使用的jdk是17的,就要用17的这个javac
" 只有当有问题的时候才需要指定这个路径
" 使用~/.vim/这种路径也是不行的,不知道原因
" let g:ale_java_javac_executable = '~/.vim/coc/extensions/coc-java-data/jdk-17.0.8/javajre-windows-64/jre/bin/javac.exe'
" 如果当前的配置就可以，如果当前默认的javac就是对的，那么这里暂时就不用修改,如果无法找到正确的就需要修改
" let g:ale_java_javac_executable = 'C:\Users\pc\.vim\coc\extensions\coc-java-data\jdk-17.0.8\javajre-windows-64\jre\bin\javac.exe'

" dense-analysis/ale }

" vim-gutentags {
" :TODO: 当前插件只支持ctags.exe和readtags.exe房子的从这个目录C:\Users\xx\.vim，如果在子目录中就无法识别
" C:\Users\pc\.vim
"   ctags.exe
"   readtags.exe
"   ctags\
"       ctags.exe
"       readtags.exe
" 这两句非常重要是缺一不可的,并且配置文件的路径一定不能写错
let $GTAGSLABEL = 'native-pygments'                                              " 让非C语言使用这个生成符号表
" 这里的路径注意下一定要是绝对路径
let $GTAGSCONF = 'C:/Users/pc/.vim/gtags/share/gtags/gtags.conf'                 " gtags的配置文件的路径

let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']      " gutentags 搜 索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_ctags_tagfile = '.tags'                                          " 所生成的数据文件的名称

let g:gutentags_modules = ['ctags', 'gtags_cscope']                              " 同时开启 ctags 和 gtags 支持

" 用leaderf设置的缓存目录,这里就不要设置了,屏蔽掉
" let g:gutentags_cache_dir = expand('~/.cache/tags')                              " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录

" 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

let g:gutentags_plus_switch = 0                                                  " 是否自动将光标定位到自动修复列表位置 0:禁用 1:打开

" 下面这行是调试用的,当生成的tag出了问题,需要用这行来调试
let g:gutentags_define_advanced_commands = 1
" vim-gutentags }

" gutentags_plus 插件配置 {

" 打开新的窗口，并且光标在跳转栏
let g:gutentags_plus_nomap = 1
nnoremap <silent> <leader>gws :belowright split \| GscopeFind s <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
nnoremap <silent> <leader>gwg :belowright split \| GscopeFind g <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
nnoremap <silent> <leader>gwc :belowright split \| GscopeFind c <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
nnoremap <silent> <leader>gwt :belowright split \| GscopeFind t <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
nnoremap <silent> <leader>gwe :belowright split \| GscopeFind e <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
nnoremap <silent> <leader>gwf :belowright split \| GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
nnoremap <silent> <leader>gwi :belowright split \| GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
nnoremap <silent> <leader>gwd :belowright split \| GscopeFind d <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
nnoremap <silent> <leader>gwa :belowright split \| GscopeFind a <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
nnoremap <silent> <leader>gwz :belowright split \| GscopeFind z <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词

nnoremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
nnoremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
nnoremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
nnoremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
nnoremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
nnoremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
nnoremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
nnoremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
nnoremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
nnoremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词

vnoremap <leader>gws y:belowright split \| GscopeFind s <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
vnoremap <leader>gwg y:belowright split \| GscopeFind g <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
vnoremap <leader>gwc y:belowright split \| GscopeFind c <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
vnoremap <leader>gwt y:belowright split \| GscopeFind t <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
vnoremap <leader>gwe y:belowright split \| GscopeFind e <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
vnoremap <leader>gwf y:belowright split \| GscopeFind f <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
vnoremap <leader>gwi y:belowright split \| GscopeFind i <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
vnoremap <leader>gwd y:belowright split \| GscopeFind d <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
vnoremap <leader>gwa y:belowright split \| GscopeFind a <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
vnoremap <leader>gwz y:belowright split \| GscopeFind z <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词

vnoremap <leader>gs y:GscopeFind s <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
vnoremap <leader>gg y:GscopeFind g <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
vnoremap <leader>gc y:GscopeFind c <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
vnoremap <leader>gt y:GscopeFind t <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
vnoremap <leader>ge y:GscopeFind e <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
vnoremap <leader>gf y:GscopeFind f <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
vnoremap <leader>gi y:GscopeFind i <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
vnoremap <leader>gd y:GscopeFind d <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
vnoremap <leader>ga y:GscopeFind a <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
vnoremap <leader>gz y:GscopeFind z <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词
" gutentags_plus 插件配置 }

" 扩展选择(这里只是记录备忘,所用默认配置即可) {
" nnoremap v<count>ii | " 辅助: 选择当前缩进，不包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>ai | " 辅助: 选择当前缩进，包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>iI | " 辅助: 选择当前缩进，包括上下边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>aI | " 辅助: 选择当前缩进，不包括上下边界，(微调使用o命令，可以在可视选框上下调整)

" 扩展选择 }

" NERDTree {
nnoremap <leader><leader><F8> :NERDTreeToggle<CR>| " 目录树: 切换目录树打开关闭
" 刷新NERDTree的状态
nnoremap <leader>r :NERDTreeFocus<cr>:NERDTreeRefreshRoot<cr><c-w>p| " 目录树: 刷新目录树状态
nnoremap <leader>ntf :NERDTreeFind<cr>:NERDTreeRefreshRoot<cr><c-w>p| " 目录树: 进入当前文件对应的目录树并且刷新目录树状态
" NERDTree的修改文件的界面使用更小的界面显示
let NERDTreeMinimalMenu = 1
let NERDTreeShowHidden = 1
let NERDTreeAutoDeleteBuffer = 1

" 让NERDTree在右边打开
let NERDTreeWinPos="right"

" NERDTree }

" nerdtree-git-plugin 插件 {
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'*',
                \ 'Staged'    :'+',
                \ 'Untracked' :'o',
                \ 'Renamed'   :'^',
                \ 'Unmerged'  :'=',
                \ 'Deleted'   :'X',
                \ 'Dirty'     :'x',
                \ 'Ignored'   :'.',
                \ 'Clean'     :'v',
                \ 'Unknown'   :'?',
                \ }

" nerdtree-git-plugin 插件 }

" vim-gitgutter {
let g:gitgutter_git_executable = 'D:\programes\git\Git\bin\git.exe'              " git可执行文件路径
let g:gitgutter_max_signs = -1                                                   " 标记的数量为无限
" vim-gitgutter }

" vim-guifont {

" 使用了外部二进制 nircmd.exe
" :TODO: 如果要精细过滤可以下面这样
" nircmd.exe win setsize find "MyDocument" class "Vim" 0 0 800 600
" 目前这个函数并没有意义(有set guioptions+=k选项就够了)
function! ResizeGvimWindow(x, y, width, height)
  " 构建 nircmd 命令字符串
  let l:nircmd_cmd = 'nircmd.exe win setsize class "vim" ' . a:x . ' ' . a:y . ' ' . a:width . ' ' . a:height
  " 调用 nircmd 命令
  call system(l:nircmd_cmd)
endfunction

" 使用powershell命令获取GVim窗口的像素大小(windows系统专用!目前只支持一个窗口的情况)
" :TODO: 精细过滤可以文件名或者?
" 目前这个函数并没有意义(有set guioptions+=k选项就够了)
function! GetGvimWindowSize()
    let l:ps_script_path = 'E:\code\my_vim_config\get_win_size.ps1'
    let l:cmd = 'powershell -ExecutionPolicy Bypass -File ' . shellescape(l:ps_script_path)
    let l:size = system(l:cmd)
    return l:size
endfunction


function! PreserveWindowSize(delta)
    " let l:size = GetGvimWindowSize()
    " let l:pattern = 'Width: \(\d\+\), Height: \(\d\+\)'
    " let matches = matchlist(l:size, pattern)
    " " 先保存原始的像素尺寸
    " let l:window_width_px = matches[1]
    " let l:window_height_px = matches[2]

    " " 获取窗口的起始位置
    " let l:pos = execute('silent! winpos')
    " let l:x = split(split(l:pos, 'X')[1], ',')[0]
    " let l:y = split(split(l:pos, 'Y')[1], ' ')[0]

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

    " 这里可能需要乘以一个缩放比例,根据环境不同可能需要调整
    " call ResizeGvimWindow(l:x, l:y, l:window_width_px, l:window_height_px)
endfunction

" 调整字体大小的时候不要重新计算窗口大小
set guioptions+=k

" 使用小数步进值
nnoremap <silent> <C-ScrollWheelDown> :call PreserveWindowSize(-0.5)<CR>| " 辅助: 减小字体大小
nnoremap <silent> <C-ScrollWheelUp> :call PreserveWindowSize(0.5)<CR>| " 辅助: 增加字体大小

" let guifontpp_size_increment=1
" let guifontpp_smaller_font_map="<C-ScrollWheelDown>"
" let guifontpp_larger_font_map="<C-ScrollWheelUp>"
" let guifontpp_original_font_map="<F7>"


nnoremap <leader><C-t> :setlocal guifont=Yahei\ Fira\ Icon\ Hybrid:h| " 辅助: 设置另外一种字体
" vim-guifont }

" gtagsomnicomplete {
" https://github.com/ragcatshxu/gtagsomnicomplete 原始的位置,我修改了下，当前使用的是我修改后的
autocmd filetype c,perl set omnifunc=gtagsomnicomplete#Complete
autocmd filetype python setlocal omnifunc=OmniFuncPython
autocmd filetype sh setlocal omnifunc=OmniFuncShell
" gtagsomnicomplete }

" vim-rainbow {
let g:rainbow_active = 1                                                         " 插件针对所有文件类型全局启用
" vim-rainbow }

" " vim-one {
" colorscheme one
" let g:airline_theme='one'
" set background=dark                                                            " for the dark version
" " set background=light                                                         " for the light version
" " vim-one }

" " catppuccin主题 {
" let g:airline_theme = 'catppuccin_mocha'
" colorscheme catppuccin_frappe                                                  " 还可以选择catppuccin_latte catppuccin_macchiato catppuccin_mocha
" " catppuccin主题 }

" " toast主题 {
" set termguicolors
" set background=light
" colorscheme toast
" ser guicursor+=a:blinkon0
" " toast主题 }

" " vim-colors-github 主题 {
" let g:github_colors_soft = 1
" set background=light
" let g:github_colors_block_diffmark = 0
" colorscheme github
" let g:airline_theme = "github"
" " 切换亮和暗主题
" call github_colors#togglebg_map('<f6>')
" " vim-colors-github 主题 }

" " Mitgorakh/snow 主题 {
" colorscheme snow
" set background=light
" " Mitgorakh/snow 主题 {

" photon.vim 主题 {
" " Dark theme
" colorscheme photon
" Light theme
" colorscheme antiphoton
" photon.vim 主题 }
" " Lightning 主题 {
colorscheme Lightning
" " Lightning 主题 }
" colorscheme Atom
" colorscheme github
" set background=light
" colorscheme sunbather


" set t_Co=256
" " 还有amdard
" colorscheme amlight
" set guicursor+=a:blinkon0

" " papercolor-theme 主题 {
" " 这个主题用于git对比效果很好
" set t_Co=256   " This is may or may not needed.
" set background=light
" colorscheme PaperColor
" " papercolor-theme 主题 }

" " 为diff的时候单独设置一个颜色方案
" " 不过目前这个并没有效果(不知道原因)
" " 可以在对比的时候手动设置主题即可
" if &diff
"     set t_Co=256   " This is may or may not needed.
"     set background=light
"     colorscheme PaperColor
" endif

" " intellij 主题 {
" " 这个主题编码可以,但是用于git对比效果不好
" set background=light
" colorscheme intellij
" " let g:lightline.colorscheme='intellij'
" " intellij 主题 {

" " vim-hybrid 主题 {
" set background=light
" colorscheme hybrid
" " vim-hybrid 主题 }

" " vim-open-color 主题配置 {
" set background=light
" colorscheme open-color
" " vim-open-color 主题配置 }

" " vim-colors-off 主题配置 {
" colorscheme off
" set background=light
" " vim-colors-off 主题配置 }

" " vim-colors-pencil 主题配置 {
" colorscheme pencil
" set background=light
" " vim-colors-pencil 主题配置 }


" " vim-humanoid-colorscheme 插件配置 {
" colorscheme humanoid
" set background=light
" " 这里需要单独设置光标不闪烁
" set guicursor+=a:blinkon0
" " vim-humanoid-colorscheme 插件配置 }


" " lucius 主题配置 {
" colorscheme lucius
" let g:lucius_style = 'light'
" set background=light
" let g:lucius_contrast = 'normal'
" let g:lucius_contrast_bg = 'high'
" " lucius 主题配置 }

" LeaderF 配置 {

let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsGutentags = 1

let g:Lf_CacheDirectory = expand('~')
let g:gutentags_cache_dir = expand(g:Lf_CacheDirectory.'/LeaderF/gtags')         " vim-gentags和leaderf共享的配置,只能这样配



" 索引方式
let g:Lf_UseVersionControlTool=1                                                 " 这个是默认选项, 可以不写, 按照版本控制工具来索引
let g:Lf_DefaultExternalTool='rg'                                                " 如果不是一个repo, 那么使用rg工具来索引
" 下面的两个cache都不要使用,否则结果可能不准确或者不实时显示
let g:Lf_UseCache = 0                                                            " 不要使用缓存,这样结果是最准确的
let g:Lf_UseMemoryCache = 0                                                      " 也不要使用内存的缓存,保证每次结果都是准确的

let g:Lf_ShortcutB = '<c-l>'                                                     " 打开buffer搜 索窗口
let g:Lf_ShortcutF = '<c-p>'                                                     " 打开leaderf窗口

" 为不同的项目配置不同的忽略配置
" autocmd BufNewFile,BufRead X:/yourdir* let g:Lf_WildIgnore={'file':['*.vcproj', '*.vcxproj'],'dir':[]}

" popup menu的显示效果非常差,就暂时不用它了
" let g:Lf_WindowPosition = 'popup'                                              " 配置leaderf的弹出窗口类型为popup
" 根目录配置
let g:Lf_WorkingDirectoryMode = 'AF'                                             " 配置leaderf的工作目录模式
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', '.project', '.root']              " 根目录标识
let g:Lf_MruFileExclude = ['*.tmp', '*.swp']
let g:Lf_MruMaxFiles = 2000


" 字符串检索相关配置 可以手动补充的词 (-i 忽略大小写. -e <PATTERN> 正则表达式搜 索. -F 搜 索字符串而不是正则表达式. -w 搜 索只匹配有边界的词.)
nmap <leader>fr <Plug>LeaderfRgPrompt| "                  搜索:Leaderf Leaderf rg -e,然后等待输入正则表达式
nmap <leader>frb <Plug>LeaderfRgCwordLiteralNoBoundary| " 搜索:Leaderf 查询光标或者可视模式下所在的词,非全词匹配
nmap <leader>frw <Plug>LeaderfRgCwordLiteralBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的词,全词匹配
nmap <leader>fre <Plug>LeaderfRgCwordRegexNoBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
nmap <leader>frew <Plug>LeaderfRgCwordRegexBoundary| "    搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配
vmap <leader>frb <Plug>LeaderfRgVisualLiteralNoBoundary| "搜索:Leaderf 查询光标或者可视模式下所在的词,非全词匹配
vmap <leader>frw <Plug>LeaderfRgVisualLiteralBoundary| "  搜索:Leaderf 查询光标或者可视模式下所在的词,全词匹配
vmap <leader>fre <Plug>LeaderfRgVisualRegexNoBoundary| "  搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
vmap <leader>frew <Plug>LeaderfRgVisualRegexBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配

noremap ]n :Leaderf rg --next<CR>| " 搜索:Leaderf 跳转到字符串搜索列表的下一个结果
noremap ]p :Leaderf rg --previous<CR>| " 搜索:Leaderf 跳转到字符串搜索列表的上一个结果


noremap <leader>f :LeaderfSelf<cr>| " 搜索:Leaderf 搜索leaderf自己
noremap <leader>fm :LeaderfMru<cr>| " 搜索:Leaderf 搜索leaderf最近打开文件列表
noremap <leader>ff :LeaderfFunction<cr>| " 搜索:Leaderf 搜索函数
noremap <leader>fb :LeaderfBuffer<cr>| " 搜索:Leaderf 搜索buffer
noremap <leader>ft :LeaderfBufTag<cr>| " 搜索:Leaderf 搜索标签文件
noremap <leader>fl :LeaderfLine<cr>| " 搜索:Leaderf 搜索当前文件的所有行
noremap <leader>fw :LeaderfWindow<cr>| " 搜索:Leaderf 搜索打开的窗口
noremap <leader>frr :LeaderfRgRecall<cr>| " 搜索:Leaderf 搜索重新打开上一次的rg搜索

" search visually selected text literally, don't quit LeaderF after accepting an entry
" 这个不开启二次过滤
" 这里要注意下不能l键映射到最前面，不然会导致可视模式下自动往后多选择一个字符
xnoremap gfl :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>| " 搜索:Leaderf 不开启二次过滤的保留搜索列表(跳转后)
" 这个开启二次过滤
xnoremap gnfl :<C-U><C-R>=printf("Leaderf rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>| " 搜索:Leaderf 开启二次过滤的保留搜索列表(跳转后)

" 保持文件搜 索窗口不关闭
nnoremap <leader><C-P> :Leaderf file --stayOpen<CR>| " 搜索:Leaderf 文件搜索但是保持搜索窗口不关闭
" 保持当前文件行搜 索窗口不关闭
nnoremap <leader><leader>fl :Leaderf line --stayOpen<CR>| " 搜索:Leaderf 搜索文件行但是保持搜索窗口不关闭


" 关闭leaderf的预览窗口,不然会影响-stayOpen模式,预览窗口无法关闭,也无法编辑新的文件
let g:Lf_PreviewInPopup = 0

" leaderf不要自动生成标签,用gentags插件生成
" unique的意思是vim是否检查映射已经存在,如果存在会报错,当前暂时不需要这个功能
" nmap <unique> <leader>fgd <Plug>LeaderfGtagsDefinition
nmap <leader>fgd <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
nmap <C-LeftMouse> <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
nmap <leader>fgr <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
nmap <S-LeftMouse> <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
nmap <leader>fgs <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
nmap <A-LeftMouse> <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
nmap <leader>fgg <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)
nmap <C-A-LeftMouse> <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)

vmap <leader>fgd <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
vmap <leader>fgr <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
vmap <leader>fgs <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
vmap <leader>fgg <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)

noremap <leader>fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>| " 标签导航:Leaderf 重新打开最近的跳转命令
noremap <leader>fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>| " 标签导航:Leaderf 结果列表的下一个元素
noremap <leader>fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>| " 标签导航:Leaderf 结果列表的上一个元素

" LeaderF 配置 }
" tagbar 配置 {
map <leader><F4> :TagbarToggle<CR>| " 标签导航:Tagbar 切换打开和关闭Tagbar
let g:tagbar_type_zim = {
    \ 'ctagstype' : 'zim',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
let g:tagbar_type_txt = {
    \ 'ctagstype' : 'txt',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
" 0:不要按照tag名排序,而是按照tag出现的顺序排序
" 1:按照tag名排序
let g:tagbar_sort = 0
" tagbar 配置 }

" auto-pairs 配置 {
au filetype markdown,html let b:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '**':'**', '~~':'~~', '<':'>'}
" :TODO: 具体使用的时候在来调整,或者把公司中的配置同步过来
au filetype zim let b:AutoPairs = {'(':')', '[':']', '{':'}',"''":"''",'"':'"', '`':'`', '**':'**', '~~':'~~', '<':'>', '//':'//'}
" auto-pairs 配置 }

" doq的配置 {
let g:pydocstring_doq_path = 'D:/python/Script/doq'
" doq的配置 }



" vim-markdown {
" 这个命令可能失效,需要在vim中手动执行这个命令,编辑markdown文件的时候
let g:vim_markdown_emphasis_multiline = 0
" 设置语法收缩
let g:vim_markdown_conceal = 1
" 设置代码块提示语法收缩
let g:vim_markdown_conceal_code_blocks = 1
let g:vim_markdown_strikethrough = 1
" 设置禁用折叠,这个一定要设置,不然会造成对比的时候语法错乱
let g:vim_markdown_folding_disabled = 1
" vim-markdown }

" img-paste {
autocmd filetype zim,txt let g:mdip_imgdir = expand('%:t:r')
autocmd filetype zim,txt let g:PasteImageFunction = 'g:ZimwikiPasteImage'
autocmd filetype markdown,tex,zim,txt nmap <buffer><silent> <leader><leader>p :call mdip#MarkdownClipboardImage()<CR>| " markdown:zim 粘贴图片
autocmd FileType markdown silent! ALEDisableBuffer
" img-paste }

" 因为有星门vim9-stargate,所以easymotion暂时屏蔽
" " vim-easymotion 的配置 {
" let g:EasyMotion_smartcase = 1
" map <Leader>j <Plug>(easymotion-j)
" map <Leader>k <Plug>(easymotion-k)
" map <Leader>h <Plug>(easymotion-linebackward)
" map <Leader>l <Plug>(easymotion-lineforward)
" map <Leader><leader>. <Plug>(easymotion-repeat)
" " map <Leader>w <Plug>(easymotion-bd-w)
" map <C-;> <Plug>(easymotion-bd-w)
" " map <Leader>W <Plug>(easymotion-overwin-w)
" map <C-,> <Plug>(easymotion-overwin-w)
" map <Leader>f <Plug>(easymotion-bd-f)
" map <Leader>F <Plug>(easymotion-overwin-f)
" " vim-easymotion 的配置 }

" coc补全插件的一些配置 {
" 这行配置已经没有意义,因为coc-settings.json中已经配置了"suggest.noselect": true
" :TODO: 这里我的预期效果是要直接设置TAB，但是设置TAB无效，具体原因未知，不过这不是很重要,目前可以使用ctrl + n/p替代
inoremap <silent><expr> <S-TAB> pumvisible() ? coc#pum#next(1) : "\<TAB>"| " 补全: 补全插入

" 定义coc插件和数据的目录
let g:coc_data_home = '~/.vim/coc'
" 这个参数可能并没有作用
" let g:python3_host_prog = "D:\\python\\python.exe"
" coc补全插件的一些配置 }

" vim-gitgutter 插件配置 {
" 状态的刷新时间由updatetime决定
nnoremap gnh :GitGutterNextHunk<CR>| " git: 下一个改动点
nnoremap gph :GitGutterPrevHunk<CR>| " git: 上一个改动点
command! Gqf GitGutterQuickFix | copen
command! Gcf GitGutterQuickFixCurrentFile | copen

" vim-gitgutter 插件配置 }

" vim-markdown-toc 插件配置 {
let g:vmt_cycle_list_item_markers = 1
let g:vmt_auto_update_on_save = 1
" 自动更新

" vim-markdown-toc 插件配置 }

" vim-bookmarks 书签插件配置 {
let g:bookmark_save_per_working_dir = 0
" 这里不能设置自动保存，不然会在很多目录保存书签，目前不知道原因
let g:bookmark_auto_save = 1

" 不要使用默认的按键映射
let g:bookmark_no_default_key_mappings = 1
nmap <Leader><Leader>bt <Plug>BookmarkToggle| " 书签: 切换书签打开与关闭
nmap <Leader><Leader>bi <Plug>BookmarkAnnotate| " 书签: 创建一个注释书签
nmap <Leader><Leader>ba <Plug>BookmarkShowAll| " 书签: 显示所有的书签
nmap <Leader><Leader>bj <Plug>BookmarkNext| " 书签: 跳转到下一个书签
nmap <Leader><Leader>bk <Plug>BookmarkPrev| " 书签: 跳转到上一个书签
nmap <Leader><Leader>bc <Plug>BookmarkClear| " 书签: 删除当前书签
nmap <Leader><Leader>bx <Plug>BookmarkClearAll| " 书签: 删除所有书签

" these will also work with a [count] prefix
nmap <Leader>kk <Plug>BookmarkMoveUp| " 书签: 当前书签行上移
nmap <Leader>jj <Plug>BookmarkMoveDown| " 书签: 当前书签行下移
nmap <Leader>gl <Plug>BookmarkMoveToLine| " 书签: 书签移动到某一行


" vim-bookmarks 书签插件配置 }

" " indentLine 插件配置 {
" " let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" let g:indentLine_char_list = ['┊']
" let g:indentLine_concealcursor = "inc"
" " 这里会影响默认的缩进级别
" let g:indentLine_conceallevel = "2"

" autocmd filetype zim,markdown silent let g:indentLine_concealcursor = ""
" autocmd FileType * if &ft != 'zim' && &ft != 'markdown' | let g:indentLine_concealcursor = "inc" | endif

" " :verbose set conceallevel? 这样的命令可以查看最后设置某个配置的位置,可用于问题定位
" " 让json和markdown正常显示引号
" let g:vim_json_conceal=0
" let g:markdown_syntax_conceal=0
" " indentLine 插件配置 }

" vim-indent-guides {
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
autocmd filetype zim,markdown silent set conceallevel=2
autocmd FileType * if &ft != 'zim' && &ft != 'markdown' | set conceallevel=0 | endif
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#F0F0F0 ctermbg=15
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#F5F5F5 ctermbg=15

" vim-indent-guides }



" undotree 的配置 {
nnoremap <leader><F5> :UndotreeToggle<CR> | " undo: 切换undotree的打开和关闭
" undotree 的配置 }

" vim-bufferline 的配置 {
let g:bufferline_echo = 1
let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_modified = '+'
let g:bufferline_show_bufnr = 1
let g:bufferline_rotate = 1
let g:bufferline_fixed_index =  0
let g:bufferline_inactive_highlight = 'StatusLineNC'
let g:bufferline_active_highlight = 'StatusLine'
 let g:bufferline_pathshorten = 1
" vim-bufferline 的配置 }

" vim-rooter 插件配置
" 需要打印目录
let g:rooter_silent_chdir = 0
" 手动设置root目录
let g:rooter_manual_only = 1
let g:rooter_patterns = ['.root', '.svn', '.git', '.hg', '.project']

" vim-rooter 插件配置 {
nnoremap <leader>foo :Rooter<CR>| " 项目: 把当前的工作目录切换到项目的根目录
" vim-rooter 插件配置 }

" " vim-linebox 插件配置 {
" " 使用默认配置
" let g:linebox_default_maps = 1
" " vim-linebox 插件配置 }

" " vim-textmanip 插件配置 {
" let g:textmainip_startup_mode = 'replace'
" vnoremap <C-d> <Plug>(textmanip-duplicate-down)
" vnoremap <C-u> <Plug>(textmanip-duplicate-up)

" vnoremap <C-S-j> <Plug>(textmanip-move-down)
" vnoremap <C-S-k> <Plug>(textmanip-move-up)
" vnoremap <C-S-h> <Plug>(textmanip-move-left)
" vnoremap <C-S-l> <Plug>(textmanip-move-right)

" " toggle insert/replace with <F4>
" nmap <C-F4> <Plug>(textmanip-toggle-mode)

" " use allow key to force replace movement
" vnoremap  <Up>     <Plug>(textmanip-move-up-r)
" vnoremap  <Down>   <Plug>(textmanip-move-down-r)
" vnoremap  <Left>   <Plug>(textmanip-move-left-r)
" vnoremap  <Right>  <Plug>(textmanip-move-right-r)
" " vim-textmanip 插件配置 }

" " vim-box-draw 插件配置 {
" " 在有字符的情况下中间会多一条竖线，在纯ve=all的无字符的地方是正常的方框
" vnoremap xxb: call box#Draw()<CR>
" " vim-box-draw 插件配置 }

" " vim-snippets 插件配置 {
" Coc中安装这个就能触发代码片段,并且它读取的是UltiSnipsSnippetDirectories目录中的代码片段,另外UltiSnips目录也会默认读取
" :CocInstall coc-snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnips"]
" Utisnippest目录
" snippets.userSnippetsDirectory": "C:\\Users\\q00208337\\.vim\\plugged\\vim-snippets\\mysnips",
" vscode的textmate格式目录 sh.json 后缀
" snippets.textmateSnippetsRoots": ["C:\\Users\\q00208337\\.vim\\plugged\\vim-snippets\\textmate"]

inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" " vim-snippets 插件配置 }

" " airline {
let g:airline_theme = 'catppuccin_frappe'
" let g:airline_theme_dark = 'catppuccin_frappe'
" let g:airline_powerline_fonts = 1
" " airline }

" completor 插件配置 {
" pygments_parser.
" 关闭自动预览窗口(不知道是否会有什么负作用,但是可以解决强制打开预览窗口的问题)
" 就算是关闭这个选项也没用(涂鸦预览窗口还是会弹出)
let g:completor_auto_preview = 0
" set pythonthreedll=D:\python\python38.dll
let g:completor_auto_close_doc = 0
" let g:completor_clang_binary = 'D:\programs\LLVM\bin\clang.exe'
" 和javacomplete2配合起来使用,让javacomplete2的补全结果出现在我们的默认补全列表中
" .号或者::后面自动补全,或者输入任意的字符自动补全
" 这个不设置也能触发,但是可能优先级不够高
let g:completor_java_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
" let g:completor_zim_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
let g:completor_zim_omni_trigger = '(\S+)$'
let g:completor_html_omni_trigger = '(\.|::)?\w*'
let g:completor_css_omni_trigger = '(\.|::)?\w*'
let g:completor_markdown_omni_trigger = '(\.|::)?\w*'
let g:completor_javascript_omni_trigger = '(\.|::)?\w*'
let g:completor_python_omni_trigger = '(\S+)$'
let g:completor_xml_omni_trigger = '(\.|::)?\w*'
" let g:completor_bash_omni_trigger = '(\.|::)?\w*'
" 还是单词优先好,需要补全函数手动触发即可
let g:completor_sh_omni_trigger = '(\S+)$'
" 一般情况下completor插件会自动检测java_completor插件的东西的位置,如果检测成功,那么功能自动就是正常的,否则需要手动指定他们
" let g:completor_python_binary = '/path/to/python/with/jedi/installed'
" 可以关闭preview,这样不和自定义的补全的弹出窗口重复
" :TODO: 这里可以根据文件类型不同打开不同的参数
" let g:completor_complete_options = 'menuone,noselect,preview'
let g:completor_complete_options = 'menuone,noselect'


" completor.vim 补全插件配置 }


" vim_completor.git {

" 如果使用的是虚拟环境这里要配置虚拟环境的地址,补全这里还有一个问题,如果文件名不规范,有@等特殊字符,无法补全
" let g:completor_python_binary = 'D:/code/tu_refactor_learn/TU_Refactory/.venv/Scripts/python.exe'
let g:completor_python_binary = 'D:/python/python.exe'

noremap <silent> <leader><leader><leader>d :call completor#do('definition')<CR>| " 补全:completor 显示定义
noremap <silent> <leader><leader><leader>c :call completor#do('doc')<CR>| " 补全:completor 显示文档
noremap <silent> <leader><leader><leader>f :call completor#do('format')<CR>| " 补全:completor 格式化
noremap <silent> <leader><leader><leader>s :call completor#do('hover')<CR>| " 补全:completor ?
" vim_completor.git }

" completor 插件配置 {

" vimspector 调试插件配置 {
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools']
let g:vimspector_enable_mappings = 'HUMAN'

" 这是调试C语言默认的按键，其它的防止和它冲突
" F5	<Plug>VimspectorContinue	When debugging, continue. Otherwise start debugging.
" F3	<Plug>VimspectorStop	Stop debugging.
" F4	<Plug>VimspectorRestart	Restart debugging with the same configuration.
" F6	<Plug>VimspectorPause	Pause debuggee.
" F9	<Plug>VimspectorToggleBreakpoint	Toggle line breakpoint on the current line.
" <leader>F9	<Plug>VimspectorToggleConditionalBreakpoint	Toggle conditional line breakpoint or logpoint on the current line.
" F8	<Plug>VimspectorAddFunctionBreakpoint	Add a function breakpoint for the expression under cursor
" <leader>F8	<Plug>VimspectorRunToCursor	Run to Cursor
" F10	<Plug>VimspectorStepOver	Step Over
" F11	<Plug>VimspectorStepInto	Step Into
" F12	<Plug>VimspectorStepOut	Step out of current function scope
" 全局配置文件的路径在这里
" C:\Users\pc\.vim\plugged\vimspector\configurations\windows\C
" 针对具体的项目需要单独配置

" 插件的根目录(一般不用设置)
" let g:vimspector_base_dir='C:\Users\pc\.vim\plugged\vimspector'
nnoremap <leader>db <Plug>VimspectorBreakpoints| " 调试: 设置断点

" vimspector 调试插件配置 }

" ctrlsf 插件配置 {
" 有个小tips: 我们在搜 索结果页中我们可以使用zM折叠所有的搜 索结果(类似于vscode的效果)
" :TODO: 目前发现全词匹配-W不能和-I一起使用
" 获取光标下的单词(这里命令在第二个命令,所以不能用<cword>)
nnoremap <leader>cfip :Rooter<cr> :CtrlSF -I <C-r><C-w><cr>| "     搜索:ctrlsf:项目级 不敏感,非全词
nnoremap <leader>cfsp :Rooter<cr> :CtrlSF -S <C-r><C-w><cr>| "     搜索:ctrlsf:项目级 敏感,非全词
" 目前发现敏感和全词必须配套使用,否则全词功能失效?
nnoremap <leader>cfwp :Rooter<cr> :CtrlSF -S -W <C-r><C-w><cr>| "  搜索:ctrlsf:项目级 敏感,全词

nnoremap <leader>cfic :CtrlSF -I <C-r><C-w><cr>|             "     搜索:ctrlsf:当前目录递归 不敏感,非全词
nnoremap <leader>cfsc :CtrlSF -S <C-r><C-w><cr>|             "     搜索:ctrlsf:当前目录递归 敏感,非全词
nnoremap <leader>cfwc :CtrlSF -S -W <C-r><C-w><cr>|             "  搜索:ctrlsf:当前目录递归 敏感,全词

nnoremap <leader>cfid :CtrlSF -I <C-r><C-w> ./<cr>|          "     搜索:ctrlsf:仅限当前目录 不敏感,非全词
nnoremap <leader>cfsd :CtrlSF -S <C-r><C-w> ./<cr>|          "     搜索:ctrlsf:仅限当前目录 敏感,非全词
nnoremap <leader>cfwd :CtrlSF -S -W <C-r><C-w> ./<cr>|          "  搜索:ctrlsf:仅限当前目录 敏感,全词

nnoremap <leader>cfif :CtrlSF -I <C-r><C-w> %<cr>|           "     搜索:ctrlsf:当前文件 不敏感,非全词
nnoremap <leader>cfsf :CtrlSF -S <C-r><C-w> %<cr>|           "     搜索:ctrlsf:当前文件 敏感,非全词
nnoremap <leader>cfwf :CtrlSF -S -W <C-r><C-w> %<cr>|           "  搜索:ctrlsf:当前文件 敏感,全词

nnoremap <leader>cfmp :Rooter<cr> :CtrlSF -I | "                   搜索:ctrlsf:项目级 手动搜索
nnoremap <leader>cfmc :CtrlSF -I | "                               搜索:ctrlsf:当前目录递归 手动搜索
nnoremap <leader>cfmd :CtrlSF -I  ./|          "                   搜索:ctrlsf:仅限当前目录 手动搜索
nnoremap <leader>cfmf :CtrlSF -I  %|           "                   搜索:ctrlsf:当前文件 手动搜索

vnoremap <leader>cfip y:Rooter<cr> :CtrlSF -I <C-r>"<cr>| "        搜索:ctrlsf:项目级 不敏感,非全词
vnoremap <leader>cfsp y:Rooter<cr> :CtrlSF -S <C-r>"<cr>| "        搜索:ctrlsf:项目级 敏感,非全词
vnoremap <leader>cfwp y:Rooter<cr> :CtrlSF -S -W <C-r>"<cr>| "     搜索:ctrlsf:项目级 敏感,全词

vnoremap <leader>cfic y:CtrlSF -I <C-r>"<cr>| "                    搜索:ctrlsf:当前目录递归 不敏感,非全词
vnoremap <leader>cfsc y:CtrlSF -S <C-r>"<cr>| "                    搜索:ctrlsf:当前目录递归 敏感,非全词
vnoremap <leader>cfwc y:CtrlSF -S -W <C-r>"<cr>| "                 搜索:ctrlsf:当前目录递归 敏感,全词

vnoremap <leader>cfid y:CtrlSF -I <C-r>" ./<cr>| "                 搜索:ctrlsf:仅限当前目录 不敏感,非全词
vnoremap <leader>cfsd y:CtrlSF -S <C-r>" ./<cr>| "                 搜索:ctrlsf:仅限当前目录 敏感,非全词
vnoremap <leader>cfwd y:CtrlSF -S -W <C-r>" ./<cr>| "              搜索:ctrlsf:仅限当前目录 敏感,全词

vnoremap <leader>cfif y:CtrlSF -I <C-r>" %<cr>| "                  搜索:ctrlsf:当前文件 不敏感,非全词
vnoremap <leader>cfsf y:CtrlSF -S <C-r>" %<cr>| "                  搜索:ctrlsf:当前文件 敏感,非全词
vnoremap <leader>cfwf y:CtrlSF -S -W <C-r>" %<cr>| "               搜索:ctrlsf:当前文件 敏感,全词

" 设置vimgrep的全局排除规则
set wildignore=.git/**,tags,GPATH,GRTAGS,GTAGS
nnoremap <leader>vgip :Rooter<cr> :vimgrep /\c<C-r><C-w>/gj **/*<cr>| "      搜索:vimgrep:项目级 不敏感,非全词
nnoremap <leader>vgsp :Rooter<cr> :vimgrep /<C-r><C-w>/gj **/*<cr>| "        搜索:vimgrep:项目级 敏感,非全词
nnoremap <leader>vgwp :Rooter<cr> :vimgrep /\<<C-r><C-w>\>/gj **/*<cr>| "    搜索:vimgrep:项目级 敏感,全词
nnoremap <leader>vgiwp :Rooter<cr> :vimgrep /\c\<<C-r><C-w>\>/gj **/*<cr>| " 搜索:vimgrep:项目级 不敏感,全词

nnoremap <leader>vgic :vimgrep /\c<C-r><C-w>/gj **/*<cr>| "                  搜索:vimgrep:当前目录递归 不敏感,非全词
nnoremap <leader>vgsc :vimgrep /<C-r><C-w>/gj **/*<cr>| "                    搜索:vimgrep:当前目录递归 敏感,非全词
nnoremap <leader>vgwc :vimgrep /\<<C-r><C-w>\>/gj **/*<cr>| "                搜索:vimgrep:当前目录递归 敏感,全词
nnoremap <leader>vgiwc :vimgrep /\c\<<C-r><C-w>\>/gj **/*<cr>| "             搜索:vimgrep:当前目录递归 不敏感,全词

nnoremap <leader>vgid :vimgrep /\c<C-r><C-w>/gj *<cr>| "                     搜索:vimgrep:仅限当前目录 不敏感,非全词
nnoremap <leader>vgsd :vimgrep /<C-r><C-w>/gj *<cr>| "                       搜索:vimgrep:仅限当前目录 敏感,非全词
nnoremap <leader>vgwd :vimgrep /\<<C-r><C-w>\>/gj *<cr>| "                   搜索:vimgrep:仅限当前目录 敏感,全词
nnoremap <leader>vgiwd :vimgrep /\c\<<C-r><C-w>\>/gj *<cr>| "                搜索:vimgrep:仅限当前目录 不敏感,全词

nnoremap <leader>vgif :vimgrep /\c<C-r><C-w>/gj %<cr>| "                     搜索:vimgrep:当前文件 不敏感,非全词
nnoremap <leader>vgsf :vimgrep /<C-r><C-w>/gj %<cr>| "                       搜索:vimgrep:当前文件 敏感,非全词
nnoremap <leader>vgwf :vimgrep /\<<C-r><C-w>\>/gj %<cr>| "                   搜索:vimgrep:当前文件 敏感,全词
nnoremap <leader>vgiwf :vimgrep /\c\<<C-r><C-w>\>/gj %<cr>| "                搜索:vimgrep:当前文件 不敏感,全词

nnoremap <leader>vgmp :Rooter<cr> :vimgrep //gj **/*| "                      搜索:ctrlsf:项目级 手动搜索
nnoremap <leader>vgmc :vimgrep //gj **/*| "                                  搜索:ctrlsf:当前目录递归 手动搜索
nnoremap <leader>vgmd :vimgrep //gj *|          "                            搜索:ctrlsf:仅限当前目录 手动搜索
nnoremap <leader>vgmf :vimgrep //gj %|           "                           搜索:ctrlsf:当前文件 手动搜索

vnoremap <leader>vgip y:Rooter<cr> :vimgrep /\c<C-r>"/gj **/*<cr>| "         搜索:vimgrep:项目级 不敏感,非全词
vnoremap <leader>vgsp y:Rooter<cr> :vimgrep /<C-r>"/gj **/*<cr>| "           搜索:vimgrep:项目级 敏感,非全词
vnoremap <leader>vgwp y:Rooter<cr> :vimgrep /\<<C-r>"\>/gj **/*<cr>| "       搜索:vimgrep:项目级 敏感,全词
vnoremap <leader>vgiwp y:Rooter<cr> :vimgrep /\c\<<C-r>"\>/gj **/*<cr>| "    搜索:vimgrep:项目级 不敏感,全词

vnoremap <leader>vgic y:vimgrep /\c<C-r>"/gj **/*<cr>| "                     搜索:vimgrep:当前目录递归 不敏感,非全词
vnoremap <leader>vgsc y:vimgrep /<C-r>"/gj **/*<cr>| "                       搜索:vimgrep:当前目录递归 敏感,非全词
vnoremap <leader>vgwc y:vimgrep /\<<C-r>"\>/gj **/*<cr>| "                   搜索:vimgrep:当前目录递归 敏感,全词
vnoremap <leader>vgiwc y:vimgrep /\c\<<C-r>"\>/gj **/*<cr>| "                搜索:vimgrep:当前目录递归 不敏感,全词

vnoremap <leader>vgid y:vimgrep /\c<C-r>"/gj *<cr>| "                        搜索:vimgrep:仅限当前目录 不敏感,非全词
vnoremap <leader>vgsd y:vimgrep /<C-r>"/gj *<cr>| "                          搜索:vimgrep:仅限当前目录 敏感,非全词
vnoremap <leader>vgwd y:vimgrep /\<<C-r>"\>/gj *<cr>| "                      搜索:vimgrep:仅限当前目录 敏感,全词
vnoremap <leader>vgiwd y:vimgrep /\c\<<C-r>"\>/gj *<cr>| "                   搜索:vimgrep:仅限当前目录 不敏感,全词

vnoremap <leader>vgif y:vimgrep /\c<C-r>"/gj %<cr>| "                        搜索:vimgrep:当前文件 不敏感,非全词
vnoremap <leader>vgsf y:vimgrep /<C-r>"/gj %<cr>| "                          搜索:vimgrep:当前文件 敏感,非全词
vnoremap <leader>vgwf y:vimgrep /\<<C-r>"\>/gj %<cr>| "                      搜索:vimgrep:当前文件 敏感,全词
vnoremap <leader>vgiwf y:vimgrep /\c\<<C-r>"\>/gj %<cr>| "                   搜索:vimgrep:当前文件 不敏感,全词

let g:regexPatterns = [
\ '^：匹配行的开始。',
\ '$：匹配行的结束。',
\ '[]：匹配括号内的任何字符。',
\ '.：匹配任何单个字符（除了换行符）。',
\ '*：匹配前面的元素零次或多次。',
\ '+：匹配前面的元素一次或多次。',
\ '?：匹配前面的元素零次或一次。',
\ '\s：匹配任何空白字符，包括空格、制表符、换页符等。',
\ '\S：匹配任何非空白字符。',
\ '\d：匹配任何数字。',
\ '\D：匹配任何非数字字符。',
\ '\w：匹配任何字母、数字或下划线字符。',
\ '\W：匹配任何非字母、非数字和非下划线字符。',
\ '{n,m}：匹配前面的元素至少 n 次，但不超过 m 次。',
\ '{n,}：匹配前面的元素 n 次或更多次。',
\ '{,m}：匹配前面的元素不超过 m 次。',
\ '{n}：匹配前面的元素恰好 n 次。',
\ '|：表示或（or），匹配前面或后面的表达式。',
\ '( )：用于分组，匹配括号中的表达式。'
\ ]

" :TODO: 目前列表里面无法加注释只能放到外面来单独注释
" ^：匹配行的开始。                                    " 辅助:regexPatterns
" $：匹配行的结束。                                    " 辅助:regexPatterns
" []：匹配括号内的任何字符。                           " 辅助:regexPatterns
" .：匹配任何单个字符（除了换行符）。                  " 辅助:regexPatterns
" *：匹配前面的元素零次或多次。                        " 辅助:regexPatterns
" +：匹配前面的元素一次或多次。                        " 辅助:regexPatterns
" ?：匹配前面的元素零次或一次。                        " 辅助:regexPatterns
" \s：匹配任何空白字符，包括空格、制表符、换页符等。   " 辅助:regexPatterns
" \S：匹配任何非空白字符。                             " 辅助:regexPatterns
" \d：匹配任何数字。                                   " 辅助:regexPatterns
" \D：匹配任何非数字字符。                             " 辅助:regexPatterns
" \w：匹配任何字母、数字或下划线字符。                 " 辅助:regexPatterns
" \W：匹配任何非字母、非数字和非下划线字符。           " 辅助:regexPatterns
" {n,m}：匹配前面的元素至少 n 次，但不超过 m 次。      " 辅助:regexPatterns
" {n,}：匹配前面的元素 n 次或更多次。                  " 辅助:regexPatterns
" {,m}：匹配前面的元素不超过 m 次。                    " 辅助:regexPatterns
" {n}：匹配前面的元素恰好 n 次。                       " 辅助:regexPatterns
" |：表示或（or），匹配前面或后面的表达式。            " 辅助:regexPatterns
" ( )：用于分组，匹配括号中的表达式。                  " 辅助:regexPatterns


function! FindAndReplaceInFiles()
    let winid = ShowPopup(g:regexPatterns)
    " 这里的redraw至关重要
    redraw
    let file_pattern = input('Enter the file pattern(Rooter 进入项目根; **/* 目录递归; * 当前目录; % 当前文件): ')
    execute 'args ' . file_pattern
    let search_pattern = input('Enter the search pattern(\c 忽略大小写; \<\> 全词匹配): ')
    let replace_pattern = input('Enter the replace pattern: ')
    execute 'argdo %s/' . search_pattern . '/' . replace_pattern . '/gc | update'
    call popup_close(winid)
endfunction


nnoremap <leader>vs :call FindAndReplaceInFiles()<cr>| " 替换: vim内置替换功能封装

" 多文件替换相关的操作
" :args *.txt
" :argdo %s/foo/bar/gc | update

let g:ctrlsf_case_sensitive = 'yes'
let g:ctrlsf_follow_symlinks = 0
let g:ctrlsf_ignore_dir = ['docs/bak.md', '.gitignore']
let g:ctrlsf_backend = 'rg'
let g:ctrlsf_search_mode = 'async'
let g:ctrlsf_winsize = '30%'
" 默认按照字面意思搜 索
let g:ctrlsf_regex_pattern = 0

" ctrlsf 插件配置 }

" vim-terminal-help 插件配置 {
let g:terminal_height = 20
tnoremap <Esc> <C-\><C-n>| " 终端: 进入到普通模式
" 重新映射Esc键的功能
" <C-v>的默认功能是输出特殊字符,这里<C-S-->是不行的,不知道原因
tnoremap <C-v> <C-S-_>"+| " 终端: 粘贴系统剪切板
" 这个插件自定义了一个drop命令,但是使用有报错,可能是因为windows系统的换行符导致的
" 有空可以定位下 :TODO:

" vim-terminal-help 插件配置 }

" " quick-scope 插件 {
" highlight QuickScopePrimary ctermfg=red guifg=red
" highlight QuickScopeSecondary ctermfg=blue guifg=blue
" " 这里设置的特殊字符好像无效
" let g:qs_accepted_chars = map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)')
"             \+ map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)')
"             \+ map(range(char2nr('0'), char2nr('9')), 'nr2char(v:val)')
"             \+ ['"', ',', '.', "'", '!', '@', '+', '-']
" " 终端中不要高亮
" " let g:qs_buftype_blacklist = ['terminal', 'nofile']
" " quick-scope 插件 }

" vim9-stargate 插件配置 {
let g:stargate_limit = 300
" vim9-stargate 插件配置 }

" vim-fugitive 插件按键绑定 {
" 显示所有差异
nnoremap <silent> <leader>gda :Git difftool -y<cr>| " git:diff 显示所有差异
" commit 全对比
nnoremap <silent> <leader>gdc :execute 'Git! difftool ' . getreg('a') . ' ' . getreg('b') . ' --name-status'<CR>| " git:diff 对比两个commit
" 分支全对比
nnoremap <silent> <leader>gdb :execute 'Git! difftool ' . getreg('a') . ' --name-status'<CR>| " git:diff 对比两个分支或者两个commit(以当前的作为基准)
" 执行单文件对比(commit id 和 分支)
nnoremap <silent> <leader>gdv :execute 'Gvdiffsplit ' . getreg('a')<CR>| " git:diff 执行单文件对比
" 对比当前文件
nnoremap <silent> <leader>gdf :execute 'Gvdiffsplit'<CR>| " git:diff 对比当前文件

nnoremap <silent> <leader>gbn :Git checkout -b | "         git:branch 基于当前分支创建一个新分支
nnoremap <silent> <leader>gbl :execute 'Git branch'<CR>| " git:branch 查看所有本地分支
nnoremap <silent> <leader>gbc :execute 'normal "xyiw' \| execute 'Git checkout ' . getreg('x') \| close<CR>| "   git:branch 切换分支
vnoremap <silent> <leader>gbc y:execute 'Git checkout ' . shellescape(@0) \| close<CR>| "                        git:branch 切换分支
" 删除一个本地分支
nnoremap <silent> <leader>gbxl :execute 'normal "xyiw' \| execute 'Git branch -d ' . getreg('x') \| close<CR>| " git:branch 删除一个本地分支
vnoremap <silent> <leader>gbxl y:execute 'Git branch -d ' . shellescape(@0) \| close<CR>| "                      git:branch 删除一个本地分支
nnoremap <silent> <leader>gbfxl :execute 'normal "xyiw' \| execute 'Git branch -D ' . getreg('x') \| close<CR>| "git:branch 删除一个本地分支
vnoremap <silent> <leader>gbfxl y:execute 'Git branch -D ' . shellescape(@0) \| close<CR>| "                     git:branch 删除一个本地分支

" 删除一个远程分支
nnoremap <silent> <leader>gbxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -d ' . branchname<CR>| "  git:branch 删除一个远程分支
nnoremap <silent> <leader>gbfxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -D ' . branchname<CR>| " git:branch 删除一个远程分支

" 查看所有的远程分支
nnoremap <silent> <leader>gbr :execute 'Git remote prune origin' \| execute 'Git branch -r'<CR>| " git:branch 查看所有在远程分支
" 拉取一个远程分支并在本地跟踪它(复制远程分支名然后检出到本地)
" git fetch origin <远程分支名>:<本地分支名>
nnoremap <silent> <leader>gbfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git fetch origin ' . branchname . ':' . branchname<CR>| " git:branch 检出一个远程分支到本地

" 拉取最新变更
nnoremap <silent> <leader>gpl :execute 'Git pull'<CR>| " git: 拉取最新的变更
" 推送当前更改(当前本地分支)
nnoremap <silent> <leader>gps :let branchname=system('git rev-parse --abbrev-ref HEAD') \| execute 'Git push --set-upstream origin ' . trim(branchname)<CR>| " git: 推送当前本地分支到远端

" 查看当前文件的所有提交历史
nnoremap <silent> <leader>gog :0Gclog<cr> | " git: 查看当前文件相关的所有提交历史记录

" 标签管理
nnoremap <leader>gta :execute 'Git tag -a <tag-name> ' . getreg('a') .  ' -m "标注信息"'| " git:tags 基于某个提交创建一个标签
nnoremap <silent> <leader>gtsl :execute 'normal "xyiw' \| execute 'Git show ' . getreg('x')<CR>| " git:tags 显示某个标签明细
nnoremap <silent> <leader>gtl :execute 'Git tag -l'<CR>| " git:tags 列出所有的本地标签

nnoremap <silent> <leader>gtxl :execute 'normal "xyiw' \| execute 'Git tag -d ' . getreg('x') \| close<CR>| " git:tags 删除一个本地标签
vnoremap <silent> <leader>gtxl y:execute 'Git tag -d ' . shellescape(@0) \| close<CR>| " git:tags 删除一个本地标签

nnoremap <silent> <leader>gtp :execute 'normal "xyiw' \| execute 'Git push --set-upstream origin ' . getreg('x')<CR>| " git:tags 推送某个标签到远程服务器(x寄存器中存储了内容)

nnoremap <silent> <leader>gtr :execute 'Git fetch --prune --tags' \| terminal Git ls-remote --tags<CR>| " git:tags 列出所有的远程标签
function! GetLineContentLast ()
    " 获取当前行的内容
    let line = getline('.')
    " 使用空格分割行内容
    let fields = split(line)
    " 返回最后一个域的内容
    return fields[-1]
endfunction
nnoremap <silent> <leader>gtxr :execute 'Git push origin :' . GetLineContentLast() \| close<CR>| " git:tags 删除某一个远程标签



" vim-fugitive 插件按键绑定 }

" " vim-markbar 插件配置 {
" " this is required for mark names to persist between editor sessions
" if has('nvim')
"     set shada+=!
" else
"     set viminfo+=!
" endif

" nmap <Leader>m <Plug>ToggleMarkbar

" " the following are unneeded if ToggleMarkbar is mapped
" nmap <Leader>mo <Plug>OpenMarkbar
" nmap <Leader>mc <Plug>CloseMarkbar
" nmap <Leader>www <Plug>WriteMarkbarRosters
" let g:markbar_print_time_on_shada_io = v:true


" " vim-markbar 插件配置 }


" tabular 对齐插件配置区域 {
vnoremap <silent> <leader>tb<Space> :Tabularize / \+<cr>
vnoremap <silent> <leader>tb= :Tabularize /=<cr>
vnoremap <silent> <leader>tb: :Tabularize /:<cr>
vnoremap <silent> <leader>tb-> :Tabularize /-><cr>
vnoremap <silent> <leader>tb=> :Tabularize /=><cr>

" tabular 对齐插件配置区域 }


" markdown-preview 插件配置 {
" let g:mkdp_markdown_css = $VIM . '\github-markdown-light.css'
let g:mkdp_markdown_css = expand('~/.vim/markdown/github-markdown-light.css')
" markdown-preview 插件配置 }

" let g:lightline.colorscheme='catppuccin_mocha'

" vim-highlighter 配置 {

" 这里最好不要直接用<CR>会覆盖掉一些重要的默认按键映射
nnoremap <C-CR>  <Cmd>Hi><CR>| " 高亮: 当前高亮的下一个
nnoremap <C-S-CR>  <Cmd>Hi<<CR>| " 高亮: 当前高亮的上一个
nnoremap <M-CR> <Cmd>Hi}<CR>| " 高亮: 所有高亮的下一个
nnoremap <M-S-CR> <Cmd>Hi{<CR>| " 高亮: 所有高亮的上一个

" vim-highlighter 配置 }

" 插件配置 }


" 这个语句需要最后执行，说出暂时放在配置文件的最后，给markdown/zimwiki文件加上目录序号
" :TODO: 因为保存的时候的效率问题，暂时先屏蔽掉
" autocmd BufWritePost *.md silent call GenSectionNum('markdown')
" autocmd BufWritePost *.txt silent call GenSectionNum('zim')
noremap <leader>gsnm :silent call GenSectionNum('markdown')<cr>| " markdown: markdown生成数字目录序号
noremap <leader>gsnz :silent call GenSectionNum('zim')<cr>| " zim: zim生成数字目录序号

" 替换函数快捷方式,和<leader>r和NERDTree刷新快捷键冲突
noremap <leader><leader>r :call MyReplaceWord('n')<CR>| " 替换: 普通模式替换当前单词
vnoremap <leader>r :call MyReplaceWord('v')<CR>| " 替换: 可视模式替换当前单词
vnoremap <leader><leader>r :call VisualReplaceWord()<CR>| " 替换: 可视模式替换选择区域复制的单词为新单词

nnoremap <leader>br :call AddBufferBr()<CR>

" 打开git远端上的分支
" nnoremap <silent> <leader>git :call GitGetCurrentBranchRemoteUrl()<CR>| " git: 通过浏览器打开git上对应当前本地分支的远端分支

nnoremap <leader><F9> :call DisplayHTML()<CR>| " 文件: 浏览器中打开当前编辑的html文件

" 针对特种文件格式的自定义补全 {
" 暂时未验证是否和coc或者completor冲突
" 加载补全全局列表 g:complete_list
function! CustomCompleteList()
    source $VIM/complete_list_all.vim
    let g:word_to_complete = {}
    let g:complete_list = []
    if &filetype == 'zim' || &filetype == 'txt'
        source $VIM/complete_list_zim.vim
    elseif &filetype == 'python'
        source $VIM/complete_list_python.vim
    elseif &filetype == 'sh'
        source $VIM/complete_list_sh.vim
    endif

    if !empty(g:complete_list)
        let g:complete_list_all += g:complete_list
    endif

    let g:word_to_complete = extend(copy(g:word_to_complete_all), g:word_to_complete)

endfunction

" 这里多调用一次是因为如果重新加载vimrc,希望能生效
call CustomCompleteList()
autocmd filetype * call CustomCompleteList()

function! OmniCompleteCustom(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        " 检查是否是一个字母,如果是字母开始补全(\a只能匹配ascii \S可以匹配中文字符)
        while start > 0 && line[start - 1] =~ '\S'
            let start -= 1
        endwhile
        return start
    else
        " find matches for a:base
        let res = []
        " h complete-functions
        " word: 补全的单词(无法多行,但是可以自己转换)
        " abbr: 补全菜单中显示的缩写
        " menu: 补全菜单中显示的额外信息(我加个*表示这项含有info预览信息 -表示没有)
        " info: 在预览窗口中显示的详细信息(如果有信息要至少包含一个换行符)
        " kind: 补全的类型
        " icase: 如果设置为1忽略大小写(需要后面的函数处理,否则无用)
        " dup: 如果设置为1标识允许添加重复项(只要word相同就能添加)(需要后面的代码处理否则没有作用)
        " :TODO: 这个变量移动到单独的字典文件中,然后每个语言一个文件,在vimrc中source进来(不是对应文件的字典清空,节省内存,要考虑字典文件的内存使用问题)
        " 还需要看下内存xnhc
        for item in g:complete_list_all
            " 匹配不区分大小写
            " 据说matchstr效率更高?
            " if item['word'] =~ '\c^' . a:base
            let pattern = item['icase'] ? '\c' . a:base : '\C' . a:base
            if item['word'] =~ pattern
                " if matchstr(item['word'], pattern) != ''
                let item_copy = copy(item)

                if has_key(g:word_to_complete, item_copy['word'])
                    let item_copy['word'] = g:word_to_complete[item_copy['word']]
                endif

                if item_copy['kind'] == 'ic' || item_copy['kind'] == 'if'
                    let item_copy['word'] = eval(item_copy['word'])
                endif
                " add more information to the completion menu
                call add(res, item_copy)
            endif
        endfor
        return res
    endif
endfunction

" 设置默认的用户自定义补全函数
set completefunc=OmniCompleteCustom

" 在补全时显示弹出窗口
" :TODO: 补全的弹出窗口如果在别的文字上面显示会出现闪烁现象,需要定位下
function! CompleteShowPopup(item)
    " 如果已经存在弹出窗口，先关闭它,这里之所以要用双引号是因为这里要检查的是以双引号引起来的字符串的名字作为变量名的变量是否存在,所以这里单引号也是可以的
    if exists("s:winid")
        call popup_close(s:winid)
    endif

    if(!empty(v:completed_item) && !empty(a:item['info']))
        " :help popup_create()
        let popup_width_str = a:item['abbr'] . ' ' . a:item['kind'] . ' ' . a:item['menu']
        let word_len = strchars(a:item['word']) + strchars(substitute(a:item['word'], '[^\u4E00-\u9FCC]', '', 'g'))
        let list_len = strchars(popup_width_str) + strchars(substitute(popup_width_str, '[^\u4E00-\u9FCC]', '', 'g'))
        let width = list_len - word_len

        let opts = { 'line': 'cursor+1',
                    \'col': (width<0)?'cursor' . width:'cursor' . '+' . width,
                    \ 'padding': [0,1,0,1],
                    \ 'wrap': v:true,
                    \ 'border': [],
                    \ 'close': 'click',
                    \ 'highlight': 'Pmenu',
                    \ 'zindex': 100}
        let s:winid = popup_create(split(a:item['info'], '\n'), opts)
    endif
endfunction

" 当补全项改变时，显示弹出窗口
autocmd CompleteChanged * call CompleteShowPopup(v:completed_item)
" 当退出插入模式时，关闭弹出窗口
" :TODO: 这里甚至可以执行特定的回调，回调的位置可以想办法指定
autocmd InsertLeave * if exists("s:winid") | call popup_close(s:winid) | endif
" 当补全完成时，关闭弹出窗口
autocmd CompleteDone * if exists("s:winid") | call popup_close(s:winid) | endif
autocmd CompleteDone * .s/\%x00/\r/ge
" 替换文本中的^@为换行
nnoremap <leader>rca :%s/\%x00/\r/g<cr>| " 编辑: 普通模式替换文本中的^@为换行
vnoremap <leader>rca :s/\%x00/\r/g<cr>| " 编辑: 可视模式替换文本中的^@为换行

" :TODO: 后面可以支持跨字母匹配,比如 wind  输入wd,匹配它

" 针对特种文件格式的自定义补全 }
function! RemoveLastChar(str)
    if len(a:str) > 0
        let l:width = strchars(a:str) - 1
        let l:result = strcharpart(a:str, 0, l:width)
        return l:result
    else
        return a:str
    endif
endfunction

" 按键补全帮助窗口 {

let g:help_popup_highlight_colors = ['red', 'DarkGreen', 'DarkCyan', 'DarkMagenta', 'green']


" 定义空格的高亮组

hi HelpPopupKeywordHighLightBlank ctermfg=red guifg=white guibg=black
if index(prop_type_list(), 'HelpPopupKeywordHighLightBlank') == -1
    call prop_type_add('HelpPopupKeywordHighLightBlank', {'highlight': 'HelpPopupKeywordHighLightBlank'})
endif


for i in range(len(g:help_popup_highlight_colors))
    let highlight_group = 'HelpPopupKeywordHighLight' . i
    execute 'hi ' . highlight_group . ' ctermfg=' . g:help_popup_highlight_colors[i] . ' guifg=' . g:help_popup_highlight_colors[i]
    if index(prop_type_list(), highlight_group) == -1
        call prop_type_add(highlight_group, {'highlight': highlight_group})
    endif
endfor

let g:help_win_text_prop_id = 1
function! PopupMenuShowKeyBindings(search_mode, exec_mode, exec_cmd)
    " ! 开头的命令表示外部名 : 开头表示执行函数 其它表示执行vim内部表达式
    if a:exec_mode == 'auto'
        let user_command = a:exec_cmd
    elseif a:exec_mode == 'manu'
        let user_command = input('请输入一个命令:', '', 'command')
    endif

    " :TODO: 当前特殊情况太多了,函数需要重构
    if a:exec_mode != ''
        if user_command == 'get_vimrc_content'
            let data_list = readfile($MYVIMRC)
        elseif user_command == 'get_initel_content'
            let data_list = readfile('E:\code\emacs\emacs_config\init.el')
        elseif user_command == ':SortMarks'
            let data_list = eval(user_command[1:] . '()')
        else
            let user_command_str = ''
            try
                if user_command[0] == '!'
                    let user_command_str = system(user_command[1:])
                elseif user_command[0] == ':'
                    let user_command_str = eval(user_command[1:] . '()')
                else
                    redir => user_command_str
                    silent execute user_command
                    redir END
                endif
            catch
                let user_command_str = "null"
                echoerr "执行的命令无效: " . v:exception
            endtry

            let user_command_utf8 = iconv(user_command_str, &encoding, 'utf-8')
            let data_list = split(user_command_utf8, '\n')
        endif
    else
        let data_list = g:key_binding_list
    endif


    let opts = { 'line': 'cursor',
        \ 'col': 'cursor',
        \ 'padding': [0,1,0,1],
        \ 'wrap': v:true,
        \ 'border': [],
        \ 'close': 'button',
        \ 'highlight': 'Pmenu',
        \ 'resize': 1,
        \ 'zindex': 100,
        \ 'maxheight': 20,
        \ 'maxwidth': 80,
        \ 'title': 'tips',
        \ 'dragall': 1}
    let help_win = popup_create([''], opts)
    let help_win_nr = winbufnr(help_win)

    let input_str = ''
    while 1
        let c = getchar()
        if c == 27
            call popup_close(help_win)
            break
        elseif c == 9
            call GetAllInfoInPopupWin(0)
            break
        elseif c == "\<BS>"
            let input_str = RemoveLastChar(input_str)
        elseif c == 13
            let input_str = ''
        elseif c != 0
            let input_str .= nr2char(c)
        endif

        let keyword_match = []
        let text_property_list = []
        let first_line_text_property = []
        if(!empty(input_str))
            let match_line_cnt = 1
            let is_first_line = 1
            for item in ['{' . help_win . '} ' . input_str] + data_list
                let popup_str_in_bool = 0
                let fit_bool = (a:search_mode == 'and')? 1 : 0
                for sub_str in split(input_str, '\s\+')
                    if (a:search_mode == 'and' && item !~ '\c' . sub_str) || (a:search_mode == 'or' && item =~ '\c' . sub_str)
                        let fit_bool = 1 - fit_bool
                        break
                    endif
                endfor

                " :TODO: 这里可以优化性能,写一个总的正则,不用一个单词一个单词去匹配
                for sub_item in split(item, '\n')
                    if fit_bool
                        if !popup_str_in_bool
                            call extend(keyword_match, split(item, '\n'))
                        endif
                        if is_first_line
                            let start = 0
                            while 1
                                let match_str = matchstrpos(sub_item, '\s\+', start)
                                if match_str[0] == ''
                                    break
                                endif

                                let start = match_str[2]
                                call add(first_line_text_property, [1, match_str[1]+1, match_str[2] - match_str[1], 'HelpPopupKeywordHighLightBlank'])
                            endwhile
                            let is_first_line = 0
                        endif

                        " 循环高亮组
                        let highlight_cnt = 0
                        for input_str_regex in split(input_str, '\s\+')
                            let start = 0
                            while 1
                                let match_str = matchstrpos(sub_item, '\c' . input_str_regex, start)
                                if match_str[0] == ''
                                    break
                                endif

                                let start = match_str[2]
                                call add(text_property_list, [match_line_cnt, match_str[1]+1, match_str[2]-match_str[1], highlight_cnt % len(g:help_popup_highlight_colors)])
                            endwhile
                            let highlight_cnt += 1
                        endfor
                        let popup_str_in_bool = 1
                    endif
                    let match_line_cnt += 1
                endfor
                if !popup_str_in_bool
                    let match_line_cnt -= len(split(item, '\n'))
                endif
            endfor
        endif

        if (c != "\<Up>" && c != "\<Down>")
            call popup_settext(help_win, keyword_match)
            if !empty(text_property_list)
                for text_property in text_property_list
                    call prop_add(text_property[0], text_property[1], {'type': 'HelpPopupKeywordHighLight' . text_property[3], 'length': text_property[2], 'bufnr': help_win_nr, 'id': g:help_win_text_prop_id})
                endfor
            endif

            if !empty(first_line_text_property)
                for text_property in first_line_text_property
                    call prop_add(text_property[0], text_property[1], {'type': text_property[3], 'length': text_property[2], 'bufnr': help_win_nr, 'id': g:help_win_text_prop_id})
                endfor
            endif
        else
            let firstline = get(popup_getoptions(help_win), 'firstline', 1)
            if c == "\<Up>" && firstline > 1
                call popup_setoptions(help_win, #{ firstline: firstline - 1})
            elseif c == "\<Down>"
                call popup_setoptions(help_win, #{firstline: firstline + 1})
            endif
        endif

        redraw
    endwhile
endfunction

" 一个简单的弹出窗口只是为了用户帮助信息(只显示信息不获取焦点,屏幕右上角)
function! ShowPopup(contentList)
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

source $VIM/keybinding_help.vim
" :TODO: 如果列表中只有一个元素，可能再增加一个弹窗显示详情
" :TODO: 可以支持类似fzf的模糊搜 索功能
" :TODO: 滚轮键只有在固定的时候可以使用，可以再处理下PgUp和PgDn
" 如果要搜 索所有的，输入.点号即可

" :TODO: 增加获取某个文件的行的后几行功能,用于查看_vimrc的注释信息和实际配置信息
nnoremap <silent> <leader><leader>psba :call PopupMenuShowKeyBindings('and', '', '')<cr>| " 辅助: 在自定义的列表中查找关键字,与的关系
nnoremap <silent> <leader><leader>psbo :call PopupMenuShowKeyBindings('or', '', '')<cr>| " 辅助: 在自定义的列表中查找关键字,或的关系
nnoremap <silent> <leader><leader>psbma :call PopupMenuShowKeyBindings('and', 'auto', 'map')<cr>| " 辅助: 在map命令中查找关键字,与的关系
nnoremap <silent> <leader><leader>psbmo :call PopupMenuShowKeyBindings('or', 'auto', 'map')<cr>| " 辅助: 在map命令中查找关键字,或的关系
nnoremap <silent> <leader><leader>psbva :call PopupMenuShowKeyBindings('and', 'auto', 'get_vimrc_content')<cr>| " 辅助: 在vimrc配置文件中查找关键字,与的关系
nnoremap <silent> <leader><leader>psbea :call PopupMenuShowKeyBindings('and', 'auto', 'get_initel_content')<cr>| " 辅助: 在emacs配置文件中查找关键字,与的关系

" 输入命令 marks 可以显示当前所有的标记
nnoremap <silent> <leader><leader>cm :call PopupMenuShowKeyBindings('and', 'manu', '')<cr>| " 辅助: 弹出窗口中显示所有的标记marks

nnoremap <leader>cpw :call popup_close(| " 辅助: 关闭某一个弹出窗口(传入窗口ID)
nnoremap <leader>cpwa :call popup_clear()<cr>| " 辅助: 关闭与清除所有的弹出窗口

function! GetAllInfoInPopupWin(paste_flag)
    let all_popup_win_list = popup_list()
    if all_popup_win_list != []
        let first_register = 1
        for winid in all_popup_win_list
            let bufnr = winbufnr(winid)
            let lines = getbufline(bufnr, 2, '$')
            if first_register
                let @a = join(lines, "\n") . "\n"
                let first_register = 0
            else
                let @A = join(lines, "\n") . "\n"
            endif
        endfor
        let @" = @a
        let @+ = @a

        if a:paste_flag
            normal! p
        endif
    endif

endfunction

" " 目前插件官方已经修复了这个BUG,这里屏蔽 {
" " vim9-stargate插件的bug修复

" function! ClearAllNotTipsPopupWin()
"     let all_popup_win_list = popup_list()
"     if all_popup_win_list != []
"         for winid in all_popup_win_list
"             if get(popup_getoptions(winid), "title", "") != "tips"
"                 call popup_close(winid)
"             endif
"         endfor
"     endif

" endfunction
" autocmd TabLeave * call ClearAllNotTipsPopupWin()
" " 目前插件官方已经修复了这个BUG,这里屏蔽 }


nnoremap <silent> <leader>ypw :call GetAllInfoInPopupWin(0)<cr>| " 辅助: 拷贝当前弹出窗口中的所有内容
nnoremap <silent> <leader>ypwp :call GetAllInfoInPopupWin(1)<cr>| " 辅助: 粘贴当前弹出窗口中的所有内容


" 按键补全帮助窗口 }



nnoremap <c-;> <Cmd>call stargate#OKvim('\<')<cr>| " 跳转: 跳转到某一个关键字
nnoremap <c-s-:> <Cmd>call stargate#Galaxy()<cr>| " 跳转: 跳转到某一个窗口



" :TODO: vim脚本超过80列自动换行,设置了下面的配置也无用
" :TODO: 这个设置无效会被覆盖需要定位
set textwidth=0
" 用这一行规避上面的问题
autocmd filetype * set textwidth=0

" :TODO: 所有需要映射的文件用一个windows下的批处理脚本来处理
" :TODO: 目前不确定我自定义的补全是否会和coc还有completor的补全相冲突

" :TODO: 自己写一个插件,在弹出窗口中显示小写字母标记和大写字母标记[marker]的上下文,并且自动更新,可以手动切换这个弹出窗口的显示与关闭,最好是还可以重命令,并且可以持久化保存弹出窗口中的名字相关的映射,这样下次打开还能使用
" :TODO: 待实现标记窗口的上下文
" 利用弹出窗口自己设计的标记系统 {
" 标记的格式
" 标记 行 列 文件/文本
function! SortMarks()
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
            let l:comment = get(g:global_mark_comments, l:mark, '')
        else
            let l:comment = get(b:file_mark_comments, l:mark, '')
        endif

        let l:comment = printf('%-10s', l:comment)
        call insert(l:line, l:comment, 1)
    endfor
    call sort(l:lines, 'SortByLine')

    " return join(map(copy(l:lines), 'join(v:val, " ")'), "\n")
    return map(copy(l:lines), 'join(v:val, " ")')
endfunction

function! SortByLine(mark1, mark2)
    return a:mark1[1] - a:mark2[1]
endfunction

" timer的实现 {
" " vim中执行异步的命令并且在弹出窗口中动态显示出来(用于监控一些重要信息)
" let s:timer = -1

" function! StartTimer()
"     if s:timer != -1
"         call timer_stop(s:timer)
"     endif

"     " 创建一个空的弹出窗口
"     let opts = { 'line': 'cursor',
"         \ 'col': 'cursor',
"         \ 'padding': [0,1,0,1],
"         \ 'wrap': v:true,
"         \ 'border': [],
"         \ 'close': 'none',
"         \ 'highlight': 'Pmenu',
"         \ 'resize': 1,
"         \ 'zindex': 100,
"         \ 'maxheight': 20,
"         \ 'maxwidth': 80,
"         \ 'title': 'tips',
"         \ 'dragall': 1}
"     let s:dynamic_content_win = popup_create([''], opts)

"     let s:timer = timer_start(1000, 'UploadDynamicPopupWin', {'repeat': -1})
" endfunction

" function! StopTimer()
"     if s:timer != -1
"         call timer_stop(s:timer)
"         let s:timer = -1
"         " if exists(s:dynamic_content_win) && !empty(popup_findinfo(s:dynamic_content_win))
"         call popup_close(s:dynamic_content_win)
"         " endif
"     endif
" endfunction

" function! UploadDynamicPopupWin(timer_id)
"     let dynamic_info_list = SortMarks()
"     " if exists(s:dynamic_content_win) && !empty(popup_findinfo(s:dynamic_content_win))
"     call popup_settext(s:dynamic_content_win, dynamic_info_list)
"     " endif
" endfunction

" nnoremap <silent> <leader>smt :call StartTimer()<cr>| " 辅助: 动态显示当前文件所有marks标记
" nnoremap <silent> <leader>tmt :call StopTimer()<cr>| " 辅助: 关闭显示当前文件所有marks标记
" " 为了避免麻烦,在切换标签页前关闭
" " :TODO: 可以考虑给字母标记加注释,注释的内容可以持久化,并方便更新,字母标记也可以持久化
" autocmd BufLeave * call StopTimer()
" timer的实现 }

" Autocmd的实现 {
function! StartAutoCmd()
    if !exists("b:dynamic_content_win")
        let b:dynamic_content_win = -1
    endif
    " 如果前面已经有一个需要先关闭
    call StopPopUpAutoCmd()

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
    let b:dynamic_content_win = popup_create([''], opts)

    " " 设置autocmd事件
    " augroup DynamicPopup
    "     autocmd!
    "     autocmd CursorMoved * call UploadDynamicPopupWin()
    " augroup END

    " 手动打开
    call UploadDynamicPopupWin()

endfunction

function! StopPopUpAutoCmd()
    " " 清除autocmd事件
    " augroup DynamicPopup
    "     autocmd!
    " augroup END

    " 关闭弹出窗口
    if !exists("b:dynamic_content_win")
        let b:dynamic_content_win = -1
    endif
    if b:dynamic_content_win != -1
        call popup_close(b:dynamic_content_win)
        let b:dynamic_content_win = -1
    endif
endfunction

function! UploadDynamicPopupWin()
    if !exists("b:dynamic_content_win")
        let b:dynamic_content_win = -1
    endif
    if b:dynamic_content_win != -1
        let dynamic_info_list = SortMarks()
        call popup_settext(b:dynamic_content_win, dynamic_info_list)
    endif
endfunction

" show marks
nnoremap <silent> <leader>smt :call StartAutoCmd()<cr>| " 辅助: 显示当前文件所有marks标记
nnoremap <silent> <leader>smx :call StopPopUpAutoCmd()<cr>| " 辅助: 关闭显示当前文件所有marks标记
nnoremap <silent> <leader>smu :call UploadDynamicPopupWin()<cr>| " 辅助: 更新显示当前文件所有marks标记
autocmd BufEnter * if &buftype == '' | call UploadDynamicPopupWin()| " 辅助: 进入buffer的时候更新标记

" 一键清除所有的小写和大写字母标记
nnoremap <silent> <leader>smd :call DeleteMarks(join(map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)'), ' '))<cr>| " 辅助: 删除当前文件中所有的小写字母 marks 标记
nnoremap <silent> <leader>smD :call DeleteMarks(join(map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)'), ' '))<cr>| " 辅助: 删除当前文件中所有的大写字母 marks 标记
function! UpdateMarks(type)
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
    call UploadDynamicPopupWin()
endfunction

nnoremap <silent> <leader>smn :call UpdateMarks('n')<cr>| " 辅助: 添加下一个小写字母 marks 标记
nnoremap <silent> <leader>smN :call UpdateMarks('N')<cr>| " 辅助: 添加下一个大写字母 marks 标记
" 定义添加标记并调用自定义函数的函数
function! AddOrRemoveMark(mark)
    let lnum = line('.')
    let col = col('.')
    let pos = getpos("'" . a:mark)[1]
    execute 'delmarks ' . a:mark
    " 删除标记的同时也删除它的注释
    call DeleteMarkComment(a:mark)
    if pos != lnum
        call setpos("'" . a:mark, [0, lnum, col, 0])
    endif
    call UploadDynamicPopupWin()
endfunction

function! EnableMarkMappings()
    for char in range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z'))
        execute 'nnoremap <silent> m' . nr2char(char) . ' :call AddOrRemoveMark("' . nr2char(char) . '")<CR>'
    endfor
endfunction

function! DisableMarkMappings()
    for char in range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z'))
        execute 'nunmap m' . nr2char(char)
    endfor
endfunction

" :TODO: 当前配置中自动命令太多了,屏蔽m快捷键映射和NERD_tree的相关操作,也许还有更好的实现方式
autocmd BufEnter * if ! bufname('%') =~ 'NERD_tree' | call EnableMarkMappings() | endif
autocmd BufEnter * if bufname('%') =~ 'NERD_tree' | call DisableMarkMappings() | endif

function! DeleteMarks(marks)
    let l:marks = split(a:marks)
    for mark in l:marks
        execute 'delmarks' mark
        " 删除标记的同时也删除它的注释
        call DeleteMarkComment(mark)
    endfor
    call UploadDynamicPopupWin()
endfunction

" 手动删除某个(某些)标记
nnoremap <silent> <leader>sdm :call DeleteMarks(input('Enter marks to delete (space-separated): '))<CR>| " 辅助: 手动删除一个标记列表



let g:global_mark_comments = {}
let g:global_mark_comments_file_path = ''

" 加载全局标记注释
function! LoadGlobalMarkComments()
    " 如果当前viminfo并不是默认的,那么全局注释文件也需要更换
    let g:global_mark_comments_file_path = expand('~/.vim/mark_comments/' . fnamemodify(g:viminfo_file_path, ':t') . 'global_mark_comments_')

    echom g:global_mark_comments_file_path

    if filereadable(g:global_mark_comments_file_path)
        let g:global_mark_comments = eval(join(readfile(g:global_mark_comments_file_path), "\n"))
    endif
endfunction

" 保存全局标记注释
function! SaveGlobalMarkComments()
    let l:dirpath = expand('~/.vim/mark_comments/')
    let l:filepath = expand(l:dirpath . 'global_mark_comments')
    " 检查并创建目录
    if !isdirectory(l:dirpath)
        call mkdir(l:dirpath, 'p')
    endif

    if empty(g:global_mark_comments)
        if filereadable(g:global_mark_comments_file_path)
            call delete(g:global_mark_comments_file_path)
        endif
    else
        call writefile(split(string(g:global_mark_comments), "\n"), g:global_mark_comments_file_path)
    endif
endfunction

" 加载文件标记注释
function! LoadFileMarkComments()
    let l:filepath = expand('%:p')
    let l:comment_file = substitute(l:filepath, '[\\/:]', '-', 'g')
    let l:file_name = expand('~/.vim/mark_comments/' . l:comment_file . '_mark_comments')
    if filereadable(l:file_name)
        let b:file_mark_comments = eval(join(readfile(l:file_name), "\n"))
    else
        let b:file_mark_comments = {}
    endif
endfunction

" 保存文件标记注释
function! SaveFileMarkComments()
    let l:filepath = expand('%:p')
    let l:comment_file = substitute(l:filepath, '[\\/:]', '-', 'g')
    let l:dirpath = expand('~/.vim/mark_comments/')
    if !isdirectory(l:dirpath)
        call mkdir(l:dirpath, 'p')
    endif

    let l:file_name = expand(l:dirpath . l:comment_file . '_mark_comments')
    if empty(b:file_mark_comments)
        if filereadable(l:file_name)
            call delete(l:file_name)
        endif
    else
        call writefile(split(string(b:file_mark_comments), "\n"), l:file_name)
    endif
endfunction

" 添加标记注释
function! AddMarkComment(mark, comment)
    if a:mark =~# '[A-Z]'
        let g:global_mark_comments[a:mark] = a:comment
    else
        let b:file_mark_comments[a:mark] = a:comment
    endif
    call UploadDynamicPopupWin()
endfunction

" 删除标记注释
function! DeleteMarkComment(mark)
    if a:mark =~# '[A-Z]'
        if has_key(g:global_mark_comments, a:mark)
            call remove(g:global_mark_comments, a:mark)
        endif
    else
        if has_key(b:file_mark_comments, a:mark)
            call remove(b:file_mark_comments, a:mark)
        endif
    endif
    call UploadDynamicPopupWin()
endfunction

" 在Vim退出时保存全局标记注释(:TODO:这里要判断下是不是最后一个实例,只有最后一个实例才能保存)
autocmd VimLeavePre * call SaveGlobalMarkComments()
" 在进入buffer时加载文件标记注释
autocmd BufEnter * if &buftype == '' | call LoadFileMarkComments() | endif

" 在离开buffer时保存文件标记注释
autocmd BufLeave * if &buftype == '' | call SaveFileMarkComments() | endif
" 在Vim退出之前保存所有文件标记注释
autocmd VimLeavePre * call SaveFileMarkComments()

" " 在标签页切换时保存和加载文件标记注释
" autocmd TabLeave * call SaveFileMarkComments()
" autocmd TabEnter * call LoadFileMarkComments()

" 示例映射：添加标记注释
nnoremap <silent> <leader>ama :call AddMarkComment(input('Mark: '), input('Comment: '))<CR>| " 辅助: 添加某一个标记注释
" 示例映射：删除标记注释
nnoremap <silent> <leader>amx :call DeleteMarkComment(input('Mark: '))<CR>| " 辅助: 删除某一个标记注释



" autocmd BufLeave * call StopPopUpAutoCmd()
" Autocmd的实现 }


" show marks
nnoremap <silent> <leader><leader>sm :call PopupMenuShowKeyBindings('and', 'auto', ':SortMarks')<cr>| " 辅助: 静态显示当前文件所有marks标记

" 利用弹出窗口自己设计的标记系统 }
" :TODO: 下面这个通过emacs打开后继承的环境变量有点问题,导致ggtags相关的路径错乱,可能是因为两个程序都定义了gtags相关的东西
function! OpenInEmacs()
    let l:line_number = line(".")
    let l:file_path = expand("%:p")
    let l:command = "start emacsclientw +" . l:line_number . " " . l:file_path
    call system(l:command)
endfunction

nnoremap <leader>oe :call OpenInEmacs()<CR>| " 辅助: 使用emacs打开当前文件当前行

nnoremap <silent> v :let g:saved_cursor_pos = getpos('.')<CR>v
nnoremap <silent> V :let g:saved_cursor_pos = getpos('.')<CR>V
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

        if g:saved_cursor_pos[1] == l:start_pos[1]
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

    call cursor(g:saved_cursor_pos[1], g:saved_cursor_pos[2] + l:offset)
endfunction

" 创建新的命令，S)，来调用这个函数
vnoremap <silent> S( :call SurroundWith('()', visualmode(), ' ')<CR>| " 编辑: 小括号包围有空格
" 创建新的命令，S}，来调用这个函数
vnoremap <silent> S{ :call SurroundWith('{}', visualmode(), ' ')<CR>| " 编辑: 大括号包围有空格
" 创建新的命令，$)，来调用这个函数
vnoremap <silent> S) :call SurroundWith('()', visualmode(), '')<CR>| " 编辑: 小括号包围无空格
" 创建新的命令，$}，来调用这个函数
vnoremap <silent> S} :call SurroundWith('{}', visualmode(), '')<CR>| " 编辑: 大括号包围无空格

" 增加映射手动重置当前的viminfo
nnoremap <leader>svm :call SaveGlobalMarkComments()<cr> \| :call SetProjectViminfo()<cr>| " 辅助: 重置当前环境的viminfo(切换新项目时)

" 定义一个自定义高亮组(这个只能放最后不然会被主题覆盖)
highlight MyVirtualText ctermfg=LightGray guifg=#D3D3D3 ctermbg=NONE guibg=NONE

" 自定义的图形
" 图形大类别索引

function! SwitchSmartDrawLev1Index(direction)
    if a:direction == 1
        let g:SmartDrawShapes['set_index'] = (g:SmartDrawShapes['set_index']+1) % len(g:SmartDrawShapes['value'])
    else
        let g:SmartDrawShapes['set_index'] = (g:SmartDrawShapes['set_index']-1 + len(g:SmartDrawShapes['value'])) % len(g:SmartDrawShapes['value'])
    endif

    call UpdateSmartDrawLev2Info()
    call UpdateVisualBlockPopup()
endfunction

function! SwitchSmartDrawLev2Index(direction)
    let step = g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['step'][g:switch_smart_draw_lev2_step_index] * a:direction

    " 如果index是数组,那么极限值是数组第一个元素,否则是'value'中的元素个数
    if type(g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index']) == type([])
        let size_count = g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'][0]
        if a:direction == 1
            let g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'][1] = (g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'][1]+step) % size_count
        elseif a:direction == -1
            let g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'][1] = (g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'][1]+step+size_count) % size_count

        endif
    else
        let size_count = len(g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['value'])
        if a:direction == 1
            let g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'] = (g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index']+step) % size_count
        elseif a:direction == -1
            let g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index'] = (g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index']+step+size_count) % size_count
        endif
    endif

    call UpdateSmartDrawLev2Info()
    call UpdateVisualBlockPopup()
endfunction


" 'index': 函数集索引
" '[0, 0, 0]': 函数集中每个大类的小类的索引
" 0: 函数集中大类的索引
" :TODO: 后面这个数组可以和具体的定义文件彻底解耦,数组的元素个数要根据文件中的内容自动创建
" 这里不设置为-1是因为基本图形组比较多担心影响启动速度,所以设置为最后一个组
let g:DefineSmartDrawGraphFunctions = {
    \ 'index': 1,
    \ 'value': [
    \ ['DefineSmartDrawShapesBasic', [0, [60, 0], [60, 0], [60, 0], [60, 0], [600, 0], [600, 0], 0, 0, [600, 0], 0, [40, 0], 0, 0], 0, 'basic.vim'],
    \ ['DefineSmartDrawShapesLed', [0], 0, 'led.vim'],
    \ ['DefineSmartDrawShapesFiglet', [0, 0, 0, 0, 0, 0], 0, 'figlet.vim']
    \ ]
    \ }

" 如果lev2_index是一个数组 [300, 124],证明当前图形由函数动态生成,不可直接取数组元素,而是需要调用函数
" 第一个值是函数生成图形的极限,第二个值是当前的索引
" 函数的参数逻辑
" 如果 step为1号元素为1,那么函数只需要一个参数
"                     2,那么函数需要两个参数(宽和高)
function! UpdateSmartDrawLev2Info()
    " 更新x寄存器中的内容
    let lev2_index = g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['index']
    let step_arr = g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['step']
    if type(lev2_index) == type([])
        let func_name = g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['value']

        if step_arr[1] == 1
            let func_param = lev2_index[1]
            let @+ = join(call(func_name, [func_param]), "\n")
        else
            let func_param_row = lev2_index[1] / step_arr[1] + 1
            let func_param_col = lev2_index[1] % step_arr[1]
            let @+ = join(call(func_name, [func_param_row, func_param_col]), "\n")
        endif
    else
        let @+ = join(g:SmartDrawShapes['value'][g:SmartDrawShapes['set_index']]['value'][lev2_index], "\n")
    endif
endfunction


function! LoadAndUseCustomDrawSetFunctions(func_name, indexes, index, file_name)
    let file_path = expand('$VIM/draw_shaps/' . a:file_name)
    execute 'source' file_path

    " 调用函数
    let result = call(a:func_name, [a:indexes, a:index])

    " 全局变量已经加载后删除函数定义
    " 这里删除函数的目的是节省内存(因为函数初始化的局部变量中有可能包含大量字符串)
    execute 'delfunction!' a:func_name
endfunction

function! SwitchDefineSmartDrawGraphSet(is_show)
    " " 记录开始时间
    " let l:start_time = reltime()

    " 首先记录所有小类的index
    if exists('g:SmartDrawShapes')
        let old_index = g:DefineSmartDrawGraphFunctions['index']
        for i in range(len(g:DefineSmartDrawGraphFunctions['value'][old_index][1]))
            let g:DefineSmartDrawGraphFunctions['value'][old_index][1][i] = copy(g:SmartDrawShapes['value'][i]['index'])
        endfor
        
        " 记录大类的index
        let g:DefineSmartDrawGraphFunctions['value'][old_index][2] = g:SmartDrawShapes['set_index']
    endif

    let g:DefineSmartDrawGraphFunctions['index'] = (g:DefineSmartDrawGraphFunctions['index']+1) % len(g:DefineSmartDrawGraphFunctions['value'])
    let index_value = g:DefineSmartDrawGraphFunctions['index']

    call LoadAndUseCustomDrawSetFunctions(g:DefineSmartDrawGraphFunctions['value'][index_value][0], g:DefineSmartDrawGraphFunctions['value'][index_value][1], g:DefineSmartDrawGraphFunctions['value'][index_value][2], g:DefineSmartDrawGraphFunctions['value'][index_value][3])

    call UpdateSmartDrawLev2Info()
    if a:is_show
        call UpdateVisualBlockPopup()
    endif

    " " 记录结束时间
    " let l:end_time = reltime()

    " " 计算执行时间
    " let l:elapsed_time = reltimestr(reltime(l:start_time, l:end_time))

    " " 输出执行时间
    " echo "Execution time: " . l:elapsed_time
endfunction

call SwitchDefineSmartDrawGraphSet(0)



" 定义一个全局变量来存储光标物理位置和对应的字符
let g:multi_cursors = []
highlight MultiCursor cterm=reverse gui=reverse guibg=Yellow guifg=Black

" 添加光标的函数
function! AddCursor(direction, ...)
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    let [chars_arr, index] = ProcessLine(row, virtcol)
    let col = len(join(chars_arr[0:index], ''))

    let length = len(chars_arr[index])
    let dis_length = strdisplaywidth(chars_arr[index])
    if length == 0
        let length = len(chars_arr[index-1])
        let col -= 2
        let add_char = chars_arr[index-1]
        let add_row = row
        let add_col = virtcol - 1
    else
        if dis_length == 1 && length != 1
            let col -= 2
        endif
        let add_char = chars_arr[index]
        let add_row = row
        let add_col = virtcol
    endif

    let match_id = matchaddpos('MultiCursor', [[row, col, length]])
    call add(g:multi_cursors, [add_char, add_row, add_col, match_id])

    if a:direction == 'l'
        normal! l
    elseif a:direction == 'h'
        normal! h
    elseif a:direction == 'j'
        normal! j
    elseif a:direction == 'k'
        normal! k
    endif
endfunction

function! VisualBlockAddCursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            let [chars_arr, index] = ProcessLine(row, col)

            if strdisplaywidth(chars_arr[index]) != 2
                call AddCursor('null', row, col)
                call cursor(row, len(join(chars_arr[0:index], '')))
            endif
        endfor
    endfor
endfunction

function! VisualBlockRemoveCursor() range
    let row_left = line("'<")
    let row_right = line("'>")
    let col_left= virtcol("'<")
    let col_right = virtcol("'>")

    for row in range(row_left, row_right)
        for col in range(col_left, col_right-1)
            let [chars_arr, index] = ProcessLine(row, col)

            if strdisplaywidth(chars_arr[index]) != 2
                call RemoveCursor('null', row, col)
                call cursor(row, len(join(chars_arr[0:index], '')))
            endif
        endfor
    endfor

endfunction


" 移除某个光标的函数
function! RemoveCursor(direction, ...)
    let row = get(a:, 1, line('.'))
    let virtcol = get(a:, 2, virtcol('.'))
    let [chars_arr, index] = ProcessLine(row, virtcol)

    let length = len(chars_arr[index])
    let new_multi_cursors = []
    for cursor in g:multi_cursors
        if length == 0
            if !(cursor[1] == row && cursor[2] == virtcol - 1)
                call add(new_multi_cursors, cursor)
            else
                call matchdelete(cursor[3])
            endif
        else
            if !(cursor[1] == row && cursor[2] == virtcol)
                call add(new_multi_cursors, cursor)
            else
                call matchdelete(cursor[3])
            endif
        endif
    endfor
    let g:multi_cursors = new_multi_cursors

    if a:direction == 'l'
        normal! l
    elseif a:direction == 'h'
        normal! h
    elseif a:direction == 'j'
        normal! j
    elseif a:direction == 'k'
        normal! k
    endif
endfunction

function! AddCursorMouseMoveStart()
    augroup RemoveCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup AddCursorMouseMove
        autocmd!
        autocmd CursorMoved * call AddCursor('null')
    augroup END
endfunction

function! RemoveCursorMouseMoveStart()
    augroup AddCursorMouseMove
        autocmd!
    augroup END

    set mouse=n

    augroup RemoveCursorMouseMove
        autocmd!
        autocmd CursorMoved * call RemoveCursor('null')
    augroup END
endfunction

function! DisableCursorMouseMove()
    augroup RemoveCursorMouseMove
        autocmd!
    augroup END

    augroup AddCursorMouseMove
        autocmd!
    augroup END
    
    set mouse=a
endfunction

" 删除所有光标的函数
function! ClearCursors()
    let g:multi_cursors = []
    call clearmatches()
    augroup AddCursorMouseMove
        autocmd!
    augroup END
    augroup RemoveCursorMouseMove
        autocmd!
    augroup END
    set mouse=a
endfunction

function! CreateRectangleString(data, is_delate_ori_data, replace_char)
    " 获取矩形的最小和最大行、列
    let min_row = min(map(copy(a:data), 'v:val[1]'))
    let max_row = max(map(copy(a:data), 'v:val[1]'))
    let min_col = min(map(copy(a:data), 'v:val[2]'))
    let max_col = max(map(copy(a:data), 'v:val[2]'))

    " 初始化矩形字符串为二维矩阵
    let rectangle = []
    for i in range(min_row, max_row + 1)
        let row = []
        for j in range(min_col, max_col+1)
            call add(row, ' ')
        endfor
        call add(rectangle, row)
    endfor

    " 遍历数据，插入字符到矩形字符串中
    for item in a:data
        let [char, row, col] = [item[0], item[1], item[2]]
        let rectangle[row - min_row][col - min_col] = char
        " 如果是宽字符那么后面的字符设置为空
        if strdisplaywidth(char) == 2
            let rectangle[row - min_row][col - min_col+1] = ''
        endif
    endfor

    " 将二维矩阵转换为字符串
    let result = []
    for row in rectangle
        let row = join(row, '')
        " :TODO: 这里有一个问题,就是删除了所有的行尾空格后,可能导致覆盖模式也
        " 缺少尾部的填充空格。所有这里就删除最后一个空格就好
        " 具体策略可以根据业务调整
        " let row = substitute(row, '\s\+$', '', '')
        let row = substitute(row, '\s$', '', '')
        call add(result, row)
    endfor

    " 放入x寄存器中用于绘图
    let @+ = join(result, "\n")

    " 是否删除原字符
    if a:is_delate_ori_data
        for item in a:data
            let [row, col] = [item[1], item[2]]
            call DrawSmartLineEraser('null', row, col, a:replace_char)
        endfor
    endif

    call ClearCursors()

endfunction

" 替换高亮字符组中的字符为+寄存器中的第一个字符(如果寄存器中内容为空替换成空格)
function! ReplaceHighLightGroupToSystemReg()
    let char = getreg('+')
    let char = empty(char) ? ' ' : strcharpart(char, 0, 1)
    call CreateRectangleString(g:multi_cursors, 1, char)
endfunction


" 绑定快捷键
nnoremap <silent> <C-S-N> :call AddCursor('null')<CR>
nnoremap <silent> <C-S-J> :call AddCursor('j')<CR>
nnoremap <silent> <C-S-K> :call AddCursor('k')<CR>
nnoremap <silent> <C-S-L> :call AddCursor('l')<CR>
nnoremap <silent> <C-S-H> :call AddCursor('h')<CR>
nnoremap <silent> si :call AddCursorMouseMoveStart()<CR>
nnoremap <silent> sj :call RemoveCursorMouseMoveStart()<CR>
nnoremap <silent> sd :call DisableCursorMouseMove()<CR>
vnoremap <silent> si :call VisualBlockAddCursor()<CR>
vnoremap <silent> sj :call VisualBlockRemoveCursor()<CR>

nnoremap <silent> <C-S-C> :call ClearCursors()<CR>
nnoremap <silent> <C-x> :call CreateRectangleString(g:multi_cursors, 0, ' ')<CR>
nnoremap <silent> <C-S-X> :call CreateRectangleString(g:multi_cursors, 1, ' ')<CR>
nnoremap <silent> <C-S-G> :call ReplaceHighLightGroupToSystemReg()<CR>
" <M-S-LeftMouse> 可以让鼠标进入块选择模式,然后可以方便的进行各种操作


" 代码笔记跳转功能 {
function! JumpToCode()
    " " 获取根目录
    " " #[:meta:root:/project/root/path]
    " let l:root_line = getline('$')
    " if l:root_line =~ '[:meta:root:'
    "     let l:root_path = substitute(l:root_line, '\[:meta:root:\(.*\)\]', '\1', '')
    " else
    "     echo "未找到根目录标记"
    "     return
    " endif
    " 查找项目根目录
    let l:root_path = FindRootDir()
    if l:root_path == ''
        echo "未找到项目根目录"
        return
    endif

    " 获取当前光标下的行和列
    let l:line = getline('.')
    let l:col = col('.')

    " 查找所有匹配的路径和行号
    " [os/os_uname_a.sh:12]
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\[\[([^\[\]]+):(\d+)\]\]', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\[\[([^\[\]]+):(\d+)\]\]', l:start)
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

    let l:matches_list = matchlist(match_str, '\v\[\[([^\[\]]+):(\d+)\]\]')
    let [ l:relative_path, l:line_number ] = [ l:matches_list[1], l:matches_list[2] ]

    " 拼接完整路径
    let l:full_path = l:root_path . '/' . l:relative_path

    " 检查当前窗口布局并决定如何分屏
    if winnr('$') == 1
        " 只有一个窗口，直接垂直分屏
        execute 'vsplit ' . l:full_path
    else
        " 多个窗口，先切换到左边窗口
        execute 'wincmd h'
        " 在左边窗口中水平分屏
        execute 'split ' . l:full_path
    endif

    execute l:line_number
endfunction

function! GetRelationPath()
    " 获取当前文件的绝对路径和行号
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')

    " 查找项目根目录
    let l:root_dir = FindRootDir()
    if l:root_dir == ''
        echo "未找到项目根目录"
        return ''
    endif

    " 计算相对路径
    let l:relative_path = absolute_path[len(l:root_dir)+1:]
    return l:relative_path
endfunction


" 把当前的相对路径和行号信息保存到系统剪切板中
" [os/os_uname_a.sh:12]
function! RecordCodePathAndLineToSystemReg()
    " 计算相对路径
    let l:relative_path = GetRelationPath()
    if empty(l:relative_path)
        return
    endif
    let l:line_number = line('.')

    " 生成路径和行号字符串
    let l:result = '[[' . l:relative_path . ':' . l:line_number . ']]'
    let @+ = l:result
endfunction

" 当前只支持.git目录和.root文件
function! FindRootDir()
    let l:current_dir = expand('%:p:h')
    let l:current_dir = substitute(l:current_dir, '\\', '/', 'g')

    while l:current_dir != '/'
        if isdirectory(l:current_dir . '/.git') || filereadable(l:current_dir . '/.root')
            return l:current_dir
        endif
        let l:current_dir = fnamemodify(l:current_dir, ':h')
    endwhile
    return ''
endfunction

" 锚点的格式
" {{id:这是一个锚点}}
" 定义快捷方式在锚点上生成指向锚点的链接并保存到系统剪切板中
" [[src/os/os_uname_a.sh:#这是一个锚点]]
function! RecordHunkToSystemReg()
    let l:line = getline('.')
    let l:col = col('.')
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\{\{id:([^\{\}]+)\}\}', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\{\{id:([^\{\}]+)\}\}', l:start)
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

    let l:relative_path = GetRelationPath()
    if empty(l:relative_path)
        return
    endif

    let l:matches_list = matchlist(match_str, '\v\{\{id:([^\{\}]+)\}\}')
    let l:hunk_str = '[[' . l:relative_path . ':#' . l:matches_list[1] . ']]'
    let @+ = l:hunk_str
endfunction

" 通过锚点链接跳转到锚点
function! JumpToHunkPoint()
    " 查找项目根目录
    let l:root_path = FindRootDir()
    if l:root_path == ''
        echo "未找到项目根目录"
        return
    endif

    " 获取当前光标下的行和列
    let l:line = getline('.')
    let l:col = col('.')

    " 查找所有匹配的路径和锚点名
    " [[os/os_uname_a.sh:#我是一个锚点]]
    let l:start = 0
    let l:is_find_position = 0
    let l:match = []
    while l:start >= 0
        let l:start = match(l:line, '\v\[\[([^\[\]]+):#([^\[\]]+)\]\]', l:start)
        if l:start >= 0
            let match_str = matchstr(l:line, '\v\[\[([^\[\]]+):#([^\[\]]+)\]\]', l:start)
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

    let l:matches_list = matchlist(match_str, '\v\[\[([^\[\]]+):#([^\[\]]+)\]\]')
    let [ l:relative_path, l:hunk_str ] = [ l:matches_list[1], '{{id:' . l:matches_list[2] . '}}' ]

    " 拼接完整路径
    let l:full_path = l:root_path . '/' . l:relative_path
    " echo "full_path:" . l:full_path . ';' . 'hunk_str:' . l:hunk_str . ';'

    let cur_path = expand('%:p')
    let cur_path = substitute(cur_path, '\\', '/', 'g')

    " 先在文件中找到锚点字符串的行列值
    try
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


" :TODO: 后续如果中括号和冒号不够防呆,可以使用另外的特殊的unicode字符替代,或者使用更多的边界字符防呆,不过目前这样就够
nnoremap <silent> <leader>jj :call JumpToCode()<CR>
nnoremap <silent> <leader>jl :call RecordCodePathAndLineToSystemReg()<CR>
nnoremap <silent> <leader>jr :call RecordHunkToSystemReg()<CR>
nnoremap <silent> <leader>jh :call JumpToHunkPoint()<CR>

" 代码笔记跳转功能 }

" 文本幻灯片功能 {
" xx_1.txt
" xx_2.txt
" xx_3.txt



let g:current_slide = 1
let g:total_slides = 0
let g:slide_files = []

function! LoadSlide(slide)
    if a:slide > 0 && a:slide <= len(g:slide_files)
        let l:filename = g:slide_files[a:slide - 1]
        silent execute 'edit' l:filename
        let g:current_slide = a:slide
    else
        echo "Slide " . a:slide . " does not exist."
    endif
endfunction

function! SlideCursorZero ()
    call cursor(1, 1)
endfunction

function! NextSlide(timer)
    if g:current_slide < g:total_slides
        call LoadSlide(g:current_slide + 1)
    else
        call LoadSlide(1)
    endif
    call ShowSlideInfo()
    call SlideCursorZero()
endfunction

function! PrevSlide()
    if g:current_slide > 1
        call LoadSlide(g:current_slide - 1)
    else
        call LoadSlide(g:total_slides)
    endif
    call ShowSlideInfo()
    call SlideCursorZero()
endfunction

function! ShowSlideInfo()
    echo "Slide " . g:current_slide . " of " . g:total_slides
endfunction

function! DetectSlides()
    let g:slide_files = glob('*.txt', 0, 1)
    " 使用自定义的按照数字排序
    let g:slide_files = sort(g:slide_files, {a, b -> str2nr(matchstr(a, '\d\+')) - str2nr(matchstr(b, '\d\+'))})
    let g:total_slides = len(g:slide_files)
endfunction

function! StartSlideshow()
    call DetectSlides()
    call LoadSlide(1)
    echo "Total slides detected: " . g:total_slides
    call SlideCursorZero()
endfunction

function! StartAutoSlideshow(interval)
    if exists("g:slideshow_timer") && g:slideshow_timer != 0
        call StopAutoSlideshow()
    endif
    let g:slideshow_timer = timer_start(a:interval, 'NextSlide', {'repeat': -1})
    echo "Auto slideshow started with interval: " . a:interval . " ms"
endfunction

function! StopAutoSlideshow()
    if exists("g:slideshow_timer") && g:slideshow_timer != 0
        call timer_stop(g:slideshow_timer)
        let g:slideshow_timer = 0
        echo "Auto slideshow stopped"
    endif
endfunction

" :TODO: 可以增加定时打开下一张幻灯片的功能
command! DetectSlides call DetectSlides()
command! NextSlide call NextSlide(0)
command! PrevSlide call PrevSlide()
command! SlideInfo call ShowSlideInfo()
command! StartSlideshow call StartSlideshow()
command! -nargs=1 StartAutoSlideshow call StartAutoSlideshow(<args>)
command! StopAutoSlideshow call StopAutoSlideshow()

if has('gui_running')
    " menu SlideShow.SlideShow\ Menu.Next :PrevSlide<CR>
    " menu SlideShow.Start :StartSlideshow<CR>
    " menu SlideShow.Next :NextSlide<CR>
    " menu SlideShow.Prev :PrevSlide<CR>
    " menu SlideShow.Info :SlideInfo<CR>

    " https://yyq123.github.io/learn-vim/learn-vi-39-ToolBar.html
    set toolbar=icons,text,tooltips
    " D:\programes\Vim\vim91\bitmaps
    " :TODO: 现在的情况是图标无法显示出来,默认的图标和固定路径的图标都不行
    amenu icon=New ToolBar.StartSlideshow :call StartSlideshow()<CR>
    amenu icon=Open ToolBar.NextSlide :NextSlide<CR>
    amenu icon=Save ToolBar.PrevSlide :PrevSlide<CR>
    amenu icon=Help ToolBar.SlideInfo :SlideInfo<CR>
    amenu icon=New ToolBar.StartAutoSlideshow :StartAutoSlideshow 1000<CR>
    amenu icon=Open ToolBar.StopAutoSlideshow :StopAutoSlideshow<CR>

    tmenu ToolBar.StartSlideshow start slide show
    tmenu ToolBar.NextSlide next slide
    tmenu ToolBar.PrevSlide prev slid
    tmenu ToolBar.SlideInfo slide info
    tmenu ToolBar.StartAutoSlideshow start auto slide show
    tmenu ToolBar.StopAutoSlideshow stop auto slide show

    set guioptions+=T
    " set guioptions+=m
endif


" 文本幻灯片功能 }

