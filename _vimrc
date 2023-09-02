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

" below are my personal settings
" 基本设置区域 {
filetype plugin indent on                                                        " 打开文件类型检测

" txt文本不允许vim自动换行 https://superuser.com/questions/905012/stop-vim-from-automatically-tw-78-line-break-wrapping-text-files
au! vimrcEx FileType text

set nu

set nocompatible

set ruler

set colorcolumn=81,121

set nowrap

set scrolloff=3

" search highlight
set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                                                                    " 用空格替换TAB

set cursorline                                                                   " highlight current line
" cursor not blinking
set guicursor+=a:blinkon0

set guifont=sarasa\ mono\ sc:h13

set noundofile
set nobackup
set guioptions+=b                                                                " 添加水平滚动条


nnoremap oo o<Esc>                                                               " 映射普通模式下面插入一行
nnoremap OO O<Esc>                                                               " 映射普通模式上面插入一行
set rnu                                                                          " 打开相对行号
set autoread                                                                     " 自动加载文件变化



" 基本设置区域 }

" 插件 {
call plug#begin('~/.vim/plugged')

Plug 'schmich/vim-guifont'                                                     " 灵活设置字体大小
Plug 'preservim/nerdtree'                                                      " 文件管理器
Plug 'tpope/vim-surround'                                                      " 单词包围
Plug 'WolfgangMehner/bash-support'                                             " bash开发支持
Plug 'jiangmiao/auto-pairs'                                                    " 插入模式下自动补全括号
Plug 'dense-analysis/ale'                                                      " 异步语法检查和自动格式化框架
Plug 'vim-airline/vim-airline'                                                 " 漂亮的状态栏
Plug 'godlygeek/tabular'                                                       " 自动对齐插件
Plug 'Yggdroot/indentLine'                                                     " 对齐参考线插件
Plug 'tpope/vim-fugitive'                                                      " vim的git集成插件
Plug 'rbong/vim-flog'                                                          " 显示漂亮的git praph插件
Plug 'airblade/vim-gitgutter'                                                  " git改变显示插件
Plug 'yianwillis/vimcdoc'                                                      " vim的中文文档
" 这里必须使用realese分支,不能用master分支,master分支需要自己编译
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ludovicchabant/vim-gutentags'                                            " gtags ctags自动生成插件
Plug 'skywind3000/gutentags_plus'                                              " 方便自动化管理tags插件
Plug 'preservim/tagbar'                                                        " 当前文件的标签浏览器
Plug 'MattesGroeger/vim-bookmarks'                                             " vim的书签插件
Plug 'azabiong/vim-highlighter'                                                " 多高亮标签插件

Plug 'dhruvasagar/vim-table-mode'                                              " 表格模式编辑插件
Plug 'Yggdroot/LeaderF'                                                        " 模糊搜索插件
Plug 'skywind3000/vim-terminal-help'                                           " 终端帮助插件
Plug 'easymotion/vim-easymotion'                                               " 快速移动插件

call plug#end()
" 插件 }

" 插件配置 {
" dense-analysis/ale {
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
" 错误提示的虚拟文本只在当前行出现
let g:ale_virtualtext_cursor = 'current'


" dense-analysis/ale }

" vim-gutentags {
" 这两句非常重要是缺一不可的,并且配置文件的路径一定不能写错
let $GTAGSLABEL = 'native-pygments'                                              " 让非C语言使用这个生成符号表
let $GTAGSCONF = 'C:/Users/pc/.vim/gtags/share/gtags/gtags.conf'                 " gtags的配置文件的路径

let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']      " gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_ctags_tagfile = '.tags'                                          " 所生成的数据文件的名称

let g:gutentags_modules = ['ctags', 'gtags_cscope']                              " 同时开启 ctags 和 gtags 支持

let g:gutentags_cache_dir = expand('~/.cache/tags')                              " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录

" 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

let g:gutentags_plus_switch = 0                                                  " 是否自动将光标定位到自动修复列表位置 0:禁用 1:打开

" vim-gutentags }


" tagbar {
nmap <F8> :TagbarToggle<CR>
" tagbar }


" vim-gitgutter {
let g:gitgutter_git_executable = 'D:\programes\git\Git\bin\git.exe'              " 是否自动将光标定位到自动修复列表位置 0:禁用 1:打开
let g:gitgutter_max_signs = -1                                                   " 标记的数量为无限
" vim-gitgutter }

" vim-guifont {
let guifontpp_size_increment=2
let guifontpp_smaller_font_map="<F10>"
let guifontpp_larger_font_map="<C-S-F10>"
let guifontpp_original_font_map="<C-F10>"
" vim-guifont }

" gtagsomnicomplete {
" https://github.com/ragcatshxu/gtagsomnicomplete 这个插件没有使用插件管理器安装
autocmd FileType c,python,sh set omnifunc=gtagsomnicomplete#Complete
" gtagsomnicomplete }



" 插件配置 }

