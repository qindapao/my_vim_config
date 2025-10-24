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


" 这个一定要放到最前面，放后面可能不会生效
let mapleader="\<Space>"

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
                " :TODO: 目前不知道为啥这些错误信息都会打印出来
                " echohl Error
                " echo "subsection must have parent section, ignore illegal heading line at line " . i
                " echohl None
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
                    " :TODO: 目前不知道为啥这些错误信息都会打印出来
                    " echohl Error
                    " echo "subsection must have parent section, ignore illegal heading line at line " . i
                    " echohl None
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

" 关闭同组兄弟窗口，只保留当前窗口
function! CollapseLeafGroup() abort
    let cur_winid = win_getid()
    let layout = winlayout()

    " 先找到当前窗口所在的分组路径
    function! s:find_parent_group(node, target, parent) abort
        if type(a:node) == type([])
            if a:node[0] ==# 'row' || a:node[0] ==# 'col'
                for child in a:node[1]
                    let result = s:find_parent_group(child, a:target, a:node)
                    if !empty(result)
                        return result
                    endif
                endfor
            elseif a:node[0] ==# 'leaf' && a:node[1] == a:target
                return a:parent
            endif
        elseif type(a:node) == type(0) && a:node == a:target
            return a:parent
        endif
        return []
    endfunction

    let group = s:find_parent_group(layout, cur_winid, [])
    if empty(group)
        echohl WarningMsg | echo "未找到当前窗口的所属分组。" | echohl None
        return
    endif

    for sibling in group[1]
        if type(sibling) == type([]) && sibling[0] ==# 'leaf'
            let sid = sibling[1]
            if sid != cur_winid
                execute win_id2win(sid) . "close"
            endif
        elseif type(sibling) == type(0) && sibling != cur_winid
            execute win_id2win(sibling) . "close"
        endif
    endfor
endfunction

command! CollapseFinalGroup call CollapseLeafGroup()
nnoremap <silent> sc :CollapseFinalGroup<cr>


" below are my personal settings
" 基本设置区域 {

" 交换文件放置到固定的目录中去
set directory^=$HOME/.vim/swap//

nnoremap <leader>tbd :call DeleteTerminalBuffers()<cr>| " 终端: 删除所有的终端buffer

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
nnoremap <silent> tn :tabnew<CR>| " 多标签: 创建新标签页
nnoremap <silent> tc :tabclose<CR>| " 多标签: 关闭当前标签页
nnoremap <silent> tC :q!<CR> " 多标签: 强制关闭当前标签页
nnoremap <silent> to :tabonly<CR>| " 多标签: 只保留当前标签页
nnoremap <Tab> gt<cr>| " 多标签: 向前切换标签页
nnoremap <S-Tab> gT<cr>| " 多标签: 向后切换标签页
nnoremap <M-1> 1gt| " 多标签: 切换到第1个标签页
nnoremap <M-2> 2gt| " 多标签: 切换到第2个标签页
nnoremap <M-3> 3gt| " 多标签: 切换到第3个标签页
nnoremap <M-4> 4gt| " 多标签: 切换到第4个标签页
nnoremap <M-5> 5gt| " 多标签: 切换到第5个标签页
nnoremap <M-6> 6gt| " 多标签: 切换到第6个标签页
nnoremap <M-7> 7gt| " 多标签: 切换到第7个标签页
nnoremap <M-8> 8gt| " 多标签: 切换到第8个标签页
nnoremap <M-9> 9gt| " 多标签: 切换到第9个标签页
nnoremap <M-0> :tablast<CR>| " 多标签: 切换到最后一个标签页

nnoremap <silent> <leader>new :new<cr>| " 文件: 创建一个新文件
nnoremap <silent> <leader>enew :enew<cr>| " 文件: 创建一个新文件并编辑

" 替换保持列的位置不变
nnoremap gR R
nnoremap R gR

set scrolloff=3

" search highlight
set hlsearch| " 高亮: 设置搜索高亮
nnoremap <silent> <leader>noh :nohlsearch<CR>| " 高亮: 取消搜索高亮
nnoremap <silent> # :nohlsearch<CR>| " 高亮: 取消搜索高亮

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                                                                    " 用空格替换TAB

" perl格式的文件的特殊设置 {
autocmd FileType perl call s:CustomPerlIndent()

function! s:CustomPerlIndent()
    " 禁用 Vim 的 Perl 缩进脚本（只对 Perl）
    setlocal indentexpr=
    " setlocal indentkeys=
    setlocal nosmartindent nocindent noautoindent

    " 设置 TAB 为 4 个空格宽度
    setlocal tabstop=4
    setlocal shiftwidth=4
    setlocal softtabstop=4
    setlocal noexpandtab
endfunction
" }

" 设置星号不要自动跳转,只高亮
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>| " 搜索: 搜索并高亮当前单词
" :TODO: 这里使用了默认的寄存器，如果后续有干扰，需要保持默认寄存器干净，可能需要修改这里
xnoremap <silent> * y:let @/='\V'.escape(@", '/\')<CR>:let old_pos = getpos(".")<CR>:set hls<CR>:call setpos('.', old_pos)<CR>| " 搜索: 可视模式搜索并高亮当前单词


" 星号切换打开和关闭高亮(暂时不使用)
" nnoremap <silent> * :if &hlsearch \| let @/= '\<' . expand('<cword>') . '\>' \| set nohls \| else \| let @/= '\<' . expand('<cword>') . '\>' \| set hls \| endif <cr>

set cursorline                                                                   " highlight current line

nnoremap <silent> <leader>scc :set cursorcolumn<cr>| " 辅助: 高亮当前列
nnoremap <silent> <leader>scn :set nocursorcolumn<cr>| " 辅助: 取消高亮当前列

" cursor not blinking
set guicursor+=a:blinkon0

" set guifont=sarasa\ mono\ sc:h13
" set guifont=Yahei\ Fira\ Icon\ Hybrid:h11
" set guifont=微软雅黑\ PragmataPro\ Mono:h8
" 这个字体某些方向符号无法显示
" set guifont=Fira\ Code:h8
" set guifont=Maple\ Mono\ NL\ NF\ CN:h8
" set guifont=Microsoft\ YaHei\ Mono:h8
" set guifont=PragmataPro\ Mono:h8
" set guifont=PragmataPro:h8
set guifont=vimio\ mono:h8



set noundofile
set nobackup
" 水平滚动条会让界面在上下滚动的时候有卡顿和撕裂感
" set guioptions+=b
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
autocmd BufNewFile,BufRead *.vim9 set filetype=vim

" 编辑vim配置文件
nnoremap <Leader>ver :e $MYVIMRC<CR>| " 辅助: 编辑当前的vim配置文件

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

" " 某些插件可能需要手动指定python3库的地址,不过大多情况下这个值是默认的并不需要设置，只有出问题才需要设置
" if has('python3')
"      set pythonthreedll='D:\python\python38.dll'
"      set pythonthreehome='D:\python'
" endif

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
" Z 代表最后结束的意思，所以是关闭窗口
nnoremap <silent> sz :close<CR>| " 关闭当前窗口
nnoremap <silent> <F2> :close<CR>| " 关闭当前窗口
" E 视觉自觉就是纵向分屏
nnoremap <silent> se :split<CR>| " 纵向分屏
" W 视觉自觉就是横向分屏
nnoremap <silent> sw :vsplit<CR>| " 横向分屏
" n 表示 only 删除别的留自己
nnoremap <silent> sn :only<CR>| " 只保留当前窗口


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
autocmd filetype asciidoc setlocal omnifunc=OmniCompleteCustom


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

nnoremap <leader>swa yiw/\c\<<C-R>"\>| " 搜索: 当前文件当前光标下单词全词自动搜索
nnoremap <leader>swm /\c\<\><Left><Left>| " 搜索: 当前文件全词手动搜索

" 设置vim等待某些事件的刷新事件(默认是4000ms)[ :TODO: 这个设置可能比较危险,目前还不确定有什么副作用]
set updatetime=100

" 自动创建注释
set formatoptions+=ro

" 安静保存
nnoremap <silent> <C-s> :silent w<CR>
inoremap <silent> <C-s> <Esc>:silent w<CR>a
vnoremap <silent> <C-s> <Esc>:silent w<CR>gv


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
" " 如果编辑挂载的远程文件,下面这个插件会导致很卡
" Plug 'qindapao/vim-airline'                                                    " 漂亮的状态栏
" 虽然功能不如 vim-airline 强大，但是快速湿滑
Plug 'itchyny/lightline.vim'
Plug 'qindapao/tabular'                                                        " 自动对齐插件
" 下面两个插件任选其一
" Plug 'qindapao/indentLine'                                                    " 对齐参考线插件
Plug 'qindapao/vim-indent-guides'                                              " 使用高亮而不是字符来对齐参考线
Plug 'qindapao/vim-fugitive'                                                   " vim的git集成插件
Plug 'qindapao/vim-rhubarb'                                                    " 用于打开gi的远程
" 这个插件功能和vim-flog重复,先屏蔽
" Plug 'junegunn/gv.vim'                                                         " git树显示插件
Plug 'qindapao/vim-flog'                                                       " 显示漂亮的git praph插件
" 如果编辑的是远程文件或者是编辑的文件很大，下面这个插件都会很卡
" 所以默认加载插件后禁用，然后需要的时候手动打开和关闭 ggo ggc
Plug 'qindapao/vim-gitgutter'                                                  " git改变显示插件
Plug 'qindapao/vimcdoc'                                                        " vim的中文文档
if expand('%:e') ==# 'txt' || expand('%:e') ==# 'md' || expand('%:e') ==# 'adoc'
    " 这里要注意下,这个插件会导致preview预览涂鸦窗口无法关闭,影响自定义补全
    Plug 'qindapao/completor.vim'                                              " 主要是用它的中文补全功能
else
    " 这里必须使用realese分支,不能用master分支,master分支需要自己编译
    Plug 'qindapao/coc.nvim', {'branch': 'release'}
endif
Plug 'qindapao/vim-gutentags'                                                  " gtags ctags自动生成插件
Plug 'qindapao/gutentags_plus'                                                 " 方便自动化管理tags插件
" 这个插件在大文件的时候也非常卡
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
" " 这个插件在大文件的时候也很卡，禁用
" Plug 'qindapao/vim-rainbow' 
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
Plug 'qindapao/vim', { 'as': 'catppuccin', 'branch': 'qq_modify' }               " catppuccin 主题
Plug 'pbrisbin/vim-colors-off'                                                 " 最简单的主题,所有的高亮基本关闭
Plug 'qindapao/photon.vim'                                                       " 一个极简的漂亮主题
Plug 'qindapao/Lightning', {'branch': 'qq_modify'}
Plug 'nightsense/carbonized'
Plug 'sainnhe/everforest'
Plug 'nikolvs/vim-sunbather'
Plug 'igungor/schellar'
Plug 'Donearm/Laederon'
Plug 'devsjc/vim-jb'

Plug 'qindapao/vim-go'
Plug 'vim-perl/vim-perl'
Plug 'qindapao/vimio'
Plug 'qindapao/vim-which-key'

" vim-go 插件的配置 {
" 修改 GOPATH 目录(目前导致了一些问题先不改)
" let g:go_bin_path = '~\.vim\go\bin' 
" ctrl + x + ctrl + o 触发 Go 语言的全功能补全
" vim-go 插件的配置 }

call plug#end()
" 插件 }

" 插件配置 {
" vim-expand-region {
" + " 辅助:vim-expand-region 普通模式下扩大选区
" _ " 辅助:vim-expand-region 普通模式下缩小选区

let g:expand_region_text_objects = {
      \ 'iw'  :1,
      \ 'iW'  :1,
      \ 'i"'  :1,
      \ "i'"  :1,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ 'i]'  :1,
      \ 'ab'  :1,
      \ 'aB'  :1,
      \ 'a]'  :1,
      \ 'ii'  :1,
      \ 'ai'  :1,
      \ 'ip'  :1,
      \ 'il'  :1,
      \ }

" 扩大选区
nnoremap <M-i> <Plug>(expand_region_expand)| " 编辑: 普通模式下扩大选区
vnoremap <M-i> <Plug>(expand_region_expand)| " 编辑: 可视模式下扩大选区

" 缩小选区
nnoremap <M-o> <Plug>(expand_region_shrink)| " 编辑: 普通模式下缩小选区
vnoremap <M-o> <Plug>(expand_region_shrink)| " 编辑: 可视模式下缩小选区
" vim-expand-region }

" table-mode {
nnoremap <leader>tm :TableModeToggle<CR>| " 辅助: 表格编辑模式
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
nnoremap <leader>af :ALEDisable<cr>| " lint: 关闭ale的语法检查
" 手动打开ale
nnoremap <leader>ao :ALEEnable<cr>| " lint: 打开ale的语法检查
" 定义需要禁用 ALE 的文件类型列表
let g:ale_disabled_filetypes = ['markdown', 'asciidocx', 'asciidoc', 'adoc', 'text', 'txt', 'zim', 'sh', 'bash']
" 每次打开文件时判断是否禁用 ALE
autocmd FileType * call s:ToggleALEByFiletype()
function! s:ToggleALEByFiletype()
    if index(g:ale_disabled_filetypes, &filetype) >= 0
        silent! ALEDisable
    else
        silent! ALEEnable
    endif
endfunction
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
" let g:gutentags_gtags_extra_args = ['--gtagslabel=native-pygments']
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

" ctags 也要使用 universal ctags ，不能用老的 Exuberant-ctags 
" 查看当前使用的 python3 版本的方法
" 如果使用的是cygwin版本的python3，要注意下，这个版本的python3需要安装 pygments 模块
" 如果当前使用的python3版本不对，要调整下包含python3可执行文件的位置，放到Path变量的最前面
" 在命令中输入 :echo system('python3 --version')

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

nnoremap <silent> <leader>gns :GscopeFind s <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
nnoremap <silent> <leader>gng :GscopeFind g <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
nnoremap <silent> <leader>gnc :GscopeFind c <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
nnoremap <silent> <leader>gnt :GscopeFind t <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
nnoremap <silent> <leader>gne :GscopeFind e <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
nnoremap <silent> <leader>gnf :GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
nnoremap <silent> <leader>gni :GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
nnoremap <silent> <leader>gnd :GscopeFind d <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
nnoremap <silent> <leader>gna :GscopeFind a <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
nnoremap <silent> <leader>gnz :GscopeFind z <C-R><C-W><cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词

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

vnoremap <leader>gns y:GscopeFind s <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号
vnoremap <leader>gng y:GscopeFind g <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找符号定义
vnoremap <leader>gnc y:GscopeFind c <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 调用这个函数的函数
vnoremap <leader>gnt y:GscopeFind t <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找字符串
vnoremap <leader>gne y:GscopeFind e <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找正则表达式
vnoremap <leader>gnf y:GscopeFind f <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找文件名
vnoremap <leader>gni y:GscopeFind i <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找包含当前头文件的文件
vnoremap <leader>gnd y:GscopeFind d <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 此函数调用的函数
vnoremap <leader>gna y:GscopeFind a <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 查找为此符号赋值的位置
vnoremap <leader>gnz y:GscopeFind z <c-r>"<cr>:wincmd p<cr>| " 标签导航:gutentags_plus 在ctags的数据库中查找当前单词
" gutentags_plus 插件配置 }

" 扩展选择(这里只是记录备忘,所用默认配置即可) {
" nnoremap v<count>ii | " 辅助: 选择当前缩进，不包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>ai | " 辅助: 选择当前缩进，包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>iI | " 辅助: 选择当前缩进，包括上下边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>aI | " 辅助: 选择当前缩进，不包括上下边界，(微调使用o命令，可以在可视选框上下调整)

" 扩展选择 }

" NERDTree {
" 刷新NERDTree的状态
nnoremap <leader>rt :NERDTreeFocus<cr>:NERDTreeRefreshRoot<cr><c-w>p| " 目录树: 刷新目录树状态
nnoremap <leader>rf :NERDTreeFind<cr>:NERDTreeRefreshRoot<cr><c-w>p| " 目录树: 进入当前文件对应的目录树并且刷新目录树状态
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
let g:gitgutter_max_signs = 2000                                                 " 如果设置为-1,标记的数量为无限
" 默认不启用
let g:gitgutter_enabled = 0
" 切换它的打开和关闭
nnoremap <silent> <leader>ggo :GitGutterEnable<CR>
nnoremap <silent> <leader>ggc :GitGutterDisable<CR>
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

" 主题和颜色设置 {
" 定义主题列表和颜色配置
let g:my_themes = [
    \ {'name': 'Lightning',         'fg': '#F0F0F0', 'bg': '#F5F5F5', 'config': {'global': {'airline_theme': 'catppuccin_frappe'}}},
    \ {'name': 'photon',            'fg': '#2E2E2E', 'bg': '#3C3C3C', 'config': {'global': {'airline_theme': 'catppuccin_frappe'}}},
    \ {'name': 'peachpuff',         'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'carbonized-light',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'carbonized-dark',   'fg': '#2E2E2E', 'bg': '#3C3C3C', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'everforest',        'fg': '#2E2E2E', 'bg': '#3C3C3C',
    \ 'config': { 
    \     'options': {'background': 'dark'},
    \     'global':  {
    \         'everforest_background': 'hard',
    \         'everforest_better_performance': 1,
    \         'airline_theme': 'everforest',
    \         },
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'everforest',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global': {
    \         'everforest_background': 'hard',
    \         'everforest_better_performance': 1,
    \         'airline_theme': 'everforest',
    \         },
    \    'post_command': [
    \        'set fillchars=vert:▒',
    \        'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \        ],
    \     },
    \ },
    \ {'name': 'sunbather',        'fg': '#2E2E2E', 'bg': '#3C3C3C',
    \ 'config': { 
    \     'options': {'background': 'dark'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#444444',
    \         ],
    \     },
    \ },
    \ {'name': 'sunbather',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'schellar',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'Laederon',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'jb',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {
    \         'airline_theme': 'catppuccin_frappe',
    \         'jb_style': 'light',
    \         'jb_enable_italic': 0,
    \         'jb_enable_unicode': 1,
    \         },
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=214 guifg=#FFA500',
    \         ],
    \     },
    \ },
    \ {'name': 'default',    'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         ],
    \     },
    \ },
    \ {'name': 'lunaperche',      'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         ],
    \     },
    \ },
    \ {'name': 'off',      'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe', 'colors_off_a_little': 1},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight CursorLine guibg=#f5f5f5',
    \         ],
    \     },
    \ },
    \ ]


" 定义辅助函数来设置主题和颜色
function! SetTheme(theme)
    if has_key(a:theme, 'config')
        " 设置全局变量
        if has_key(a:theme.config, 'global')
            for [key, val] in items(a:theme.config.global)
                execute 'let g:' . key . ' = ' . string(val)
            endfor
        endif

        " 设置 Vim 选项
        if has_key(a:theme.config, 'options')
            for [key, val] in items(a:theme.config.options)
                execute 'set ' . key . '=' . val
            endfor
        endif
    endif

    execute 'colorscheme ' . a:theme.name
    execute 'hi IndentGuidesOdd guibg=' . a:theme.fg . ' ctermbg=15'
    execute 'hi IndentGuidesEven guibg=' . a:theme.bg . ' ctermbg=15'

    " 执行后置命令
    if has_key(a:theme, 'config') && has_key(a:theme.config, 'post_command')
        for cmd in a:theme.config.post_command
            execute cmd
        endfor
    endif

    redraw
    echohl Question
    echo '* 正在应用主题：' . a:theme.name . ' ' . (g:my_color_name_index + 1) . '/' . len(g:my_themes)
    echohl None
endfunction

" 定义切换主题的函数
function! ToggleMyOwnTheme()
    let g:my_color_name_index = (g:my_color_name_index + 1) % len(g:my_themes)
    call ApplyTheme()
endfunction

" 定义应用主题的函数
function! ApplyTheme()
    let theme = g:my_themes[g:my_color_name_index]
    call SetTheme(theme)
    " 保存当前主题状态到文件
    call writefile([g:my_color_name_index], expand('~/.vim_theme'))
endfunction

" 在 Vim 启动时读取主题状态并应用
if filereadable(expand('~/.vim_theme'))
    let g:my_color_name_index = readfile(expand('~/.vim_theme'))[0]
else
    let g:my_color_name_index = 0
endif

nnoremap <silent><F5> :call ToggleMyOwnTheme()<CR>
autocmd VimEnter * call timer_start(50, { -> ApplyTheme() })


function! RemoveCommentItalic()
    let l:new_attrs = []

    " 获取 Comment 的 synID
    let l:id = synIDtrans(hlID('Comment'))

    " term/cterm/gui 样式
    for style_type in ['bold', 'underline', 'reverse', 'standout']
        if synIDattr(l:id, style_type, 'gui') == 1
            call add(l:new_attrs, 'gui=' . style_type)
        endif
        if synIDattr(l:id, style_type, 'cterm') == 1
            call add(l:new_attrs, 'cterm=' . style_type)
        endif
    endfor

    " 颜色
    let l:guifg = synIDattr(l:id, 'fg', 'gui')
    let l:ctermfg = synIDattr(l:id, 'fg', 'cterm')
    if l:guifg != ''
        call add(l:new_attrs, 'guifg=' . l:guifg)
    endif
    if l:ctermfg != ''
        call add(l:new_attrs, 'ctermfg=' . l:ctermfg)
    endif

    " 去掉 italic，不添加 gui=italic 或 cterm=italic

    " 如果没有其它样式，显式设置 gui=NONE 和 cterm=NONE
    if join(l:new_attrs, ' ') !~ 'gui='
        call add(l:new_attrs, 'gui=NONE')
    endif
    if join(l:new_attrs, ' ') !~ 'cterm='
        call add(l:new_attrs, 'cterm=NONE')
    endif

    " 构造并执行 highlight 命令
    let l:cmd = 'highlight Comment ' . join(l:new_attrs, ' ')
    execute l:cmd
endfunction
autocmd ColorScheme * call RemoveCommentItalic()
" 主题和颜色设置 }

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

" let g:Lf_ShowRelativePath = 1


" 字符串检索相关配置 可以手动补充的词 (-i 忽略大小写. -e <PATTERN> 正则表达式搜 索. -F 搜 索字符串而不是正则表达式. -w 搜 索只匹配有边界的词.)
nnoremap <leader>frm <Plug>LeaderfRgPrompt| "                  搜索:Leaderf Leaderf rg -e,然后等待输入正则表达式
nnoremap <leader>frb <Plug>LeaderfRgCwordLiteralNoBoundary| " 搜索:Leaderf 查询光标或者可视模式下所在的词,非全词匹配
nnoremap <leader>frw <Plug>LeaderfRgCwordLiteralBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的词,全词匹配
nnoremap <leader>fren <Plug>LeaderfRgCwordRegexNoBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
nnoremap <leader>frew <Plug>LeaderfRgCwordRegexBoundary| "    搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配
vnoremap <leader>frb <Plug>LeaderfRgVisualLiteralNoBoundary| "搜索:Leaderf 查询光标或者可视模式下所在的词,非全词匹配
vnoremap <leader>frw <Plug>LeaderfRgVisualLiteralBoundary| "  搜索:Leaderf 查询光标或者可视模式下所在的词,全词匹配
vnoremap <leader>fren <Plug>LeaderfRgVisualRegexNoBoundary| "  搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
vnoremap <leader>frew <Plug>LeaderfRgVisualRegexBoundary| "   搜索:Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配
nnoremap <leader>frr :LeaderfRgRecall<cr>| " 搜索:Leaderf 搜索重新打开上一次的rg搜索

nnoremap ]n :Leaderf rg --next<CR>| " 搜索:Leaderf 跳转到字符串搜索列表的下一个结果
nnoremap ]p :Leaderf rg --previous<CR>| " 搜索:Leaderf 跳转到字符串搜索列表的上一个结果


nnoremap <leader>f1 :LeaderfSelf<cr>| " 搜索:Leaderf 搜索leaderf自己
nnoremap <leader>fm :LeaderfMru<cr>| " 搜索:Leaderf 搜索leaderf最近打开文件列表
nnoremap <leader>ff :LeaderfFunction<cr>| " 搜索:Leaderf 搜索函数
nnoremap <leader>fb :LeaderfBuffer<cr>| " 搜索:Leaderf 搜索buffer
nnoremap <leader>ft :LeaderfBufTag<cr>| " 搜索:Leaderf 搜索标签文件
nnoremap <leader>fll :LeaderfLine<cr>| " 搜索:Leaderf 搜索当前文件的所有行
nnoremap <leader>fw :LeaderfWindow<cr>| " 搜索:Leaderf 搜索打开的窗口

" search visually selected text literally, don't quit LeaderF after accepting an entry
" 这个不开启二次过滤
" 这里要注意下不能l键映射到最前面，不然会导致可视模式下自动往后多选择一个字符, --context 5 显示上下文5行, r替换
xnoremap gfl :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen --context 5 -e %s ", leaderf#Rg#visual())<CR>| " 搜索:Leaderf 不开启二次过滤的保留搜索列表(跳转后)
" 这个开启二次过滤
xnoremap gnfl :<C-U><C-R>=printf("Leaderf rg -F --stayOpen --context 5 -e %s ", leaderf#Rg#visual())<CR>| " 搜索:Leaderf 开启二次过滤的保留搜索列表(跳转后)

" 保持文件搜 索窗口不关闭
nnoremap <leader><C-P> :Leaderf file --stayOpen<CR>| " 搜索:Leaderf 文件搜索但是保持搜索窗口不关闭
" 保持当前文件行搜 索窗口不关闭
nnoremap <leader>flk :Leaderf line --stayOpen<CR>| " 搜索:Leaderf 搜索文件行但是保持搜索窗口不关闭


" 关闭leaderf的预览窗口,不然会影响-stayOpen模式,预览窗口无法关闭,也无法编辑新的文件
" 当前好像这个功能又可以用了(太卡了，还是把它禁用)
let g:Lf_PreviewInPopup = 0

" leaderf不要自动生成标签,用gentags插件生成
" unique的意思是vim是否检查映射已经存在,如果存在会报错,当前暂时不需要这个功能
" nmap <unique> <leader>fgd <Plug>LeaderfGtagsDefinition
nnoremap <leader>fgd <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
nnoremap <C-LeftMouse> <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
nnoremap <leader>fgr <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
nnoremap <S-LeftMouse> <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
nnoremap <leader>fgs <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
nnoremap <A-LeftMouse> <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
nnoremap <leader>fgg <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)
nnoremap <C-A-LeftMouse> <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)

vnoremap <leader>fgd <Plug>LeaderfGtagsDefinition| " 标签导航:Leaderf 跳转到定义
vnoremap <leader>fgr <Plug>LeaderfGtagsReference| " 标签导航:Leaderf 跳转到引用
vnoremap <leader>fgs <Plug>LeaderfGtagsSymbol| " 标签导航:Leaderf 跳转到符号
vnoremap <leader>fgg <Plug>LeaderfGtagsGrep| " 标签导航:Leaderf 跳转到字符串(启动搜索功能)

nnoremap <leader>fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>| " 标签导航:Leaderf 重新打开最近的跳转命令
nnoremap <leader>fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>| " 标签导航:Leaderf 结果列表的下一个元素
nnoremap <leader>fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>| " 标签导航:Leaderf 结果列表的上一个元素

" LeaderF 配置 }
" tagbar 配置 {
" conf.ctags 配置 C:\Users\xx\ctags.d\conf.ctags
"
" --langdef=asciidocx
" --langmap=asciidocx:.ad.adoc.asciidoc
" --regex-asciidocx=/^=[ \t]+([^[:cntrl:]]+)/o \1/h/
" --regex-asciidocx=/^==[ \t]+([^[:cntrl:]]+)/. \1/h/
" --regex-asciidocx=/^===[ \t]+([^[:cntrl:]]+)/. . \1/h/
" --regex-asciidocx=/^====[ \t]+([^[:cntrl:]]+)/. . . \1/h/
" --regex-asciidocx=/^=====[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/^======[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/^=======[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/\[\[([^]]+)\]\]/\1/a/
" --regex-asciidocx=/^\.([^ \t\.][^[:cntrl:]]+)/\1/t/
" --regex-asciidocx=/image::([^\[]+)/\1/i/
" --regex-asciidocx=/image:([^:][^\[]+)/\1/I/
" --regex-asciidocx=/include::([^\[]+)/\1/n/


" --langdef=txt
" --langmap=txt:.txt
" --regex-txt=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
" --regex-txt=/^(\={5}\s)(\S.+)(\s\={5})$/. 2/h,heading/
" --regex-txt=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
" --regex-txt=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
" --regex-txt=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/

" --langdef=zim
" --langmap=zim:.txt
" --regex-zim=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
" --regex-zim=/^(\={5}\s)(\S.+)(\s\={5})$/. \2/h,heading/
" --regex-zim=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
" --regex-zim=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
" --regex-zim=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/
"
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

" vim 的文件类型依然是 asciidoc 但是呢使用自定义的 ctags 类型 asciidocx
" 这样就在既保持编辑器识别又能让tagbar按照自定义的方式处理标题
let g:tagbar_type_asciidoc = {
    \ 'ctagstype' : 'asciidocx',
    \ 'kinds' : [
        \ 'h:table of contents',
        \ 'a:anchors:1',
        \ 't:titles:1',
        \ 'n:includes:1',
        \ 'i:images:1',
        \ 'I:inline images:1'
    \ ],
    \ 'sort' : 0
\ }

" 0:不要按照tag名排序,而是按照tag出现的顺序排序
" 1:按照tag名排序
let g:tagbar_sort = 0

" 这是为了占用更少的空间
let g:tagbar_position = 'rightbelow'
let g:tagbar_autoshowtag = 0
" 必须要加这一行，不然大文件的时候默认使用tagbar会非常卡顿
" 这是airline显示tag用的
let g:airline#extensions#tagbar#enabled = 0
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
" 具體的顔色配置和主題綁定

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

nnoremap <silent> <leader><leader><leader>d :call completor#do('definition')<CR>| " 补全:completor 显示定义
nnoremap <silent> <leader><leader><leader>c :call completor#do('doc')<CR>| " 补全:completor 显示文档
nnoremap <silent> <leader><leader><leader>f :call completor#do('format')<CR>| " 补全:completor 格式化
nnoremap <silent> <leader><leader><leader>s :call completor#do('hover')<CR>| " 补全:completor ?
" vim_completor.git }

" completor 插件配置 {

" vimspector 调试插件配置 {
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools']


" 如果设置上这个会导致vimspector的按键被自动映射,当前我不需要,已经使用工具栏实现
" 把F键释放给最常用的操作
" let g:vimspector_enable_mappings = 'HUMAN'


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
" 后面使用工具栏来定义调试按钮,释放出来的F1~F12绑定到最常用的操作
nnoremap <silent> <F8> :NERDTreeToggle<CR>| " 目录树: 切换目录树打开关闭
nnoremap <silent> <F4> :TagbarToggle<CR>| " 标签导航:Tagbar 切换打开和关闭Tagbar

" 打开vim自带的文件管理器
nnoremap <silent> <F3> :Explore<CR>| " 目录树: 打开vim自带的文件管理器

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

nnoremap <leader>cfmip :Rooter<cr> :CtrlSF -I | "                   搜索:ctrlsf:项目级 手动搜索,大小写不敏感
nnoremap <leader>cfmic :CtrlSF -I | "                               搜索:ctrlsf:当前目录递归 手动搜索,大小写不敏感
nnoremap <leader>cfmid :CtrlSF -I  ./|          "                   搜索:ctrlsf:仅限当前目录 手动搜索,大小写不敏感
nnoremap <leader>cfmif :CtrlSF -I  %|           "                   搜索:ctrlsf:当前文件 手动搜索,大小写不敏感

nnoremap <leader>cfmsp :Rooter<cr> :CtrlSF -S | "                   搜索:ctrlsf:项目级 手动搜索,大小写敏感
nnoremap <leader>cfmsc :CtrlSF -S | "                               搜索:ctrlsf:当前目录递归 手动搜索,大小写敏感
nnoremap <leader>cfmsd :CtrlSF -S  ./|          "                   搜索:ctrlsf:仅限当前目录 手动搜索,大小写敏感
nnoremap <leader>cfmsf :CtrlSF -S  %|           "                   搜索:ctrlsf:当前文件 手动搜索,大小写敏感

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

nnoremap <leader>vgmp :Rooter<cr> :vimgrep //gj **/*| "                      搜索:vimgrep:项目级 手动搜索
nnoremap <leader>vgmc :vimgrep //gj **/*| "                                  搜索:vimgrep:当前目录递归 手动搜索
nnoremap <leader>vgmd :vimgrep //gj *|          "                            搜索:vimgrep:仅限当前目录 手动搜索
nnoremap <leader>vgmf :vimgrep //gj %|           "                           搜索:vimgrep:当前文件 手动搜索

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
" :TODO: 直接在ctrlsf的搜索界面不要做替换,有一个风险是前面几行无法对齐,如果遇到
" 这种情况要么手动调整前面几行的对齐和下面的一致,或者是定位到真正的文本后再做替换
let g:ctrlsf_indent = 2
" normal 就是左边一列现实上下文的方式，可以用 M 切换
let g:ctrlsf_default_view_mode = 'compact'

" "openb" : 定义的是 打开当前匹配项，并在打开后跳转回 CtrlSF 面板前所在的窗口（也就是通过 suffix 来补充后续动作）。
" key     : "O"       : 你可以按大写 O 来触发这个操作。
" suffix  : "<C-w>p"  : 打开结果后，立刻切换回上一个窗口，保持 CtrlSF 面板活跃。
" \ 'openb': { 'key': 'f', 'suffix': '<C-w>p' },   " f = 打开并跳回
" 如果不想跳回，就不设置 suffix
" M 切换回紧凑模式的预览(切换回去比较卡，建议不要)
" :help ctrlsf-options
let g:ctrlsf_mapping = {
    \ "openb": { 'key': "d" },
    \ "popen": { 'key': "s" },
    \ "pquit": { 'key': "a" },
    \ "stop":  { 'key': "x" },
    \ "vsplit":  { 'key': "v" },
    \ "next": "n",
    \ "prev": "N",
    \ }
" 自动打开预览窗口
" 目前似乎这个功能无效，原因未知
let g:ctrlsf_auto_preview = 0
" 定义上下文的数量
let g:ctrlsf_context = '-B 5 -A 3'
" 根据项目文件，如 .svn .git 等等来确定项目根目录(因为我们当前有 Rooter 插件)
let g:ctrlsf_default_root = 'project'
let g:ctrlsf_extra_root_markers = ['.root', '.workspace', 'pyproject.toml']

" 结果不要默认折叠，需要的时候我们手动折叠即可
let g:ctrlsf_fold_result = 0
" 让每个窗口有独立面板
let g:ctrlsf_position = 'left_local'
let g:ctrlsf_compact_position = 'bottom_inside'
" 切换窗口的打开和关闭
nnoremap <leader>cfit :CtrlSFToggle<CR>
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
let g:stargate_limit = 800
nnoremap <c-;> <Cmd>call stargate#OKvim('\<')<cr>| " 跳转: 跳转到某一个关键字
" :TODO: bug: 有些字符无法显示高亮(╛ ┛)，─ 字符确莫名奇妙的显示了高亮
noremap <M-;> <Cmd>call stargate#OKvim("[\\+\\.\\'\\^v<>┼┤├╭╮╯╰┣┳┻┏┗╬╣╠╔╗╝╚╨╧╥╤╟╞╜╛╙╘╖╕╓╒┍┎┑┒┕┖┙┚┝┞┟┠┡┢┥┦┧┨┩┪┭┮┯┰┱┲┵┶┷┸┹┺┽┾┿╀╁╂╃╄╅╆╇╈╉╊┌┐└┘┛\\)❫⟫▲▼◀▶△▽◁▷┬┴╋┫┓╦╩╫╪╢╡]")<CR>
nnoremap <c-s-:> <Cmd>call stargate#Galaxy()<cr>| " 跳转: 跳转到某一个窗口
" vim9-stargate 插件配置 }

" vim-fugitive 插件按键绑定 {
" 显示所有差异
nnoremap <silent> <leader>gda :Git difftool -y<cr>| " git:diff 显示所有差异
" commit 全对比
nnoremap <silent> <leader>gdc :execute 'Git! difftool ' . getreg('a') . ' ' . getreg('b') . ' --name-status'<CR>| " git:diff 对比两个commit
" 分支全对比
nnoremap <silent> <leader>gdb :execute 'Git! difftool ' . getreg('a') . ' --name-status'<CR>| " git:diff 对比两个分支或者两个commit(以当前的作为基准)
" 执行单文件对比(commit id 和 分支)
nnoremap <silent> <leader>gdd :execute 'Gvdiffsplit ' . getreg('a')<CR>| " git:diff 执行单文件对比
nnoremap <silent> <leader>gdv :call DiffQuickfixEntryWithA()<CR>
nnoremap <silent> <leader>gdn :call DiffQuickfixNextEntryWithA()<CR>

" 对比当前文件
nnoremap <silent> <leader>gdf :execute 'Gvdiffsplit'<CR>| " git:diff 对比当前文件

nnoremap <silent> <leader>gbn :Git checkout -b | "         git:branch 基于当前分支创建一个新分支
nnoremap <silent> <leader>gbl :execute 'Git branch'<CR>| " git:branch 查看所有本地分支
nnoremap <silent> <leader>gbc :execute 'normal "xyiw' \| execute 'Git checkout ' . getreg('x') \| close<CR>| "   git:branch 切换分支
vnoremap <silent> <leader>gbc y:execute 'Git checkout ' . shellescape(@0) \| close<CR>| "                        git:branch 切换分支
" 删除一个本地分支
nnoremap <silent> <leader>gbxl :execute 'normal "xyiw' \| execute 'Git branch -d ' . getreg('x') \| bwipeout \| execute 'Git branch'<CR>| " git:branch 删除一个本地分支
vnoremap <silent> <leader>gbxl y:execute 'Git branch -d ' . shellescape(@0) \| bwipeout \| execute 'Git branch'<CR>| "                      git:branch 删除一个本地分支
nnoremap <silent> <leader>gbxfl :execute 'normal "xyiw' \| execute 'Git branch -D ' . getreg('x') \| bwipeout \| execute 'Git branch'<CR>| "git:branch 删除一个本地分支
vnoremap <silent> <leader>gbxfl y:execute 'Git branch -D ' . shellescape(@0) \| bwipeout \| execute 'Git branch'<CR>| "                     git:branch 删除一个本地分支

" 删除一个远程分支
nnoremap <silent> <leader>gbxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -d ' . branchname<CR>| "  git:branch 删除一个远程分支
nnoremap <silent> <leader>gbxfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -D ' . branchname<CR>| " git:branch 删除一个远程分支

" 查看所有的远程分支
nnoremap <silent> <leader>gbr :execute 'Git remote prune origin' \| execute 'Git branch -r'<CR>| " git:branch 查看所有在远程分支
" 拉取一个远程分支并在本地跟踪它(复制远程分支名然后检出到本地然后建立两者的跟踪关系)
" git fetch origin <远程分支名>:<本地分支名>
" git branch --set-upstream-to=origin/<远程分支名> <本地分支名>
nnoremap <silent> <leader>gbfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git fetch origin ' . branchname . ':' . branchname \| execute 'Git branch --set-upstream-to=origin/' . branchname . ' ' . branchname<CR>| " git:branch 检出一个远程分支到本地

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

nnoremap <silent> <leader>gtxl :execute 'normal "xyiw' \| execute 'Git tag -d ' . getreg('x') \| bwipeout \| execute 'Git tag -l'<CR>| " git:tags 删除一个本地标签
vnoremap <silent> <leader>gtxl y:execute 'Git tag -d ' . shellescape(@0) \| bwipeout \| execute 'Git tag -l'<CR>| " git:tags 删除一个本地标签

nnoremap <silent> <leader>gtp :execute 'normal "xyiw' \| execute 'Git push --set-upstream origin ' . getreg('x')<CR>| " git:tags 推送某个标签到远程服务器(x寄存器中存储了内容)

nnoremap <silent> <leader>gtr :execute 'Git fetch --prune --tags' \| terminal Git ls-remote --tags<CR>| " git:tags 列出所有的远程标签
" git:tags 检出某个远程标签到本地
function! CheckoutTag()
    let tagline = expand("<cfile>")
    let tagname = matchstr(tagline, '[^/]*$')
    execute 'Git fetch origin tag ' . tagname
    execute 'Git checkout tags/' . tagname
endfunction
nnoremap <silent> <leader>gtc :call CheckoutTag()<CR>

function! DeleteRemoteTag()
    let tagline = expand("<cfile>")
    let tagname = matchstr(tagline, '[^/]*$')
    execute 'Git push origin --delete tag ' . tagname
endfunction
nnoremap <silent> <leader>gtxr :call DeleteRemoteTag()<CR>

" 最终对比的时候是左旧右新
xnoremap <leader>ec :<C-u>call ExtractCommitsFromVisualRange()<CR>

function! ExtractCommitsFromVisualRange()
    " 获取选区的起止行号
    let start = getpos("'<")[1]
    let end = getpos("'>")[1]

    " 获取选中的行
    let lines = getline(start, end)

    " 初始化 commit 列表
    let commits = []

    " 正则匹配：前后有空格的 [abcdefg]，提取中间哈希
    for line in lines
        " • 2025-10-13 02:03:45 +0200 [f8e23da] {xx} FIXED: xx
        let match = matchlist(line, '\v\s\[\zs([0-9a-f]{7})\ze\]\s')
        if len(match) > 1
            call add(commits, match[1])
        endif
    endfor

    " 存入寄存器 a 和 b
    " b 是 新提交
    " a 是 旧提交
    if len(commits) >= 2
        let @b = commits[0]
        let @a = commits[-1]
        echo "Copied to registers: a = " . @a . ", b = " . @b
    else
        echo "Not enough properly bracketed commits found in selection."
    endif
endfunction

function! DiffQuickfixEntryWithA()
    " Step 1: 只保留 Quickfix 窗口
    only

    " Step 2: 模拟回车，打开光标所在的 Quickfix 项
    execute "normal! \<CR>"

    " Step 3: 执行 Gvdiffsplit 对比，使用寄存器 a 中的提交哈希
    execute "Gvdiffsplit " . getreg('a')
endfunction

function! DiffQuickfixNextEntryWithA()
    copen
    
    only

    execute "cnext"

    execute "Gvdiffsplit " . getreg('a')
endfunction

function! GetLineContentLast ()
    " 获取当前行的内容
    let line = getline('.')
    " 使用空格分割行内容
    let fields = split(line)
    " 返回最后一个域的内容
    return fields[-1]
endfunction

" :TODO: 待验证
function! QQGitDeleteRemoteTagAndRefresh()
    let l:tag = GetLineContentLast()
    " 1 表示选择的是 Yes 2 表示选择的 No
    if confirm("删除远程标签 '" . l:tag . "' ?", "&Yes\n&No") != 1
        return
    endif
    execute 'Git push origin :' . l:tag
    execute 'Git fetch --prune --tags'
  execute 'terminal Git ls-remote --tags'
endfunction
nnoremap <silent> <leader>gtxr :call QQGitDeleteRemoteTagAndRefresh()<CR>| " git:tags 删除某一个远程标签



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
vnoremap <silent> <leader>tb=<Space> :Tabularize /=<cr>
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


" " vimio 的配置{
" let g:vimio_custom_shapes_dir = expand('~/.vim/vimio_custom_shapes')
" let g:vimio_user_shapes_define_graph_functions = [
"       \ ['Vimio__DefineSmartDrawShapesanimal', [0], 0, 'my_animal1.vim'],
"       \ ['Vimio__DefineSmartDrawShapesanimal', [0], 0, 'my_animal2.vim'],
"       \ ]
" " vimio 的配置}

" 插件配置 }


" 这个语句需要最后执行，说出暂时放在配置文件的最后，给markdown/zimwiki文件加上目录序号
" :TODO: 因为保存的时候的效率问题，暂时先屏蔽掉
" autocmd BufWritePost *.md silent call GenSectionNum('markdown')
" autocmd BufWritePost *.txt silent call GenSectionNum('zim')
noremap <leader>gsnm :silent call GenSectionNum('markdown')<cr>| " markdown: markdown生成数字目录序号
noremap <leader>gsnz :silent call GenSectionNum('zim')<cr>| " zim: zim生成数字目录序号

" 替换函数快捷方式,和<leader>r和NERDTree刷新快捷键冲突
noremap <leader>rw :call MyReplaceWord('n')<CR>| " 替换: 普通模式替换当前单词
vnoremap <leader>rw :call MyReplaceWord('v')<CR>| " 替换: 可视模式替换当前单词
vnoremap <leader>rn :call VisualReplaceWord()<CR>| " 替换: 可视模式替换选择区域复制的单词为新单词

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
        " 用 filter 先筛出匹配项
        let matched = filter(copy(g:complete_list_all),
                    \ 'has_key(v:val, "icase") && v:val.icase ? v:val.word =~ "\\c" . a:base : v:val.word =~ "\\C" . a:base')

        for item in matched
            " 匹配不区分大小写
            " 据说matchstr效率更高?
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
        endfor
        return res
    endif
endfunction

" 设置默认的用户自定义补全函数
" c-x c-u(并不是 c-x c-o)
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
nnoremap <leader>ra :%s/\%x00/\r/g<cr>| " 编辑: 普通模式替换文本中的^@为换行
vnoremap <leader>ra :s/\%x00/\r/g<cr>| " 编辑: 可视模式替换文本中的^@为换行

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
nnoremap <silent> <leader>smm :call DeleteMarks(input('Enter marks to delete (space-separated): '))<CR>| " 辅助: 手动删除一个标记列表



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
nnoremap <silent> <leader>sms :call PopupMenuShowKeyBindings('and', 'auto', ':SortMarks')<cr>| " 辅助: 静态显示当前文件所有marks标记

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

" (加粗)zim语法创建新的命令，$*，来调用这个函数
vnoremap <silent> S* :call SurroundWith(['**', '**'], visualmode(), '')<CR>| " 编辑: 双*包围无空格(加粗)
" (删除)zim语法创建新的命令，$~，来调用这个函数
vnoremap <silent> S~ :call SurroundWith(['~~', '~~'], visualmode(), '')<CR>| " 编辑: 双~包围无空格(删除)
" (高亮)zim语法创建新的命令，$_，来调用这个函数
vnoremap <silent> S_ :call SurroundWith(['__', '__'], visualmode(), '')<CR>| " 编辑: 双_包围无空格(高亮)
" (斜体)zim语法创建新的命令，$/，来调用这个函数
vnoremap <silent> S/ :call SurroundWith(['//', '//'], visualmode(), '')<CR>| " 编辑: 双/包围无空格(斜体)
" (内联代码)zim语法创建新的命令，$''，来调用这个函数
vnoremap <silent> S'' :call SurroundWith(["''", "''"], visualmode(), '')<CR>| " 编辑: 双'包围无空格(内联代码)


" 增加映射手动重置当前的viminfo
nnoremap <leader>svm :call SaveGlobalMarkComments()<cr> \| :call SetProjectViminfo()<cr>| " 辅助: 重置当前环境的viminfo(切换新项目时)

" 代码笔记跳转功能 {
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
        let l:full_path = GetCurrentFileAndPath()
    elseif strpart(l:relative_path, 0, 1) == '+'
        let l:full_path = GetCurrentPath() . '/' . strpart(l:relative_path, 1)
    else
        " 得到获取路径的顶级路径
        let father_dir_name = split(l:relative_path, '/')[0]
        let father_path = FindCustomDir(father_dir_name)
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

function! GetCurrentFileAndPath()
    " 获取当前文件的绝对路径和行号
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')
    return l:absolute_path
endfunction

function! GetCurrentPath()
    " 获取当前文件的绝对路径
    let l:absolute_path = expand('%:p')
    let l:absolute_path = substitute(l:absolute_path, '\\', '/', 'g')
    let l:path_only = fnamemodify(l:absolute_path, ':h')
    return l:path_only
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
" [{[os/os_uname_a.sh:12]}]
function! RecordCodePathAndLineToSystemReg()
    " 计算相对路径
    let l:full_path = GetCurrentFileAndPath()
    if empty(l:full_path)
        return
    endif

    let l:line_number = line('.')

    " 生成路径和行号字符串
    let l:result = '[{[' . l:full_path . ';' . l:line_number . ']}]'
    let @+ = l:result
endfunction

" 当前只支持.git目录和.root文件
function! FindRootDir()
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

"function! FindCustomDir(target_dir)
"    let l:current_dir = expand('%:p:h')
"    let l:current_dir = substitute(l:current_dir, '\\', '/', 'g')

"    while l:current_dir != '/' && l:current_dir !~ '^[A-Za-z]:/$'
"        " 这个原始的实现有一个BUG
"        " strip\strip1\strip2
"        "     strip1.txt {[{id:能连接到我吗}]}
"        "     strip2\
"        "     stripx\
"        "         strip1.txt [{[strip2/strip1.txt;#能连接到我吗]}]
"        " 
"        " 按照当前的逻辑 strip2 和 strip\strip1\strip2 拼接的目录是存在的,所以最终组合成的完成路径是:
"        "     strip\strip1\strip2\strip2\strip1.txt 显然我们的锚点不在这里，我们的锚点在
"        "     strip\strip1\strip2\strip1.txt
"        " 有一种改进的方法是同时验证下文件是否存在,如果不存在就继续查找
"        if isdirectory(l:current_dir . '/' . a:target_dir)
"            return l:current_dir
"        endif
"        let l:current_dir = fnamemodify(l:current_dir, ':h')
"    endwhile
"    return ''
"endfunction

" :TODO: 其实这个也有缺陷,无法处理目录名和文件名都重复的情况
function! FindCustomDir(target_path)
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


" 锚点的格式
" {[{id:这是一个锚点}]}
" 定义快捷方式在锚点上生成指向锚点的链接并保存到系统剪切板中
" [{[src/os/os_uname_a.sh:#这是一个锚点]}]
function! RecordHunkToSystemReg()
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

    let l:full_path = GetCurrentFileAndPath()
    if empty(l:full_path)
        return
    endif

    let l:matches_list = matchlist(match_str, '\v\{\[\{id:([^\{\}\[\]]+)\}\]\}')
    let l:hunk_str = '[{[' . l:full_path . ';#' . l:matches_list[1] . ']}]'
    let @+ = l:hunk_str
endfunction

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
        let l:full_path = GetCurrentFileAndPath()
    elseif strpart(l:relative_path, 0, 1) == '+'
        let l:full_path = GetCurrentPath() . '/' . strpart(l:relative_path, 1)
    else
        " 得到获取路径的顶级路径
        let father_dir_name = split(l:relative_path, '/')[0]
        let father_path = FindCustomDir(l:relative_path)
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

" 在当前位置插入一个hunk
function! CreateNewHunkToSystemReg()
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

" 在当前位置插入代码链接
function! InsertCodePath()
    " 获取默认截切板寄存器中的内容
    let system_reg_str = getreg('+')
    let system_reg_list = matchlist(system_reg_str, '\v\[\{\[([^\[\]\{\};]+);(\d+)\]\}\]')
    " echo "system_reg_str:" . system_reg_str . ';' . "system_reg_list:" . string(system_reg_list) . ';'
    let [full_path_file, line_num] = [system_reg_list[1], system_reg_list[2]]
    let record_file = fnamemodify(full_path_file, ':t')
    let record_path = fnamemodify(full_path_file, ':h')

    let cur_path_file = GetCurrentFileAndPath()

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


" 在当前位置插入hunk链接
function! InsertHunkPath()
    " 获取默认截切板寄存器中的内容
    let system_reg_str = getreg('+')
    let system_reg_list = matchlist(system_reg_str, '\v\[\{\[([^\[\]\{\};#]*);#([^\[\]\{\};#]+)\]\}\]')

    let [full_path_file, hunk_str] = [system_reg_list[1], system_reg_list[2]]
    let record_file = fnamemodify(full_path_file, ':t')
    let record_path = fnamemodify(full_path_file, ':h')

    let cur_path_file = GetCurrentFileAndPath()

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



" :TODO: 后续如果中括号和冒号不够防呆,可以使用另外的特殊的unicode字符替代,或者使用更多的边界字符防呆,不过目前这样就够
nnoremap <silent> <leader>jj :call JumpToCode()<CR>
nnoremap <silent> <leader>jl :call RecordCodePathAndLineToSystemReg()<CR>
nnoremap <silent> <leader>jr :call RecordHunkToSystemReg()<CR>
nnoremap <silent> <leader>jh :call JumpToHunkPoint()<CR>
nnoremap <silent> <leader>jn :call CreateNewHunkToSystemReg()<CR>
nnoremap <silent> <leader>jc :call InsertCodePath()<CR>
nnoremap <silent> <leader>jk :call InsertHunkPath()<CR>
" 插入代码链接
" 插入锚点链接

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
    let g:slide_files = glob('*.*', 0, 1)
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

command! DetectSlides call DetectSlides()
command! NextSlide call NextSlide(0)
command! PrevSlide call PrevSlide()
command! SlideInfo call ShowSlideInfo()
command! StartSlideshow call StartSlideshow()
command! -nargs=1 StartAutoSlideshow call StartAutoSlideshow(<args>)
command! StopAutoSlideshow call StopAutoSlideshow()


" 文本幻灯片功能 }

" 智能绘图的zim markup模式
" {
" ▫gge▫ 这个代表行内代码 ''行内代码''
" ▪gge▪ 这个代表高亮 **加粗**
" ◖gge◗ 这个代表高亮 __高亮__
" ◤gge◥ 这个代表斜体 //斜体//
" ◢gge◣ 这个代表删除线 ~~删除线~~

" :TODO: 文本中的zim链接和锚点(非自定义链接和锚点)
" 用一组特殊的符号和文本来表示
" 符号和对应的文本记录上每个链接对应的值,用于替换符号组的时候还原
" 这里要特别小心，怎么才能防止链接丢失？
" :TODO: 需要5个增加markup的快捷方式
" 需要一个增加链接的快捷方式(在底部的输入位置输入链接和现实的字符，生成符号组,如果符号超过限制)
" :TODO: zim内部锚点如何处理?vim中很好处理，但是在zim中那个锚点的贴图无法对齐。

let g:zim_inner_links = {}
" zim软件中锚点的文件是 zim\share\zim\pixmaps\pilcrow.png 这是一个png的图像,大小是固定的
" 但是代码中会缩放它，所以直接替换它是没有意义的
" 但是在 D:\programs\config\zim\style.conf中可以配置图标的大小
" [TextView]
" bullet_icon_size=GTK_ICON_SIZE_LARGE_TOOLBAR
" indent=30
" tabs=None
" ... ...
"
" 图标的大小可以配置的值有下面这些
" GTK_ICON_SIZE_MENU：适用于菜单中的图标，大小为 16 像素。
" GTK_ICON_SIZE_SMALL_TOOLBAR：适用于小工具栏的图标，大小为 16 像素。
" GTK_ICON_SIZE_LARGE_TOOLBAR：适用于大工具栏的图标，大小为 24 像素。
" GTK_ICON_SIZE_BUTTON：适用于按钮的图标，大小为 16 像素。
" GTK_ICON_SIZE_DND：适用于拖放操作的图标，大小为 32 像素。
" GTK_ICON_SIZE_DIALOG：适用于对话框的图标，大小为 48 像素。
"
"
" 然后我发现一个有趣的事情，当把图标的大小设置为GTK_ICON_SIZE_LARGE_TOOLBAR的时候，
" 字体为 MSYH ProgmataPro Mono Normal 9号的时候，正好图标占据4个字符的位置，可以完美对齐。
" 但是有锚点的列就会比别的列要高，显得有点奇怪
"
" 或者把图标的大小设置为GTK_ICON_SIZE_BUTTON,这个时候需要把MSYH ProgmataPro Mono Normal
" 字体设置为12号字体，这样锚点图标刚才占据了两个字符的空间。这或许更好。
" 如果把字体调整为6号，那么锚点占据4个字符
"
" zim的锚点导出还有问题，导出后的文本无法链接,所以干脆全部用我自己定义锚点更好。
" :TODO:还是应该把emacs的锚点导航两个功能实现
" 还有一个办法，如果要导出到html,可以用vim先处理下当前文件中的锚点。然后再显示或者打印
" 如果不想显示又可以用vim方便还原。
"

function! DeleteAndReplaceZimMarkupCharsForBuffer()
    " 获取当前缓冲区的所有行数
    let total_lines = line("$")

    for line_num in range(1, total_lines)
        let line_content = getline(line_num)
        " 不知道为什么 vim不支持正则表达式中使用+,所以这里用了[^'][^']*
        let line_content = substitute(line_content, " ''\\([^'][^']*\\)'' ", '▫\1▫', "g")
        let line_content = substitute(line_content, ' __\([^_][^_]*\)__ ', '◖\1◗', "g")
        let line_content = substitute(line_content, ' \*\*\([^*][^*]*\)\*\* ', '▪\1▪', "g")
        let line_content = substitute(line_content, ' //\([^/][^/]*\)// ', '◤\1◥', "g")
        let line_content = substitute(line_content, ' \~\~\([^~][^~]*\)\~\~ ', '◢\1◣', "g")

        " " 先不考虑链接的情况
        " " 替换两对中括号中间的连接和竖线
        " let line_content = substitute(line_content, "\\[\\[[^|]+|\\([^]]+\\)\\]\\]", "\\1", "g")
        
        " 将替换后的内容设置回当前行
        call setline(line_num, line_content)    
    endfor
endfunction

function! RecoverZimMarkupCharsForBuffer()
    " 获取当前缓冲区的所有行数
    let total_lines = line("$")

    for line_num in range(1, total_lines)
        let line_content = getline(line_num)
        let line_content = substitute(line_content, '▫\([^▫][^▫]*\)▫', " ''\\1'' ", "g")
        let line_content = substitute(line_content, '◖\([^◖◗][^◖◗]*\)◗', ' __\1__ ', "g")
        let line_content = substitute(line_content, '▪\([^▪][^▪]*\)▪', ' \*\*\1\*\* ', "g")
        let line_content = substitute(line_content, '◤\([^◤◥][^◤◥]*\)◥', ' //\1// ', "g")
        let line_content = substitute(line_content, '◢\([^◢◣][^◢◣]*\)◣', ' \~\~\1\~\~ ', "g")

        " 将替换后的内容设置回当前行
        call setline(line_num, line_content)    
    endfor
endfunction

" :TODO: 增加插入5种符号和链接的快捷键(可视插入,不影响当前列的物理位置排列)
" 算了,不做实现,直接简单的添加到智能图形图中即可

" 设置快捷键 F12 来交替调用两个函数
nnoremap <silent> sh :call ToggleZimMarkupChars()<CR>

function! ToggleZimMarkupChars()
    if exists('g:zim_markup_chars_enabled') && g:zim_markup_chars_enabled
        " 如果已启用，执行恢复函数
        call RecoverZimMarkupCharsForBuffer()
        let g:zim_markup_chars_enabled = 0
        echo "已切换到恢复模式"
    else
        " 如果未启用，执行删除和替换函数
        call DeleteAndReplaceZimMarkupCharsForBuffer()
        let g:zim_markup_chars_enabled = 1
        echo "已切换到删除和替换模式"
    endif
endfunction

" }


" 函数的实现方案如下:
" 如果有锚点,那么连续两次就可以跳转过去
" 使用vim在当前的位置生成一个随机锚点,然后跳转过去
" 锚点的名字可以用当前的时间,这行避免冲突的可能
" 跳转完成后再让vim删除添加的这个临时锚点
" 然后执行zim的刷新功能更新页面,然后往右移动一下光标(:TODO:这里暂时不做自动化,自己按一下ctrl+r刷新下页面)
" :TODO:可以执行一个zim的插件,插件执行刷新当前页面并且把光标往右移动一位的操作
" zim --gui zim_book "项目管理:北辰项目:项目进度整理:5902参数"
" zim --gui zim_book "项目管理:北辰项目:项目进度整理:5902参数#不上次"
function! JumpToZimPagePosition()
    " 生成当前的时间戳
    let timestamp = strftime("%Y%m%d%H%M%S")
    " 当前位置插入临时锚点
    let id_string = "{{id: " . timestamp . "}}"
    execute "normal! i" . id_string    
    " 保存当前文件
    write
    " 获取当前zim日记本的名字(根目录下有.git文件夹或者.root文件,通过这个识别)
    let root_dir = FindRootDir()
    let notebook_name = fnamemodify(root_dir, ':t')
    " 获取笔记本的相对索引
    let relative_path = GetRelationPath()
    " 去掉扩展名.txt
    let relative_path = fnamemodify(relative_path, ':r')
    " /替换成冒号:
    let relative_path = substitute(relative_path, '/', ':', 'g')
    " 通过系统命令打开笔记本实例(多次打开也会在一个实例)
    " zim.exe的路径需要被添加到环境变量中
    let command_str = 'zim --gui ' . notebook_name . ' ' . relative_path . '#' . timestamp
    " vim实例不能关闭,如果关闭了zim也会一起被关闭
    " 这里使用参数就可以保证在一个实例中打开zim(只要保证所有打开实例的根目录相同即可)
    let job_opts = {'cwd': root_dir}
    call job_start(command_str, job_opts)
    sleep 1
    call job_start(command_str, job_opts)
    " 这里靠延时还有有一定的缺陷,因为如果GUI界面还没来得及跳转到锚点,vim就删除锚点,会导致跳转失败
    sleep 3
    " 最后一个步骤,删除添加的临时锚点并保存文件
    let lnum = line('.')
    let current_line = getline(lnum)
    let modified_line = substitute(current_line, '{{id: ' . timestamp . '}}', '', 'g')
    call setline(lnum, modified_line)
    write
    " :TODO: 下面这里似乎无法正常调用,现在并不知道插件调用方法
    " let command_str = 'zim --plugin refresh_and_move --action refresh_and_move'
    " call job_start(command_str, job_opts)
endfunction

" 跳转到zim的文件和位置
nnoremap <silent> s; :call JumpToZimPagePosition()<CR>


" 工具栏的配置放到最后
set guioptions+=T
" set guioptions+=m

function! ToolBarGroup1()
    aunmenu ToolBar
    " menu SlideShow.SlideShow\ Menu.Next :PrevSlide<CR>
    " menu SlideShow.Start :StartSlideshow<CR>
    " menu SlideShow.Next :NextSlide<CR>
    " menu SlideShow.Prev :PrevSlide<CR>
    " menu SlideShow.Info :SlideInfo<CR>

    " https://yyq123.github.io/learn-vim/learn-vi-39-ToolBar.html
    " http://www.ub-filosofie.ro/~solcan/wt/gnu/v/vim-toolbar-icon.html
    " :TODO: 这行配置好像并没有起作用
    set toolbar=icons,text,tooltips
    " 为当前工具栏组增加两个不同的分隔符
    amenu ToolBar.-sep8- <Nop>
    amenu ToolBar.-sep9- <Nop>
    " :TODO: 如果使用同一个内建图标挂载到不同的功能上?自定义的图标是很好实现的。
    " :TODO: 目前工具栏的图标只能显示一行，如果图标多了，后面的图标看不见，如何显示多行？
    " :TODO: 如果无法实现多行显示可以考虑用一个快捷键来切换工具栏(定义不同的工具栏组)
    " :aunmenu ToolBar 移除工具栏上所有按钮
    " :aunmenu ToolBar.BuiltIn4 移除工具栏上的某个按钮
    " 在工具栏图标的提示字符中可以提示快捷按键的值,后面查找TAG啊生成TAG啊
    " 之类的快捷键都可以用这种方式实现
    amenu ToolBar.BuiltIn18 :StartSlideshow<CR>
    amenu ToolBar.BuiltIn23 :NextSlide<CR>
    amenu ToolBar.BuiltIn22 :PrevSlide<CR>
    amenu ToolBar.BuiltIn24 :SlideInfo<CR>
    amenu ToolBar.BuiltIn4 :StartAutoSlideshow 1000<CR>
    amenu ToolBar.BuiltIn17 :StopAutoSlideshow<CR>


    tmenu ToolBar.BuiltIn18 start slide show
    tmenu ToolBar.BuiltIn23 next slide
    tmenu ToolBar.BuiltIn22 prev slid
    tmenu ToolBar.BuiltIn24 slide info
    tmenu ToolBar.BuiltIn4 start auto slide show
    tmenu ToolBar.BuiltIn17 stop auto slide show

    " 这里的目的是用工具栏来定制调试按钮，释放出F1~F12
    amenu ToolBar.BuiltIn19 :call DeleteAndRecordMarkupChars()<CR>
    tmenu ToolBar.BuiltIn19 delete zim markup chars
endfunction

function! ToolBarGroup2()
    aunmenu ToolBar
    " vimspector 调试插件配置2 {
    " :TODO: 很多图标是不匹配的,后面需要自己做一些图标
    amenu ToolBar.-sep10- <Nop>
    amenu ToolBar.-sep11- <Nop>

    amenu ToolBar.BuiltIn0 <Plug>VimspectorBreakpoints| " 调试: 设置断点
    tmenu ToolBar.BuiltIn0 set breakpoints

    amenu ToolBar.BuiltIn15 <Plug>VimspectorContinue| " 调试: 继续执行或者开启调试
    tmenu ToolBar.BuiltIn15 continue

    amenu ToolBar.BuiltIn17 <Plug>VimspectorStop| " 调试: 停止调试
    tmenu ToolBar.BuiltIn17 stop

    amenu ToolBar.BuiltIn3 <Plug>VimspectorRestart| " 调试: 重启调试
    tmenu ToolBar.BuiltIn3 restart

    amenu ToolBar.BuiltIn30 <Plug>VimspectorPause| " 调试: 暂停调试
    tmenu ToolBar.BuiltIn30 pause

    amenu ToolBar.BuiltIn13 <Plug>VimspectorToggleBreakpoint| " 调试: 当前行打开和关闭断点
    tmenu ToolBar.BuiltIn13 toggle line breakpoint on the current line

    amenu ToolBar.BuiltIn9 <Plug>VimspectorToggleConditionalBreakpoint| " 调试: 当前行切换条件断点或者日志断点
    tmenu ToolBar.BuiltIn9 toggle conditional line breakpoint or logpoint on the current line

    amenu ToolBar.BuiltIn8 <Plug>VimspectorAddFunctionBreakpoint| " 调试: 为光标下的表达式添加函数断点
    tmenu ToolBar.BuiltIn8 add a function breakpoint for the expression under cursor

    amenu ToolBar.BuiltIn19 <Plug>VimspectorRunToCursor| " 调试: 一直执行到光标位置
    tmenu ToolBar.BuiltIn19 run to Cursor

    amenu ToolBar.BuiltIn22 <Plug>VimspectorStepOver| " 调试: 单步调试不进入函数
    tmenu ToolBar.BuiltIn22 step over

    amenu ToolBar.BuiltIn23 <Plug>VimspectorStepInto| " 调试: 单步调试进入函数
    tmenu ToolBar.BuiltIn23 step into

    amenu ToolBar.BuiltIn4 <Plug>VimspectorStepOut| " 调试: 跳出当前函数的作用域
    tmenu ToolBar.BuiltIn4 step out of current function scope

    amenu ToolBar.BuiltIn29 <Plug>VimspectorBalloonEval| " 调试: 悬停查看变量或者表达式
    tmenu ToolBar.BuiltIn29 hover to view variables or expressions

    amenu ToolBar.BuiltIn14 <Plug>VimspectorUpFrame| " 调试: 堆栈导航往上
    tmenu ToolBar.BuiltIn14 up frame

    amenu ToolBar.BuiltIn12 <Plug>VimspectorDownFrame| " 调试: 堆栈导航往下
    tmenu ToolBar.BuiltIn12 down frame

    amenu ToolBar.BuiltIn16 <Plug>VimspectorBreakpoints| " 调试: 切换断点窗口的显示与隐藏
    tmenu ToolBar.BuiltIn16 show or hide break points window

    amenu ToolBar.BuiltIn25 <Plug>VimspectorDisassemble| " 调试: 反汇编
    tmenu ToolBar.BuiltIn25 disassembly 
    " }
endfunction

let g:toolbar_config = {
    \ 'current': 1,
    \ 'groups': ['ToolBarGroup1', 'ToolBarGroup2']
    \ }

function! ToggleToolBarGroup()
    let next_index = (g:toolbar_config['current'] + 1) % len(g:toolbar_config['groups'])
    let g:toolbar_config['current'] = next_index
    execute 'call ' . g:toolbar_config['groups'][g:toolbar_config['current']] . '()'
endfunction

nnoremap <silent> s, :call ToggleToolBarGroup()<CR>

" 自动翻译相关的配置 {
" 首先需要使用 alt+= 打开默认终端
" 然后再进行下面的所有操作

" 下面的两个代理一般情况下不需要，如果说需要代理才能访问那么可以考虑加上
" let $http_proxy = 'xx:8080'
" let $https_proxy = 'yy:8080'

" 简短的翻译(中->英)
vnoremap <leader>te y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TransToTerminal(1, 'en')<CR>
" 完整的翻译(中->英)
vnoremap <leader>tf y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TransToTerminal(0, 'en')<CR>

" 简短的翻译(英->中)
vnoremap <C-t> y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TransToTerminal(1, 'zh')<CR>
" 完整的翻译(英->中)
vnoremap <C-S-T> y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TransToTerminal(0, 'zh')<CR>

" 简单情况进行替换
nnoremap <leader>p :call PasteTerminalToBuffer(1, g:TRANSLATE_SELECTION_MODE)<CR>
" 复杂情况进行替换
nnoremap <leader><S-P> :call PasteTerminalToBuffer(0, g:TRANSLATE_SELECTION_MODE)<CR>

function! BashANSIQuote(s)
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

" 用于发送字符到bash终端.
function! TransToTerminal(isBrief, language)
    " 按行拆分
    let l:lines = split(@", "\n")

    " 根据语言合并句子(目标和源是反的)
    if a:language ==# 'en'
        " 中文：直接连接，不加空格
        let l:merged = join(l:lines, '')
    else
        " 英文：连接时加空格
        let l:merged = join(l:lines, ' ')
    endif

    let l:ascii_quote = BashANSIQuote(l:merged)

    " 构造命令
    " ⚠️ cygwin 环境下可能需要修改 trans 脚本的 shebang：
    "    把 #!/bin/bash 改成 #!/usr/bin/bash 才能正常运行（原因未知）
    " 某些环境下会有奇怪的标准错误输出，屏蔽掉
    let l:cmd = 'clear;echo "-----------------------------";echo "";trans :' . a:language
    let l:cmd .= (a:isBrief ? " --brief " : " ") . l:ascii_quote . " 2>/dev/null;echo ''"

    " 切换到终端窗口
    call SwitchToTerminalWindow()
    sleep 100m

    " 如果不是终端模式，进入插入
    if mode() !~# 't'
        call feedkeys("i", 'n')
    endif

    " 发送命令
    let l:term_bufnr = bufnr('%')
    call term_sendkeys(l:term_bufnr, l:cmd . "\n")
endfunction

function! SwitchToTerminalWindow()
    for win in range(1, winnr('$'))
        if getwinvar(win, '&buftype') ==# 'terminal'
            execute win . 'wincmd w'
            return
        endif
    endfor
    echo "⚠️ 没有找到终端窗口，保持当前窗口"
endfunction



function! PasteTerminalToBuffer(isBrief, selection_mode)
    execute "normal! G"
    " 往前找到最近的分隔符
    execute "normal! ?" . "-----------------------------" . "\<CR>"
    execute "normal! jj"

    if ! a:isBrief
        execute "normal! }j"
    endif

    " 在终端上Vi}可能失效，具体原因未知，可以换下面一种也能达到目的
    " execute "normal! Vi}"

    if a:selection_mode ==# 'v'
        execute "normal! 0"
        execute "normal! v}k$"
    elseif a:selection_mode ==# 'V'
        execute "normal! V}k"
    endif

    normal! "+y
    execute "wincmd k"

    " 获取剪贴板内容
    let clipboard_content = getreg('+')

    " 去掉换行符，将内容连接成一行
    let processed_content = substitute(clipboard_content, '\n', '', 'g')

    " 将处理后的内容放回剪贴板
    call setreg('+', processed_content)

    normal! gv
    normal! p
endfunction

" 自动翻译相关的配置 }

" 让鼠标也可以进入可视块选择模式(由于前面的按键相互覆盖，所以只能把这个放最后)
nnoremap <M-LeftMouse> <C-S-V>

" 复制系统消息到剪切板
command! CopyMessages execute('redir @+ | silent messages | redir END') | echo "已复制 :messages 到系统剪贴板"

" 清空 messages 历史
command! ClearMessages silent! messages clear | echo "消息历史已清空"

" 映射插入模式下和全局替换模式(R/gR)下的快速移动，不能映射 <C-h> 会发生删除
inoremap <C-S-J> <Down>
inoremap <C-S-H> <Left>
inoremap <C-S-L> <Right>
inoremap <C-S-K> <Up>

" 普通模式下的 gg=G 自动缩进，选择范围后按 = 缩进
autocmd FileType vim
      \ setlocal expandtab   " 用空格替代 Tab
      \ shiftwidth=4        " 每次缩进宽度为 4
      \ softtabstop=4       " 插入空格时用 4 个空格
      \ autoindent          " 继承上一行缩进
      \ smartindent         " 智能缩进

" 设置vim打开的时候的窗口宽度（单位为字符）
set columns=280
" 设置vim打开的时候窗口高度（单位为行）
set lines=80


" diffchar 插件配置 {

nnoremap <Leader>gdcp <Plug>GetDiffCharPair<CR>

" diffchar 插件配置 }

" vim-which-key 插件配置 {

" 不要把按键延迟的值设置得太小
set timeoutlen=400
" 这里是注册前缀
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
" 先取消 s 的特殊功能
nnoremap s <Nop>
nnoremap <silent> s :<c-u>WhichKey 's'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

let g:which_key_map = {}
let g:which_key_map_visual = {}
let g:which_key_map_s = {}

" 直接注册的方式有坑，很多限制
" let g:which_key_map.c = { 'name' : "xx" }
" let g:which_key_map.c.f = {
"             \  'name': 'ctrls搜索', 
"             \ 'i': {
"             \   'name': '忽略大小写',
"             \   'p': [':Rooter<cr><bar>:CtrlSF -I <C-r><C-w><cr>', '全项目'],
"             \   }
"             \ }

let g:which_key_map.H = {
            \ 'name' : '+help',
            \ 's' : [":call feedkeys('s')", '查看 s 键映射'],
            \ ',' : [":call feedkeys(',')", '查看 localleader 映射'],
            \ ' ' : [":call feedkeys(' ')", '查看 leader 映射'],
            \ "\<M-n>" : [":call feedkeys(\"\<M-n>\")", 'autopair jump(M-n)'],
            \ "\<M-p>" : [":call feedkeys(\"\<M-p>\")", 'autopair toggle(M-p)'],
            \ "\<M-i>" : [":call feedkeys(\"\<M-i>\")", 'region 增加(M-i)'],
            \ "\<M-o>" : [":call feedkeys(\"\<M-o>\")", 'region 减少(M-o)'],
            \ "\<C-S-G>" : [":call feedkeys(\"<C-S-G>\")", 'vimio(C-S-G)[高亮替换]'],
            \ "\<C-X>" : { 
            \   'name': "vimio(C-X)[高亮复制] (C-S-X)[高亮剪切]",
            \   's': [":call feedkeys(\"\<C-S-X>\")", 'vimio(C-S-x)[高亮取消]'],
            \   "\<CR>": [":call feedkeys(\"\<C-X>\")", 'vimio(C-X)[高亮复制]'],
            \   },
            \ "\<C-C>" : { 
            \   'name': "(C-S-C)[高亮取消]",
            \   's': [":call feedkeys(\"\<C-S-C>\")", 'vimio(C-S-C)[高亮取消]'],
            \   },
            \ "\<C-E>" : [":call feedkeys(\"\<C-E>\")", '调整窗口大小(C-E)'],
            \ '<F3>' : [":call feedkeys(\"\<F3>\")", '打开文件浏览器'],
            \ '<F4>' : [":call feedkeys(\"\<F4>\")", '切换Tagbar显示'],
            \ '<F5>' : [":call feedkeys(\"\<F5>\")", '切换主题'],
            \ '<F8>' : [":call feedkeys(\"\<F8>\")", '切换NERDTree'],
            \ }


let g:which_key_map.t = {
            \ 'name': "terminal, table mode, vimio",
            \ 't': "table mode 根据当前选择范围自动创建表格",
            \ '4': "4向纯文本选择(vimio)",
            \ '8': "8向纯文本选择(vimio)",
            \ 'b' : { 
            \   'name': "buffer",
            \   'd': "删除所有的终端buffer",
            \   },
            \ 'm': "表格编辑模式切换",
            \ }

let g:which_key_map_visual.t = {
            \ 'name': "table mode, translate, 对齐",
            \ 't': "table mode 根据当前选择范围自动创建表格",
            \ 'e': "简短的翻译(中->英)",
            \ 'b' : { 
            \   'name': "table mode",
            \   ' ': "空格对齐",
            \   '=': { 
            \     "name": "等号对齐",
            \     ' ': "=对齐",
            \     '>': "=>对齐",
            \     },
            \   ':': ":对齐",
            \   '-': { 
            \     "name": "对齐",
            \     ">": "->对齐",
            \     },
            \   },
            \ }
" --------------------显示相关-------------------------------------------------

" --------------------ale, 标记, vimio-----------------------------------------
let g:which_key_map.a = {
            \ 'name': "ale, (vimio)border 选择",
            \ 'f': "关闭ale语法检查",
            \ 'o': "打开ale语法检查",
            \ 'm': { 
            \   "name": "标记注释",
            \   'a': "添加某一个标记注释",
            \   'x': "删除某一个标记注释",
            \   '4': "vimio 4向选择大盒子内部",
            \   '8': "vimio 8向选择大盒子内部",
            \   },
            \ '4': "vimio 4向选择小盒子内部",
            \ '8': "vimio 8向选择小盒子内部",
            \ }

" -------------------切换相关 vimio选择相关 标记操作---------------------------
let g:which_key_map.s = { 
            \ "name": "切换相关,vimio(solid选择),vim简单搜索,Marks 标记相关",
            \ 's': "纵向分屏",
            \ '4': "flood选择4向",
            \ '8': "flood选择8向",
            \ 'r': "形状resize start(vimio)",
            \ 'e': "形状resize end(vimio)",
            \ 'c': { 
            \   "name": "形状(vimio)",
            \   't': "改变形状类型",
            \   'c': "高亮当前列",
            \   'n': "取消高亮当前列",
            \   },
            \ 'm': { 
            \   "name": "标记操作",
            \   'm': "手动删除某个标记",
            \   's': "显示当前文件所有标记",
            \   't': "显示当前文件所有marks标记",
            \   'x': "关闭显示当前文件所有marks标记",
            \   'u': "更新显示当前文件所有marks标记",
            \   'd': "删除当前文件所有的小写字母标记",
            \   'D': "删除当前文件所有的大写字母标记",
            \   'n': "添加下一个小写字母标记",
            \   'N': "添加下一个大写字母标记",
            \   },
            \ 'o': { 
            \   "name": "语法高亮",
            \   "n": "语法高亮打开",
            \   'f': "语法高亮关闭",
            \   'd': "放射线选择8向(vimio)",
            \   's': "放射线选择4向(vimio)",
            \   },
            \ 'v': { 
            \   "name": "viminfo",
            \   "m": "手动重置当前的viminfo",
            \   },
            \ 'w': { 
            \   "name": "vim简单搜索",
            \   "a": "搜索当前光标下的单词全词自动搜索",
            \   "m": "当前文件全词手动搜索",
            \   },
            \ }
" ------------------ vim 配置文件相关 替换 横向分屏-----------------------------
let g:which_key_map.v = { 
            \ "name": "编辑器配置文件,vimgrep",
            \ 'r': "重载vim配置文件",
            \ 's': "vim内置替换功能",
            \ 'v': "窗口横向分屏",
            \ 'e': { 
            \   "name": "虚拟文本",
            \   'a': "设置虚拟文本",
            \   'n': "关闭虚拟文本",
            \   'r': "重载vim的配置文件",
            \   },
            \ 'g' : { 
            \   "name": "vimgrep",
            \   "i": { 
            \     "name": "ignorecase",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     'w': { 
            \       "name": "全词匹配",
            \       "p": "项目搜索",
            \       "c": "当前目录递归",
            \       "d": "仅限当前目录",
            \       "f": "仅限当前文件",
            \       },
            \     },
            \   "s": { 
            \     "name": "大小写敏感",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     },
            \   "w": { 
            \     "name": "大小写敏感,全词匹配",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     },
            \   }
            \ }

let g:which_key_map_visual.v = { 
            \ "name": "vimgrep",
            \ 'g' : { 
            \   "name": "vimgrep",
            \   "i": { 
            \     "name": "ignorecase",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     'w': { 
            \       "name": "全词匹配",
            \       "p": "项目搜索",
            \       "c": "当前目录递归",
            \       "d": "仅限当前目录",
            \       "f": "仅限当前文件",
            \       },
            \     },
            \   "s": { 
            \     "name": "大小写敏感",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     },
            \   "w": { 
            \     "name": "大小写敏感,全词匹配",
            \     "p": "项目搜索",
            \     "c": "当前目录递归",
            \     "d": "仅限当前目录",
            \     "f": "仅限当前文件",
            \     },
            \   },
            \ }

" ------------------------ctrlsf 收缩------------------------------------------

let g:which_key_map.c = { 
            \ "name": "ctrlsf搜索,收缩级别",
            \ "c": { 
            \   "name": "收缩级别设置",
            \   "0": "conceallevel 级别 0",
            \   "2": "conceallevel 级别 2",
            \   },
            \ "f" : {
            \   'name': 'ctrls搜索', 
            \   'i': {
            \     'name': '不敏感',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   's': {
            \     'name': '敏感',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   'w': {
            \     'name': '敏感,全词',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   'm': { 
            \     "name": "手动",
            \     'i': { 
            \       "name": "不敏感",
            \       'p': '全项目',
            \       'c': '目录递归',
            \       'd': '目录不递归',
            \       'f': '当前文件',
            \       },
            \     's': { 
            \       "name": "敏感",
            \       'p': '全项目',
            \       'c': '目录递归',
            \       'd': '目录不递归',
            \       'f': '当前文件',
            \       },
            \     },
            \   },
            \ }

let g:which_key_map_visual.c = { 
            \ "name": "ctrlsf搜索",
            \ "f" : {
            \   'name': 'ctrlsf搜索', 
            \   'i': {
            \     'name': '不敏感',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   's': {
            \     'name': '敏感',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   'w': {
            \     'name': '敏感,全词',
            \     'p': '全项目',
            \     'c': '目录递归',
            \     'd': '目录不递归',
            \     'f': '当前文件',
            \     },
            \   },
            \ }


" --------------------本地列表操作---------------------------------------------
let g:which_key_map.l = { 
            \ "name": "locallist 操作,vimio(线选择)",
            \ "v": "locallist 中显示搜索结果", 
            \ "o": "打开 locallist", 
            \ "c": "关闭 locallist", 
            \ "n": "跳转到 locallist 的下一个项目", 
            \ "p": "跳转到 locallist 的上一个项目", 
            \ '4': '(vimio)线4向',
            \ '8': '(vimio)线8向',
            \ 'b': { 
            \   'name': '(vimio)基于线选择的 border inside 选择',
            \   'a': '选择边框和内部',
            \   'i': '只选择内部',
            \   },
            \ }

" --------------------quickfix 列表操作---------------------------------------------
let g:which_key_map.q = { 
            \ "name": "quickfix 操作",
            \ "o": "打开 quickfix", 
            \ "c": "关闭 quickfix", 
            \ "n": "跳转到 quickfix 的下一个项目", 
            \ "p": "跳转到 quickfix 的上一个项目", 
            \ }

" ------------------- leaderf 配置区域 ----------------------------------------
let g:which_key_map.f = { 
            \ 'name': "leaderf搜索",
            \ '1': "搜索自己",
            \ 'o': {
            \   "name": "目录切换", 
            \   "o": "把当前工作目录切换到项目根目录",
            \   },
            \ 'm': "搜索最近打开文件列表",
            \ 'f': "搜索函数",
            \ 'b': "搜索buffer",
            \ 't': "搜索标签文件(tags)",
            \ 'l': { 
            \   'name': "搜索当前文件",
            \   'l': "搜索当前文件行，搜索窗口不保持",
            \   'k': "搜索当前文件行,搜索窗口保持",
            \   },
            \ 'w': "搜索打开的窗口",
            \ 'r': { 
            \   'name': 'rg搜索',
            \   'm': "手动输入正则式",
            \   'b': "当前光标下的词(not -w)",
            \   'w': "当前光标下的词(-w)",
            \   'e': { 
            \     'name': "正则",
            \     'n': "(not -w)",
            \     'w': "(-w)",
            \     },
            \   'r': "打开上一次搜索",
            \   },
            \  'g': {
            \    'name': "gtags标签",
            \    'd': "跳转到定义",
            \    'r': "跳转到引用",
            \    's': "跳转到符号",
            \    'g': "跳转到字符串",
            \    'o': "重新打开最近的跳转命令",
            \    'n': "结果列表的下一个元素",
            \    'p': "结果列表的上一个元素",
            \    }
            \ }

let g:which_key_map_visual.f = { 
            \ 'name': "leaderf搜索",
            \ 'r': { 
            \   'name': "rg搜索",
            \   'b': "当前光标下的词(not -w)",
            \   'w': "当前光标下的词(-w)",
            \   'e': { 
            \     'name' : "正则表达式",
            \     'n': "(not -w)",
            \     'w': "(-w)",
            \     },
            \   },
            \ }

let g:which_key_map_s = {
            \ 'name': 'vimio,窗口管理,工具栏管理',
            \ 'c': '收缩当前窗口最底层分组只保留一个窗口',
            \ 'z': '关闭当前窗口(z代表结束)',
            \ 'e': '纵向分屏(E视觉上是纵向分屏)',
            \ 'w': '横向分屏(W视觉上是横向分屏)',
            \ 'n': '只保留当前窗口(n表示 only 只留自己)',
            \ ',': '切换图标栏分组',
            \ '.': '执行宏a内容',
            \ ';': '跳转到zim的文件和位置',
            \ 'h': '切换zim的markup char的显示与隐藏',
            \ 'a': '(vimio)自动添加箭头',
            \ 'g': '(vimio)模板集切换',
            \ 'b': '(vimio)模板lev1逆序切换',
            \ 'f': '(vimio)模板lev1正序切换',
            \ 'k': '(vimio)模板lev2步长切换',
            \ 'd': '(vimio)停止光标移动自动高亮',
            \ 'i': '(vimio)开始光标移动自动高亮',
            \ 'j': '(vimio)开始光标移动自动移除高亮',
            \ 'l': { 
            \   'name': '切换或者显示线型',
            \   'c': '切换线型',
            \   's': '显示线型',
            \   },
            \ 'u': '(vimio)根据当前光标下的字符切换线型',
            \ 'o': '(vimio)预览跟随模式开启',
            \ 'q': '(vimio)预览跟随模式关闭',
            \ 'p': '(vimio)当前位置粘贴一个字符',
            \ 's': { 
            \   'name': '(vimio)搜索和shape',
            \   's': '搜索stencil',
            \   'b': '绘制一个盒子',
            \   'r': '形状resize开始',
            \   'e': '形状resize结束',
            \   't': '形状改变类型',
            \   },
            \ 'y': '(vimio)拷贝单个字符',
            \ 't': '(vimio)切换预览是否透明',
            \ 'v': '(vimio)预览clip中内容',
            \ 'm': { 
            \   'name': '(vimio)智能线操作',
            \   'c': '取消绘制',
            \   'd': '切换直斜',
            \   'e': '结束绘制',
            \   'f': '切换方向',
            \   'r': '识别高亮选择线并且重新调整大小',
            \   's': '开始绘制或者继续绘制',
            \   'x': '交叉模式切换',
            \   'a': { 
            \     'name': '(vimio)箭头操作',
            \     'e': '结束箭头切换显示和隐藏',
            \     's': '开始箭头切换显示和隐藏',
            \     'f': '切换箭头的开始和结尾',
            \     },
            \ },
            \ 'x': { 
            \   'name': '(vimio)交叉模式管理',
            \   'm': '切换交叉模式的打开和关闭',
            \   's': '切换交叉模式的样式',
            \   'h': '切换对齐提示线的打开和关闭',
            \ },
            \ }

let g:which_key_map.i = {
            \ 'name': '(vimio) inside border,对齐线',
            \ 'g': '切换对齐线显示与隐藏',
            \ '4': '(vimio)小环4向',
            \ '8': '(vimio)小环8向',
            \ 'm': { 
            \   'name': '(vimio)大环',
            \   '4': '(vimio)大环4向',
            \   '8': '(vimio)大环8向',
            \   },
            \ }

let g:which_key_map.r = {
            \ 'name': '(vimio)选择放射线和框以及内部,NERDTree',
            \ '4': '(vimio)4向',
            \ '8': '(vimio)8向',
            \ 'f': '(NERDTree)进入当前文件对应目录树并且刷新目录树',
            \ 't': '(NERDTree)刷新目录树状态',
            \ 'w': '(替换)普通模式替换当前单词',
            \ 'a': '(替换)普通模式替换文本中^@为换行',
            \ }

let g:which_key_map_visual.r = {
            \ 'name': '替换',
            \ 'w': '(替换)可视模式替换当前单词',
            \ 'n': '(替换)可视模式替换文本中^@为换行',
            \ }

" -------------------- global 搜索---------------------------------------------

let g:which_key_map.g = { 
            \ 'name': 'global搜索,git',
            \ 'w': {
            \   'name': "分屏显示搜索结果",
            \   's': '查找符号',
            \   'g': '查找定义',
            \   'c': '调用此函数的函数',
            \   't': '查找字符串',
            \   'e': '查找查找正则表达式',
            \   'f': '查找文件名',
            \   'i': '查找包含当前头文件的文件',
            \   'd': '查找此函数调用的函数',
            \   'a': '查找赋值位置',
            \   'z': '在ctags数据库中查找当前单词',
            \   },
            \ 'n': {
            \   'name': '当前屏显示搜索结果',
            \   's': '查找符号',
            \   'g': '查找定义',
            \   'c': '调用此函数的函数',
            \   't': '查找字符串',
            \   'e': '查找查找正则表达式',
            \   'f': '查找文件名',
            \   'i': '查找包含当前头文件的文件',
            \   'd': '查找此函数调用的函数',
            \   'a': '查找赋值位置',
            \   'z': '在ctags数据库中查找当前单词',
            \   },
            \ 'd': { 
            \   'name': "git diff",
            \   'a': '显示所有的差异',
            \   'c': '显示两个commit的差异(@a register)',
            \   'b': '显示两个分支的差异(@a register)',
            \   'd': 'commit或者分支的单文件对比当前文件',
            \   'v': 'commit或者分支的单文件对比当前文件(quickfix)',
            \   'n': 'commit或者分支的单文件对比下一个文件',
            \   'f': '当前文件和库上最新对比',
            \   },
            \ 'g': { 
            \   'name': "vim-gitgutter 打开与关闭",
            \   'o': '打开 vim-gitgutter',
            \   'c': '关闭 vim-gitgutter',
            \   },
            \ 'b': { 
            \   'name': 'git branch',
            \   'n': '创建一个新分支',
            \   'l': '查看所有本地分支',
            \   'c': '切换到光标下的分支',
            \   'x': { 
            \     'name': '删除分支',
            \     'l': '删除光标下的本地分支',
            \     'r': '删除光标下的远程分支',
            \     'f': { 
            \       'name': "强制删除",
            \       'l': '本地分支',
            \       'r': '远程分支',
            \       },
            \     },
            \   'r': '查看所有的远程分支',
            \   'f': { 
            \     'name': 'fetch',
            \     'r': '拉取一个远程分支并在本地跟踪它',
            \     },
            \   },
            \ 'p': { 
            \   'name': 'git pull or push',
            \   'l': '拉取远程最新变更到本地',
            \   's': '推送本地最新变更到远程',
            \   },
            \ 'o': { 
            \   'name': 'git 提交历史',
            \   'g': '查看当前文件的所有提交历史',
            \   },
            \ 't': { 
            \   'name': 'git 标签管理',
            \   'a': '基于某个提交创建一个标签(@a register)',
            \   'l': '列出所有的本地标签',
            \   's': { 
            \     'name': '标签显示',
            \     'l': '显示某个本地标签明细(@x register)',
            \     },
            \   'x': { 
            \     'name': '标签删除',
            \     'l': '删除一个本地标签(@x register)',
            \     'r': '删除光标下的一个远程标签',
            \     },
            \   'p': '推送某个标签到远程服务器(@x register)',
            \   'r': '列出所有的远程标签',
            \   'c': '检出光标下的远程分支到本地',
            \   },
            \ }

let g:which_key_map_visual.g = { 
            \ 'name': 'global搜索,git(分支 tag)',
            \ 'w': {
            \   'name': "分屏显示搜索结果",
            \   's': '查找符号',
            \   'g': '查找定义',
            \   'c': '调用此函数的函数',
            \   't': '查找字符串',
            \   'e': '查找查找正则表达式',
            \   'f': '查找文件名',
            \   'i': '查找包含当前头文件的文件',
            \   'd': '查找此函数调用的函数',
            \   'a': '查找赋值位置',
            \   'z': '在ctags数据库中查找当前单词',
            \   },
            \ 'n': {
            \   'name': '当前屏显示搜索结果',
            \   's': '查找符号',
            \   'g': '查找定义',
            \   'c': '调用此函数的函数',
            \   't': '查找字符串',
            \   'e': '查找查找正则表达式',
            \   'f': '查找文件名',
            \   'i': '查找包含当前头文件的文件',
            \   'd': '查找此函数调用的函数',
            \   'a': '查找赋值位置',
            \   'z': '在ctags数据库中查找当前单词',
            \   },
            \ 'b': { 
            \   'name': '分支管理',
            \   'c': '切换到光标下的分支(@a register)',
            \   'x': { 
            \     'name': "删除分支",
            \     'l': '删除可视选择的本地分支',
            \     'f': { 
            \       'name': '强制删除',
            \       'l': '强制删除可视选择的本地分支',
            \       },
            \     },
            \   },
            \ 't': { 
            \   'name': '标签管理',
            \   'x': { 
            \     'name': '删除操作',
            \     'l': '删除光标下的一个本地标签',
            \     },
            \   },
            \ }

" --------------------------- 书签相关 ----------------------------------------
let g:which_key_map.b = { 
            \ 'name': 'bookmark, vimio(border)',
            \ 't': '切换书签打开与关闭',
            \ 'i': '创建注释书签',
            \ 'a': '显示所有书签',
            \ 'n': '跳转到下一个书签',
            \ 'p': '跳转到上一个书签',
            \ 'c': '删除当前书签',
            \ 'x': '删除所有书签',
            \ 'k': '当前书签行上移',
            \ 'j': '当前书签行下移',
            \ 'l': '当前书签行移动到某一行',
            \ '4': '4向选择边框[min](vimio)',
            \ '8': '8向选择边框[min](vimio)',
            \ 'm': { 
            \   'name': 'vimio(border select max)',
            \   '4': '4向选择边框[max]',
            \   '8': '4向选择边框[max]',
            \   },
            \ }
" ----------------------代码记录导航------------------------------------------
let g:which_key_map.j = { 
            \ 'name': '代码记录跳转',
            \ 'j': '跳转到代码',
            \ 'l': '记录行锚点到系统剪切板',
            \ 'r': '记录锚点到系统剪切板',
            \ 'h': '跳转到锚点',
            \ 'n': '创建新锚点到系统寄存器',
            \ 'c': '插入代码路径',
            \ 'k': '插入锚点路径',
            \ }



" 这里是把注册的前缀直接绑定到对应的全局字典
" 建议放到最后
call which_key#register('<Space>', "g:which_key_map", 'n')
call which_key#register('<Space>', "g:which_key_map_visual", 'v')
call which_key#register('s', "g:which_key_map_s", 'n')


" 终端模式下的提示配置方法
" 后面是数组的情况下可以直接配置映射，但是因为限制过多，还是直接映射比较好
" let g:which_key_map_terminal = {
"       \ 'r': [":call RestartService()<CR>", '重启服务'],
"       \ 'c': [":call ClearConsole()<CR>", '清理终端输出'],
"       \ 'q': [":bd!<CR>", '关闭终端 buffer'],
"       \ }
" call which_key#register('<leader>t', 'g:which_key_map_terminal', 't')
" tnoremap <leader>t <C-\><C-n>:WhichKey '<leader>t'<CR>


" vim-which-key 插件配置 }

" 切换到 html 模板的目录中运行 python -m http.server
" 或者指定目录运行也可以 python -m http.server --directory /path/to/html
" python -m http.server 8000 --bind 127.0.0.1
" 强制使用 ipv4
" http://127.0.0.1:8000/asciidoc_preview.html?file=demo.adoc
" 
function! PreviewAsciiDoc()
    let l:filename = expand('%:t')
    let l:url = 'http://localhost:8000/asciidoc_preview.html?file=' . l:filename
    " 前提是浏览器的路径要在环境变量中
    call job_start(['chrome', l:url])
    " call job_start(['msedge', l:url])
endfunction

nnoremap <leader><leader>p :call PreviewAsciiDoc()<CR>

" :/<C-r>=BuildLooseRegex("你好世界")<CR>
" :echo BuildLooseRegex("你好世界")
" \V你\s\*好\s\*世\s\*界
function! BuildLooseRegex(keyword)
    let chars = split(a:keyword, '\zs')
    let pattern = '\V' . join(chars, '\s\*')
    return pattern
endfunction

