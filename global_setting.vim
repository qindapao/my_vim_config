
" =====================File: global_setting {======================= 全局设置相关 ======================================

" 修复在高版本的vim中按键映射变为传统的(Ctrl组合键和Ctrl+Shift组合键无法区分)
if v:version > 901 || (v:version == 901 && has("patch51"))
    autocmd GUIEnter * call test_mswin_event('set_keycode_trans_strategy', {'strategy': 'experimental'})
endif

" 如果是下面这个那么就是无法区分的版本
" autocmd GUIEnter * call test_mswin_event('set_keycode_trans_strategy', {'strategy': 'classic'})

" 禁用关闭按钮，这样关闭按钮就不会覆盖我定义的标签页的样式
function! GlobalTabLine()
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

" --------------------- 设置 --------------------------------------------------

set columns=280                             " 设置vim打开的时候的窗口宽度（单位为字符）
set lines=80                                " 设置vim打开的时候窗口高度（单位为行）

filetype plugin indent on                   " 打开文件类型检测
set history=1000
let mapleader="\<Space>"                    " 设置 leader 键为空格
set nocompatible                            " 设置 vi 不兼容模式
set ruler                                   " 开启 标尺
set colorcolumn=81,121                      " 设置 列边界线
set nu                                      " 打开当前行号显示
set rnu                                     " 打开相对行号
set nowrap                                  " 默认不要 wrap
autocmd filetype markdown set wrap
                                            " 如果是markdown文件设置 wrap
au! vimrcEx filetype text                   " txt文本不允许vim自动换行
set wildmenu                                " 打开命令行自动补全
set fileencoding=utf-8
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,cp936,gb18030,big5,latin1
                                            " 设置文件编码
set tabstop=4                               " 默认 TAB 字符显示4个空格宽度
set softtabstop=4                           " 按 TAB 时插入或者删除的空格数量为4
set shiftwidth=4                            " 缩进的时候每次移动4个空格
set expandtab                               " 按 TAB 时不插入 TAB 而是插入空格

" show tab
set list
hi clear SpecialKey
hi SpecialKey ctermfg=245 ctermbg=NONE guifg=#999999 guibg=NONE
set listchars=tab:○◦,trail:▫
autocmd FileType markdown setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
autocmd FileType perl setlocal indentexpr= nosmartindent nocindent noautoindent tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
" 普通模式下的 gg=G 自动缩进，选择范围后按 = 缩进
autocmd FileType vim
      \ setlocal expandtab                  " 用空格替代 Tab
      \ shiftwidth=4                        " 每次缩进宽度为 4
      \ softtabstop=4                       " 插入空格时用 4 个空格
      \ autoindent                          " 继承上一行缩进
      \ smartindent                         " 智能缩进

set tabline=%!GlobalTabLine()               " 自定义多标签页的样式
set guitablabel=%N%M%t                      " 单个标签页的显示格式
set guioptions-=e                           " 关闭标签页栏的自动显示(tab pages bar)
set mouse-=a                                " 所有模式都启用鼠标支持
" set guioptions+=b                         " 不打开水平滚动条, 水平滚动条会让界面在上下滚动的时候有卡顿和撕裂感
set guioptions+=r                           " 打开右侧滚动条
set guioptions-=L                           " 隐藏左侧滚动条
set guioptions-=T                           " 禁用工具栏
set guioptions-=m                           " 禁用菜单栏
set noundofile                              " 关闭持久化撤销，不生成 undo 文件
set nobackup                                " 不生成备份文件
set autoread                                " 自动加载文件变化
set nofen                                   " 折叠功能关闭
" set foldenable                            " 开启折叠
set foldmethod=indent                       " 设置缩进折叠
setlocal foldlevel=3                        " 设置折叠层数
set foldlevelstart=99                       " 打开文件是默认不折叠代码
" :TODO: vim脚本超过80列自动换行,设置了下面的配置也无用
" :TODO: 这个设置无效会被覆盖需要定位
set textwidth=0                             " 设置不要自动换行
autocmd filetype * set textwidth=0          " 用这一行规避上面的问题

set directory^=$HOME/.vim/swap//            " 交换文件放置到固定的目录中去
set autochdir                               " 编辑时自动切换目录
set fillchars=vert:▒                        " 设置vim的窗口分割竖线的形状

set scrolloff=2                             " 光标的上下至少保留2行
set guicursor+=a:blinkon0                   " 编辑光标不闪烁
set cursorline                              " 高亮当前行
if has('termguicolors') | set termguicolors | endif

set smoothscroll                            " 设置平滑滚动(vim9.1新增),不过目前没看出来效果是啥

if has('gui_running')
    " 目前这里无法回到上次的中文输入法,不知道原因
    set imactivatekey=C
    inoremap <silent> <ESC> <ESC>: set iminsert=2<CR>
endif

set timeoutlen=400                          " 不要把按键延迟的值设置得太小
set updatetime=100                          " 设置vim等待某些事件的刷新事件(默认是4000ms)
                                            "   [ :TODO: 这个设置可能比较危险,目前还不确定有什么副作用]
set formatoptions+=ro                       " 自动创建注释

" " 某些插件可能需要手动指定python3库的地址,不过大多情况下这个值是默认的并不需要设置，只有出问题才需要设置
" if has('python3')
"      set pythonthreedll='D:\python\python38.dll'
"      set pythonthreehome='D:\python'
" endif

" 星号切换打开和关闭高亮(暂时不使用)
" nnoremap <silent> * :if &hlsearch \| let @/= '\<' . expand('<cword>') . '\>' \| set nohls \| else \| let @/= '\<' . expand('<cword>') . '\>' \| set hls \| endif <cr>



" ----------------------------- 命令组 ----------------------------------------

autocmd BufNewFile,BufRead *.vim9 set filetype=vim

" ----------------------------- 全局映射 --------------------------------------

nnoremap gR R                                   " global: gR 和 R 互换
nnoremap R gR                                   " global: gR 和 R 互换
nnoremap <silent> <leader>scc :set cursorcolumn<cr>
                                                " global: 高亮当前列
nnoremap <silent> <leader>scn :set nocursorcolumn<cr>
                                                " global: 取消高亮当前列
nnoremap <leader>pwd :pwd<cr>|                  " global: : 显示当前目录
nnoremap <silent> <leader>. :cd %:p:h<CR>:pwd<CR>
                                                " global: : 把目录切换到当前文件所在目录
" 设置虚拟文本
nnoremap <leader>vea :set ve=all<cr>|           " global: : 设置虚拟文本
nnoremap <leader>ven :set ve=<cr>|              " global: : 取消设置虚拟文本

" 设置conceallevel的收缩级别
nnoremap <leader>cc0 :set conceallevel=0<cr>| " global: 设置conceallevel级别0
nnoremap <leader>cc2 :set conceallevel=2<cr>| " global: 设置conceallevel级别2




" =====================File: global_setting }======================= 全局设置相关 ======================================

