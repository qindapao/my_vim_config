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
    execute '%s/' . old_word . '/' . new_word . '/gc'
endfunction

" 括号自动配对
runtime macros/matchit.vim
" :TODO: GUI VIM中设置垂直和水平的滚动条的宽度(目前没有找到方法,可能要通过windows系统设置)

" vim enters visual mode and selects an area the same size as the x register
" ctrl j k h l move this selection area
function! VisualBlockMove(derection)
    if a:derection == 'j'
        normal 1j
    elseif a:derection == 'k'
        normal 1k
    elseif a:derection == 'h'
        normal 1h
    elseif a:derection == 'l'
        normal 1l
    endif
    
    let regtype = getregtype("x")
    let regcontent = getreg("x")
    let blockwidth = str2nr(regtype[1:])
    let blockheight = len(split(regcontent, "\n"))
    execute "normal! \<C-S-V>"
    if blockheight != 1
        execute "normal! " . (blockheight - 1) . "j"
    endif
    execute "normal! " . blockwidth . "l"
    execute 'normal! o'
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
" endfunction


" below are my personal settings
" 基本设置区域 {

" 交换文件放置到固定的目录中去
set directory^=$HOME/.vim/swap//

nnoremap <leader>dbt :call DeleteTerminalBuffers()<cr>

nnoremap <leader>pwd :pwd<cr>

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
    inoremap <ESC> <ESC>: set iminsert=2<CR>
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
noremap tn :tabnew<CR>
noremap tc :tabclose<CR>
noremap to :tabonly<CR>
nnoremap <Tab> gt<cr>
nnoremap <S-Tab> gT<cr>
:nn <M-1> 1gt
:nn <M-2> 2gt
:nn <M-3> 3gt
:nn <M-4> 4gt
:nn <M-5> 5gt
:nn <M-6> 6gt
:nn <M-7> 7gt
:nn <M-8> 8gt
:nn <M-9> 9gt
:nn <M-0> :tablast<CR>

nnoremap <silent> <leader>new :new<cr>
nnoremap <silent> <leader>enew :enew<cr>

set scrolloff=3

" search highlight
set hlsearch
" 暂时取消搜索高亮
noremap <silent> <leader>noh :nohlsearch<CR>
noremap <silent> # :nohlsearch<CR>


set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                                                                    " 用空格替换TAB
" perl格式的文件,TAB就是TAB, 不要替换
autocmd filetype perl setlocal noexpandtab

" 设置星号不要自动跳转,只高亮
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
" 星号切换打开和关闭高亮(暂时不使用)
" nnoremap <silent> * :if &hlsearch \| let @/= '\<' . expand('<cword>') . '\>' \| set nohls \| else \| let @/= '\<' . expand('<cword>') . '\>' \| set hls \| endif <cr>

set cursorline                                                                   " highlight current line
" cursor not blinking
set guicursor+=a:blinkon0

" set guifont=sarasa\ mono\ sc:h13
" set guifont=Yahei\ Fira\ Icon\ Hybrid:h11
set guifont=微软雅黑\ PragmataPro\ Mono:h12
" set guifont=Microsoft\ YaHei\ Mono:h8
" set guifont=PragmataPro\ Mono:h8
" set guifont=PragmataPro:h8




set noundofile
set nobackup
set guioptions+=b                                                                " 添加水平滚动条

" 映射普通模式下面插入一行,这里不能设置为oo,这会导致o命令的延迟
nnoremap <leader>o o<Esc>
" 映射普通模式上面插入一行,这里不能设置为OO,这会导致O命令的延迟
nnoremap <leader>O O<Esc>
" 由于环境变量的问题,下面这行暂时不使用
" command -nargs=1 Sch noautocmd vimgrep /<args>/gj `git ls-files` | cw            " 搜索git关注的文件 :Sch xx
" 把目录切换到当前文件所在目录
nnoremap <silent> <leader>. :cd %:p:h<CR>:pwd<CR>

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
nnoremap <Leader>ver :e $MYVIMRC<CR>
" 打开虚拟文本编辑模式
nnoremap <Leader>veon :set ve=all<CR>
" 关闭虚拟文本编辑模式
nnoremap <Leader>veof :set ve=<CR>


" 重新加载vim配置文件
nnoremap <Leader>vr :source $MYVIMRC<CR>

" 映射命令行历史操作,这个注释不能写到映射后面
cnoremap <c-j> <down>
cnoremap <c-k> <up>

" 在location window列出搜索结果
nnoremap <leader>lv :lv /<c-r>=expand("<cword>")<cr>/%<cr>:lw<cr>

" 移除文件中所有行尾的空白字符
nnoremap <leader><leader><space> :%s/\s\+$//e<CR>

" 插入模式下快速插入日期时间(需要按两个TAB键触发)
iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>

" 打开当前文件所在的目录
nnoremap <silent> <leader>exp :silent !explorer %:p:h<CR><CR>

" 某些插件可能需要手动指定python3库的地址,不过大多情况下这个值是默认的并不需要设置，只有出问题才需要设置
" set pythonthreedll = D:\python\python38.dll

" 设置grep默认显示行号
set grepprg=grep\ -n

" Quickfix窗口按键映射
nnoremap <leader>qo :copen<CR>
nnoremap <leader>qc :cclose<CR>
nnoremap <leader>qn :cnext<CR>
nnoremap <leader>qp :cprev<CR>

" 本地列表映射
nnoremap <leader>lo :lopen<CR>
nnoremap <leader>lc :lclose<CR>
nnoremap <leader>ln :lnext<CR>
nnoremap <leader>lp :lprev<CR>

" 窗口操作
" 之所以绑定两个字母为了快速响应
nnoremap <leader>cw :close<CR>
nnoremap <leader>ss :split<CR>
nnoremap <leader>vv :vsplit<CR>
nnoremap <leader>ow :only<CR>



" There is a space after the mapping below. In visual mode, 
" a region is cut and saved in the x register, and all characters in the 
" original region are replaced with spaces.
vnoremap xc "xygvgr 

nnoremap <leader>xv :call VisualBlockMove("null")<cr>
vnoremap <C-j> <Esc>:call VisualBlockMove("j")<cr>
vnoremap <C-k> <Esc>:call VisualBlockMove("k")<cr>
vnoremap <C-h> <Esc>:call VisualBlockMove("h")<cr>
vnoremap <C-l> <Esc>:call VisualBlockMove("l")<cr>
vnoremap <leader>p "xp

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
set makeprg=gcc\ -Wall\ -o\ %<\ %

" 设置conceallevel的收缩级别
nnoremap <leader>cc0 :set conceallevel=0<cr>
nnoremap <leader>cc2 :set conceallevel=2<cr>

" 设置虚拟文本
nnoremap <leader>vea :set ve=all<cr>
nnoremap <leader>ven :set ve=<cr>

" 设置平滑滚动(vim9.1新增),不过目前没看出来效果是啥
set smoothscroll

" 关闭预览窗口(主要是自定义补全不冲突)
set completeopt-=preview

" 设置打开和关闭语法高亮快捷键
nnoremap <silent> <leader>sof :syntax off<cr>
nnoremap <silent> <leader>son :syntax on<cr>

" vim 进入全词匹配搜索模式(自动搜索光标下单词)
nnoremap <leader>swa yiw/\<<C-R>"\>
" vim 进入全词匹配搜索模式(手动搜索)
nnoremap <leader>swm /\<\><Left><Left>

" 设置vim等待某些事件的刷新事件(默认是4000ms)[ :TODO: 这个设置可能比较危险,目前还不确定有什么副作用]
set updatetime=100


" 基本设置区域 }

" 加载插件前指定coc配置文件路径不使用默认的
let g:coc_config_home = $VIM


" 插件 {
call plug#begin('~/.vim/plugged')

" 这个补全插件的位置最好放置到最前面,目前不直到原因
Plug 'qindapao/gtagsomnicomplete', {'branch': 'for_use'}                       " gtags完成插件
Plug 'qindapao/vim-guifont'                                                    " 灵活设置字体大小
Plug 'qindapao/nerdtree'                                                       " 文件管理器
Plug 'qindapao/nerdtree-git-plugin'                                            " nerdtree中显示git变化
Plug 'qindapao/vim-surround'                                                   " 单词包围
Plug 'qindapao/vim-repeat'                                                     " vim重复插件,可以重复surround的内容
" 暂时用不着
" Plug 'WolfgangMehner/bash-support'                                           " bash开发支持
Plug 'qindapao/auto-pairs'                                                     " 插入模式下自动补全括号
Plug 'qindapao/ale'                                                            " 异步语法检查和自动格式化框架
Plug 'qindapao/vim-airline'                                                    " 漂亮的状态栏
Plug 'qindapao/tabular'                                                        " 自动对齐插件
Plug 'qindapao/indentLine'                                                     " 对齐参考线插件
Plug 'qindapao/vim-fugitive'                                                   " vim的git集成插件
Plug 'qindapao/vim-rhubarb'                                                    " 用于打开gi的远程
" 这个插件功能和vim-flog重复,先屏蔽
" Plug 'junegunn/gv.vim'                                                         " git树显示插件
Plug 'qindapao/vim-flog'                                                       " 显示漂亮的git praph插件
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
Plug 'qindapao/LeaderF'                                                        " 模糊搜索插件
Plug 'qindapao/ctrlsf.vim'                                                     " 全局搜索替换插件
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
Plug 'qindapao/colorizer'                                                      " vim中显示16进制颜色
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
Plug 'qindapao/traces.vim'                                                     " 搜索效果显示
Plug 'qindapao/vim-visual-star-search'                                         " 增强星号搜索
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
" Plug 'rhysd/clever-f.vim'                                                      " 聪明的f,这样就不用逗号和分号来重复搜索字符,它们可以用作别的映射
" 当前这个插件会导致编辑txt和zim文件变得很卡,所以只用于特定的编程语言
" 太卡了先注释吧，编程的时候再放出来
" Plug 'SirVer/ultisnips', { 'for': ['python', 'c', 'sh', 'perl'] }
" Plug 'honza/vim-snippets'                                                      " 拥有大量的现成代码片段
" Plug 'artur-shaik/vim-javacomplete2'                                           " javac语义补全
Plug 'qindapao/vim-expand-region'                                              " vim的扩展选区插件
" 并不需要
" Plug 'puremourning/vimspector'                                                 " 调试插件
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
Plug 'qindapao/photon.vim'                                                           " 一个极简的漂亮主题


call plug#end()
" 插件 }

" 插件配置 {

" table-mode {
noremap <leader>tm :TableModeToggle<CR>
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
nnoremap <leader>aleof :ALEDisable<cr>
" 手动打开ale
nnoremap <leader>aleon :ALEEnable<cr>
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
let g:ale_java_javac_executable = 'C:\Users\pc\.vim\coc\extensions\coc-java-data\jdk-17.0.8\javajre-windows-64\jre\bin\javac.exe'

" dense-analysis/ale }

" vim-gutentags {
" 这两句非常重要是缺一不可的,并且配置文件的路径一定不能写错
let $GTAGSLABEL = 'native-pygments'                                              " 让非C语言使用这个生成符号表
" 这里的路径注意下一定要是绝对路径
let $GTAGSCONF = 'C:/Users/pc/.vim/gtags/share/gtags/gtags.conf'                 " gtags的配置文件的路径

let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']      " gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
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
nnoremap <silent> <leader>gws :belowright split \| GscopeFind s <C-R><C-W><cr>:wincmd p<cr>   " 查找符号
nnoremap <silent> <leader>gwg :belowright split \| GscopeFind g <C-R><C-W><cr>:wincmd p<cr>   " 查找符号定义
nnoremap <silent> <leader>gwc :belowright split \| GscopeFind c <C-R><C-W><cr>:wincmd p<cr>   " 调用这个函数的函数
nnoremap <silent> <leader>gwt :belowright split \| GscopeFind t <C-R><C-W><cr>:wincmd p<cr>   " 查找字符串
nnoremap <silent> <leader>gwe :belowright split \| GscopeFind e <C-R><C-W><cr>:wincmd p<cr>   " 查找正则表达式
nnoremap <silent> <leader>gwf :belowright split \| GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>  " 查找文件名
nnoremap <silent> <leader>gwi :belowright split \| GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>  " 查找包含当前头文件的文件
nnoremap <silent> <leader>gwd :belowright split \| GscopeFind d <C-R><C-W><cr>:wincmd p<cr>   " 此函数调用的函数
nnoremap <silent> <leader>gwa :belowright split \| GscopeFind a <C-R><C-W><cr>:wincmd p<cr>   " 查找为此符号赋值的位置
nnoremap <silent> <leader>gwz :belowright split \| GscopeFind z <C-R><C-W><cr>:wincmd p<cr>   " 在ctags的数据库中查找当前单词

nnoremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>:wincmd p<cr>   " 查找符号
nnoremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>:wincmd p<cr>   " 查找符号定义
nnoremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>:wincmd p<cr>   " 调用这个函数的函数
nnoremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>:wincmd p<cr>   " 查找字符串
nnoremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>:wincmd p<cr>   " 查找正则表达式
nnoremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>  " 查找文件名
nnoremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>  " 查找包含当前头文件的文件
nnoremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>:wincmd p<cr>   " 此函数调用的函数
nnoremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>:wincmd p<cr>   " 查找为此符号赋值的位置
nnoremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>:wincmd p<cr>   " 在ctags的数据库中查找当前单词

vnoremap <leader>gws y:belowright split \| GscopeFind s <c-r>"<cr>:wincmd p<cr>   " 查找符号
vnoremap <leader>gwg y:belowright split \| GscopeFind g <c-r>"<cr>:wincmd p<cr>   " 查找符号定义
vnoremap <leader>gwc y:belowright split \| GscopeFind c <c-r>"<cr>:wincmd p<cr>   " 调用这个函数的函数
vnoremap <leader>gwt y:belowright split \| GscopeFind t <c-r>"<cr>:wincmd p<cr>   " 查找字符串
vnoremap <leader>gwe y:belowright split \| GscopeFind e <c-r>"<cr>:wincmd p<cr>   " 查找正则表达式
vnoremap <leader>gwf y:belowright split \| GscopeFind f <c-r>"<cr>:wincmd p<cr>   " 查找文件名
vnoremap <leader>gwi y:belowright split \| GscopeFind i <c-r>"<cr>:wincmd p<cr>   " 查找包含当前头文件的文件
vnoremap <leader>gwd y:belowright split \| GscopeFind d <c-r>"<cr>:wincmd p<cr>   " 此函数调用的函数
vnoremap <leader>gwa y:belowright split \| GscopeFind a <c-r>"<cr>:wincmd p<cr>   " 查找为此符号赋值的位置
vnoremap <leader>gwz y:belowright split \| GscopeFind z <c-r>"<cr>:wincmd p<cr>   " 在ctags的数据库中查找当前单词

vnoremap <leader>gs y:GscopeFind s <c-r>"<cr>:wincmd p<cr>   " 查找符号
vnoremap <leader>gg y:GscopeFind g <c-r>"<cr>:wincmd p<cr>   " 查找符号定义
vnoremap <leader>gc y:GscopeFind c <c-r>"<cr>:wincmd p<cr>   " 调用这个函数的函数
vnoremap <leader>gt y:GscopeFind t <c-r>"<cr>:wincmd p<cr>   " 查找字符串
vnoremap <leader>ge y:GscopeFind e <c-r>"<cr>:wincmd p<cr>   " 查找正则表达式
vnoremap <leader>gf y:GscopeFind f <c-r>"<cr>:wincmd p<cr>   " 查找文件名
vnoremap <leader>gi y:GscopeFind i <c-r>"<cr>:wincmd p<cr>   " 查找包含当前头文件的文件
vnoremap <leader>gd y:GscopeFind d <c-r>"<cr>:wincmd p<cr>   " 此函数调用的函数
vnoremap <leader>ga y:GscopeFind a <c-r>"<cr>:wincmd p<cr>   " 查找为此符号赋值的位置
vnoremap <leader>gz y:GscopeFind z <c-r>"<cr>:wincmd p<cr>   " 在ctags的数据库中查找当前单词
" gutentags_plus 插件配置 }

" NERDTree {
nnoremap <leader><leader><F8> :NERDTreeToggle<CR>
" 刷新NERDTree的状态
nnoremap <leader>r :NERDTreeFocus<cr>:NERDTreeRefreshRoot<cr><c-w>p
nnoremap <leader>ntf :NERDTreeFind<cr>:NERDTreeRefreshRoot<cr><c-w>p
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
let guifontpp_size_increment=1
let guifontpp_smaller_font_map="<C-ScrollWheelDown>"
let guifontpp_larger_font_map="<C-ScrollWheelUp>"
let guifontpp_original_font_map="<F7>"


nnoremap <leader><C-t> :setlocal guifont=Yahei\ Fira\ Icon\ Hybrid:h
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
colorscheme antiphoton
" photon.vim 主题 }

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

let g:Lf_ShortcutB = '<c-l>'                                                     " 打开buffer搜索窗口
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


" 字符串检索相关配置 可以手动补充的词 (-i 忽略大小写. -e <PATTERN> 正则表达式搜索. -F 搜索字符串而不是正则表达式. -w 搜索只匹配有边界的词.)
" 命令行显示:Leaderf rg -e,然后等待输入正则表达式
nmap <leader>fr <Plug>LeaderfRgPrompt
" 查询光标或者可视模式下所在的词,非全词匹配
nmap <leader>frb <Plug>LeaderfRgCwordLiteralNoBoundary
" 查询光标或者可视模式下所在的词,全词匹配
nmap <leader>frw <Plug>LeaderfRgCwordLiteralBoundary
" 查询光标或者可视模式下所在的正则表达式，非全词匹配
nmap <leader>fre <Plug>LeaderfRgCwordRegexNoBoundary
" 查询光标或者可视模式下所在的正则表达式，全词匹配
nmap <leader>frew <Plug>LeaderfRgCwordRegexBoundary
" 上面解释了
vmap <leader>frb <Plug>LeaderfRgVisualLiteralNoBoundary
" 上面解释了
vmap <leader>frw <Plug>LeaderfRgVisualLiteralBoundary
" 上面解释了
vmap <leader>fre <Plug>LeaderfRgVisualRegexNoBoundary
" 上面解释了
vmap <leader>frew <Plug>LeaderfRgVisualRegexBoundary

" 跳到字符串搜索的下一个结果
noremap ]n :Leaderf rg --next<CR>
" 跳到字符串搜索的上一个结果
noremap ]p :Leaderf rg --previous<CR>


noremap <leader>f :LeaderfSelf<cr>
noremap <leader>fm :LeaderfMru<cr>
noremap <leader>ff :LeaderfFunction<cr>
noremap <leader>fb :LeaderfBuffer<cr>
noremap <leader>ft :LeaderfBufTag<cr>
noremap <leader>fl :LeaderfLine<cr>
noremap <leader>fw :LeaderfWindow<cr>
noremap <leader>frr :LeaderfRgRecall<cr>

" search visually selected text literally, don't quit LeaderF after accepting an entry
" 这个不开启二次过滤
" 这里要注意下不能l键映射到最前面，不然会导致可视模式下自动往后多选择一个字符
xnoremap gfl :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>
" 这个开启二次过滤
xnoremap gnfl :<C-U><C-R>=printf("Leaderf rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>

" 保持文件搜索窗口不关闭
nnoremap <leader><C-P> :Leaderf file --stayOpen<CR>



" 关闭leaderf的预览窗口,不然会影响-stayOpen模式,预览窗口无法关闭,也无法编辑新的文件
let g:Lf_PreviewInPopup = 0

" leaderf不要自动生成标签,用gentags插件生成
" unique的意思是vim是否检查映射已经存在,如果存在会报错,当前暂时不需要这个功能
" nmap <unique> <leader>fgd <Plug>LeaderfGtagsDefinition
nmap <leader>fgd <Plug>LeaderfGtagsDefinition
nmap <C-LeftMouse> <Plug>LeaderfGtagsDefinition
nmap <leader>fgr <Plug>LeaderfGtagsReference
nmap <S-LeftMouse> <Plug>LeaderfGtagsReference
nmap <leader>fgr <Plug>LeaderfGtagsReference
nmap <leader>fgs <Plug>LeaderfGtagsSymbol
nmap <A-LeftMouse> <Plug>LeaderfGtagsSymbol
nmap <leader>fgg <Plug>LeaderfGtagsGrep
nmap <C-A-LeftMouse> <Plug>LeaderfGtagsGrep

vmap <leader>fgd <Plug>LeaderfGtagsDefinition
vmap <leader>fgr <Plug>LeaderfGtagsReference
vmap <leader>fgs <Plug>LeaderfGtagsSymbol
vmap <leader>fgg <Plug>LeaderfGtagsGrep

noremap <leader>fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>
noremap <leader>fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>
noremap <leader>fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>

" LeaderF 配置 }

" tagbar 配置 {
map <leader><F4> :TagbarToggle<CR>
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
autocmd filetype markdown,tex,zim,txt nmap <buffer><silent> <leader><leader>p :call mdip#MarkdownClipboardImage()<CR>
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
inoremap <silent><expr> <S-TAB> pumvisible() ? coc#pum#next(1) : "\<TAB>"

" 定义coc插件和数据的目录
let g:coc_data_home = '~/.vim/coc'
" coc补全插件的一些配置 }

" vim-gitgutter 插件配置 {
" 状态的刷新时间由updatetime决定
nnoremap gnh :GitGutterNextHunk<CR>
nnoremap gph :GitGutterPrevHunk<CR>
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
nmap <Leader><Leader>bt <Plug>BookmarkToggle
nmap <Leader><Leader>bi <Plug>BookmarkAnnotate
nmap <Leader><Leader>ba <Plug>BookmarkShowAll
nmap <Leader><Leader>bj <Plug>BookmarkNext
nmap <Leader><Leader>bk <Plug>BookmarkPrev
nmap <Leader><Leader>bc <Plug>BookmarkClear
nmap <Leader><Leader>bx <Plug>BookmarkClearAll

" these will also work with a [count] prefix
nmap <Leader>kk <Plug>BookmarkMoveUp
nmap <Leader>jj <Plug>BookmarkMoveDown
nmap <Leader>gl <Plug>BookmarkMoveToLine


" vim-bookmarks 书签插件配置 }

" indentLine 插件配置 {
" 这里一定要配置，不然indentLine插件会把concealcursor=inc，造成光标行也不展开收缩无法编辑
let g:indentLine_concealcursor = ""
let g:indentLine_conceallevel = "2"
" indentLine 插件配置 }

" undotree 的配置 {
nnoremap <leader><F5> :UndotreeToggle<CR>
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
nnoremap <leader>foo :Rooter<CR>
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
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysub"]
" " vim-snippets 插件配置 }

" " airline {
" let g:airline_theme = 'catppuccin_frappe'
" let g:airline_theme_dark = 'catppuccin_frappe'
" let g:airline_powerline_fonts = 1
" " airline }

" vim-javacomplete2 {
" 自动导包?这行配置并不一定有作用,其它的配置也不一定有作用
" let g:JavaComplete_AutoImport = 1
" <C-]> 跳转到类或者方法定义处
" <C-t>返回跳转前位置
" <Plug>(JavaComplete-Impports-Rename)重命名当前光标下的变量或者方法，自动更新所有引用
" <Plug>(JavaComplete-Imports-Organize)自动格式化
" vim-javacomplete2 }

" completor 插件配置 {
" 这行并不能阻止预览窗口顶部弹出，只是某些场景不自动弹出
let g:completor_auto_preview = 0
" 设置completor的补全时的触发为任意字母
let g:completor_java_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
" let g:completor_zim_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
let g:completor_zim_omni_trigger = '(\S+)$'
let g:completor_python_omni_trigger = '(\S+)$'
" 可以关闭preview,这样不和自定义的补全的弹出窗口重复
" :TODO: 这里可以根据文件类型不同打开不同的参数
" let g:completor_complete_options = 'menuone,noselect,preview'
let g:completor_complete_options = 'menuone,noselect'

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
nnoremap <leader>db <Plug>VimspectorBreakpoints

" vimspector 调试插件配置 {

" ctrlsf 插件配置 {
" 有个小tips: 我们在搜索结果页中我们可以使用zM折叠所有的搜索结果(类似于vscode的效果)
" :TODO: 目前试过各种办法都无法实现全词匹配
" 获取光标下的单词(这里命令在第二个命令,所以不能用<cword>)
nnoremap <leader>cfr :Rooter<cr> :CtrlSF -I <C-r><C-w><cr> " 大小写不敏感递归搜索整个项目(当前单词)
" 大小写不敏感递归搜索整个项目(手动输入搜索字符)
nnoremap <leader>cfn :Rooter<cr> :CtrlSF -I 
" 大小写敏感
nnoremap <leader>cfs :Rooter<cr> :CtrlSF -S <C-r><C-w><cr> " 大小写敏感递归搜索整个项目(当前单词)
nnoremap <leader>cfc :CtrlSF -I <C-r><C-w><cr>             " 当前文件夹递归搜索
nnoremap <leader>cfd :CtrlSF -I <C-r><C-w> ./<cr>          " 只搜索当前文件夹
nnoremap <leader>cff :CtrlSF -I <C-r><C-w> %<cr>           " 只搜索当前文件

" 当前文件夹手动搜索
nnoremap <leader>cfm :CtrlSF -I 


vnoremap <leader>cfr y:Rooter<cr> :CtrlSF -I <C-r>"<cr>
vnoremap <leader>cfc y:CtrlSF -I <C-r>"<cr>
vnoremap <leader>cfd y:CtrlSF -I <C-r>" ./<cr>
vnoremap <leader>cff y:CtrlSF -I <C-r>" %<cr>


let g:ctrlsf_case_sensitive = 'yes'
let g:ctrlsf_follow_symlinks = 0
let g:ctrlsf_ignore_dir = ['docs/bak.md', '.gitignore']
let g:ctrlsf_backend = 'rg'
let g:ctrlsf_search_mode = 'async'
let g:ctrlsf_winsize = '30%'
" 默认按照字面意思搜索
let g:ctrlsf_regex_pattern = 0

" ctrlsf 插件配置 }

" vim-terminal-help 插件配置 {
let g:terminal_height = 20
tnoremap <Esc> <C-\><C-n>
" 重新映射Esc键的功能
" <C-v>的默认功能是输出特殊字符,这里<C-S-->是不行的,不知道原因
tnoremap <C-v> <C-S-_>"+
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
let g:stargate_limit = 600
" vim9-stargate 插件配置 }

" vim-fugitive 插件按键绑定 {
" 显示所有差异
nnoremap <silent> <leader>gda :Git difftool -y<cr>
" commit 全对比
nnoremap <silent> <leader>gdc :execute 'Git! difftool ' . getreg('a') . ' ' . getreg('b') . ' --name-status'<CR>
" 分支全对比
nnoremap <silent> <leader>gdb :execute 'Git! difftool ' . getreg('a') . ' --name-status'<CR>
" 执行单文件对比(commit id 和 分支)
nnoremap <silent> <leader>gdv :execute 'Gvdiffsplit ' . getreg('a')<CR>
" 对比当前文件
nnoremap <silent> <leader>gdf :execute 'Gvdiffsplit'<CR>

" 基于当前分支创建一个新分支
nnoremap <silent> <leader>gbn :Git checkout -b 
" 查看所有的本地分支
nnoremap <silent> <leader>gbl :execute 'Git branch'<CR>
" 切换分支
nnoremap <silent> <leader>gbc :execute 'normal "xyiw' \| execute 'Git checkout ' . getreg('x') \| close<CR>
vnoremap <silent> <leader>gbc y:execute 'Git checkout ' . shellescape(@0) \| close<CR>
" 删除一个本地分支
nnoremap <silent> <leader>gbxl :execute 'normal "xyiw' \| execute 'Git branch -d ' . getreg('x') \| close<CR>
vnoremap <silent> <leader>gbxl y:execute 'Git branch -d ' . shellescape(@0) \| close<CR>
nnoremap <silent> <leader>gbfxl :execute 'normal "xyiw' \| execute 'Git branch -D ' . getreg('x') \| close<CR>
vnoremap <silent> <leader>gbfxl y:execute 'Git branch -D ' . shellescape(@0) \| close<CR>

" 删除一个远程分支
nnoremap <silent> <leader>gbxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -d ' . branchname<CR>
nnoremap <silent> <leader>gbfxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -D ' . branchname<CR>


" 查看所有的远程分支
nnoremap <silent> <leader>gbr :execute 'Git remote prune origin' \| execute 'Git branch -r'<CR>
" 拉取一个远程分支并在本地跟踪它(复制远程分支名然后检出到本地)
" git fetch origin <远程分支名>:<本地分支名>
nnoremap <silent> <leader>gbfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git fetch origin ' . branchname . ':' . branchname<CR>

" 拉取最新变更
nnoremap <silent> <leader>gpl :execute 'Git pull'<CR>
" 推送当前更改(当前本地分支)
nnoremap <silent> <leader>gps :let branchname=system('git rev-parse --abbrev-ref HEAD') \| execute 'Git push --set-upstream origin ' . trim(branchname)<CR>

" 查看当前文件的所有提交历史
nnoremap <silent> <leader>gog :0Gclog<cr> 

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

" markdown-preview 插件配置 {
" let g:mkdp_markdown_css = $VIM . '\github-markdown-light.css'
let g:mkdp_markdown_css = expand('~/.vim/markdown/github-markdown-light.css')
" markdown-preview 插件配置 }

" vim-highlighter 配置 {

" 这里最好不要直接用<CR>会覆盖掉一些重要的默认按键映射
nnoremap <C-CR>  <Cmd>Hi><CR>
nnoremap <C-S-CR>  <Cmd>Hi<<CR>
nnoremap <C-S-N> <Cmd>Hi}<CR>
nnoremap <S-CR> <Cmd>Hi{<CR>

" vim-highlighter 配置 }

" 插件配置 }


" 这个语句需要最后执行，说出暂时放在配置文件的最后，给markdown/zimwiki文件加上目录序号
" :TODO: 因为保存的时候的效率问题，暂时先屏蔽掉
" autocmd BufWritePost *.md silent call GenSectionNum('markdown')
" autocmd BufWritePost *.txt silent call GenSectionNum('zim')
noremap <leader>gsnm :silent call GenSectionNum('markdown')<cr>
noremap <leader>gsnz :silent call GenSectionNum('zim')<cr>

" 替换函数快捷方式,和<leader>r和NERDTree刷新快捷键冲突
noremap <leader><leader>r :call MyReplaceWord('n')<CR>
vnoremap <leader>r :call MyReplaceWord('v')<CR>

nnoremap <leader>br :call AddBufferBr()<CR>

" 打开git远端上的分支
" nnoremap <silent> <leader>git :call GitGetCurrentBranchRemoteUrl()<CR>

" 浏览器中打开当前编辑的html文件
nnoremap <leader><F9> :call DisplayHTML()<CR>

" 配置json文件不要收缩(目前好像不起作用)
autocmd filetype json silent set conceallevel=0
autocmd filetype zim,markdown silent set conceallevel=2


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
nnoremap <leader>rca :%s/\%x00/\r/g<cr>
vnoremap <leader>rca :s/\%x00/\r/g<cr>

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

    if a:exec_mode != ''
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


source $VIM/keybinding_help.vim
" :TODO: 如果列表中只有一个元素，可能再增加一个弹窗显示详情
" :TODO: 可以支持类似fzf的模糊搜索功能
" :TODO: 滚轮键只有在固定的时候可以使用，可以再处理下PgUp和PgDn
" 如果要搜索所有的，输入.点号即可

nnoremap <silent> <c-h> :call PopupMenuShowKeyBindings('and', '', '')<cr>
nnoremap <silent> <c-s-h> :call PopupMenuShowKeyBindings('or', '', '')<cr>
nnoremap <silent> <c-s-c> :call PopupMenuShowKeyBindings('and', 'auto', 'map')<cr>
nnoremap <silent> <leader><leader>ca :call PopupMenuShowKeyBindings('or', 'auto', 'map')<cr>
" 输入命令 marks 可以显示当前所有的标记
nnoremap <silent> <leader><leader>cm :call PopupMenuShowKeyBindings('and', 'manu', '')<cr>

nnoremap <leader>cpw :call popup_close(
nnoremap <leader>cpwa :call popup_clear()<cr>

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


nnoremap <silent> <leader>ypw :call GetAllInfoInPopupWin(0)<cr>
nnoremap <silent> <leader>ypwp :call GetAllInfoInPopupWin(1)<cr>


" 按键补全帮助窗口 }



nnoremap <c-;> <Cmd>call stargate#OKvim('\<')<cr>
nnoremap <leader>w <Cmd>call stargate#Galaxy()<cr>



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
    call sort(l:lines, 'SortByLine')

    " return join(map(copy(l:lines), 'join(v:val, " ")'), "\n")
    return map(copy(l:lines), 'join(v:val, " ")')
endfunction

function! SortByLine(mark1, mark2)
    return a:mark1[1] - a:mark2[1]
endfunction

" vim中执行异步的命令并且在弹出窗口中动态显示出来(用于监控一些重要信息)
let s:timer = -1

function! StartTimer()
    if s:timer != -1
        call timer_stop(s:timer)
    endif

    " 创建一个空的弹出窗口
    let opts = { 'line': 'cursor',
        \ 'col': 'cursor',
        \ 'padding': [0,1,0,1],
        \ 'wrap': v:true,
        \ 'border': [],
        \ 'close': 'none',
        \ 'highlight': 'Pmenu',
        \ 'resize': 1,
        \ 'zindex': 100,
        \ 'maxheight': 20,
        \ 'maxwidth': 80,
        \ 'title': 'tips',
        \ 'dragall': 1}
    let s:dynamic_content_win = popup_create([''], opts)

    let s:timer = timer_start(1000, 'UploadDynamicPopupWin', {'repeat': -1})
endfunction

function! StopTimer()
    if s:timer != -1
        call timer_stop(s:timer)
        let s:timer = -1
        " if exists(s:dynamic_content_win) && !empty(popup_findinfo(s:dynamic_content_win))
        call popup_close(s:dynamic_content_win)
        " endif
    endif
endfunction

function! UploadDynamicPopupWin(timer_id)
    let dynamic_info_list = SortMarks()
    " if exists(s:dynamic_content_win) && !empty(popup_findinfo(s:dynamic_content_win))
    call popup_settext(s:dynamic_content_win, dynamic_info_list)
    " endif
endfunction


" show marks
nnoremap <silent> <leader><leader>sm :call PopupMenuShowKeyBindings('and', 'auto', ':SortMarks')<cr>
nnoremap <silent> <leader>smt :call StartTimer()<cr>
nnoremap <silent> <leader>tmt :call StopTimer()<cr>
" 为了避免麻烦,在切换标签页前关闭
" :TODO: 可以考虑给字母标记加注释,注释的内容可以持久化,并方便更新,字母标记也可以持久化
autocmd BufLeave * call StopTimer()

" 利用弹出窗口自己设计的标记系统 }
" :TODO: 下面这个通过emacs打开后继承的环境变量有点问题,导致ggtags相关的路径错乱,可能是因为两个程序都定义了gtags相关的东西
function! OpenInEmacs()
    let l:line_number = line(".")
    let l:file_path = expand("%:p")
    let l:command = "start emacsclientw +" . l:line_number . " " . l:file_path
    call system(l:command)
endfunction

nnoremap <leader>oe :call OpenInEmacs()<CR>

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
vnoremap <silent> S( :call SurroundWith('()', visualmode(), ' ')<CR>
" 创建新的命令，S}，来调用这个函数
vnoremap <silent> S{ :call SurroundWith('{}', visualmode(), ' ')<CR>
" 创建新的命令，$)，来调用这个函数
vnoremap <silent> S) :call SurroundWith('()', visualmode(), '')<CR>
" 创建新的命令，$}，来调用这个函数
vnoremap <silent> S} :call SurroundWith('{}', visualmode(), '')<CR>

