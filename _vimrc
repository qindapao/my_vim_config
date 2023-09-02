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

" 映射普通模式下面插入一行
nnoremap oo o<Esc>
" 映射普通模式上面插入一行                                                               
nnoremap OO O<Esc>
" 由于环境变量的问题,下面这行暂时不使用
" command -nargs=1 Sch noautocmd vimgrep /<args>/gj `git ls-files` | cw            " 搜索git关注的文件 :Sch xx
" 把目录切换到当前文件所在目录
nnoremap <silent> <leader>. :cd %:p:h<CR>

set rnu                                                                          " 打开相对行号
set autoread                                                                     " 自动加载文件变化

" 折叠配置区域
set foldenable                                                                   " 开始折叠
set foldmethod=indent                                                            " 设置缩进折叠
setlocal foldlevel=3                                                             " 设置折叠层数为
set foldlevelstart=99                                                            " 打开文件是默认不折叠代码


set guioptions-=T                                                                " 禁用工具栏
set guioptions-=m                                                                " 禁用菜单栏

" 打开某个目录下面的文件执行vimgrep忽略设置,这样每个项目可以独立
autocmd BufNewFile,BufRead E:/code/P5-App-Asciio* set wildignore=t/**,xt/**,*.tmp,test.c


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
Plug 'frazrepo/vim-rainbow'                                                    " 彩虹括号
Plug 'tpope/vim-commentary'                                                    " 简洁注释
Plug 'rakr/vim-one'                                                            " vim-one主题
Plug 'catppuccin/vim', { 'as': 'catppuccin' }                                  " catppuccin 主题
Plug 'jsit/toast.vim'                                                          " toast 主题
Plug 'cormacrelf/vim-colors-github'                                            " github 主题
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

" toast主题 {
set background=light
colorscheme toast
" toast主题 }

" " vim-colors-github 主题 {
" let g:github_colors_soft = 1
" set background=dark
" let g:github_colors_block_diffmark = 0
" colorscheme github
" let g:airline_theme = "github"
" 
" " vim-colors-github 主题 }

" LeaderF 配置 {
" popup menu的显示效果非常差,就暂时不用它了
" let g:Lf_WindowPosition = 'popup'                                              " 配置leaderf的弹出窗口类型为popup
" 根目录配置
let g:Lf_WorkingDirectoryMode = 'AF'                                             " 配置leaderf的工作目录模式
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', '.project', '.root']              " 根目录标识
" 索引方式
let g:Lf_UseVersionControlTool=1                                                 " 这个是默认选项, 可以不写, 按照版本控制工具来索引
let g:Lf_DefaultExternalTool='rg'                                                " 如果不是一个repo, 那么使用rg工具来索引

" 字符串检索相关配置 可以手动补充的词 (-i 忽略大小写. -e <PATTERN> 正则表达式搜索. -F 搜索字符串而不是正则表达式. -w 搜索只匹配有边界的词.)
" 命令行显示:Leaderf rg -e,然后等待输入正则表达式
nmap <unique> <leader>fr <Plug>LeaderfRgPrompt
" 查询光标或者可视模式下所在的词,非全词匹配
nmap <unique> <leader>fra <Plug>LeaderfRgCwordLiteralNoBoundary
" 查询光标或者可视模式下所在的词,全词匹配
nmap <unique> <leader>frb <Plug>LeaderfRgCwordLiteralBoundary
" 查询光标或者可视模式下所在的正则表达式，非全词匹配
nmap <unique> <leader>frc <Plug>LeaderfRgCwordRegexNoBoundary
" 查询光标或者可视模式下所在的正则表达式，全词匹配
nmap <unique> <leader>frd <Plug>LeaderfRgCwordRegexBoundary
" 上面解释了
vmap <unique> <leader>fra <Plug>LeaderfRgVisualLiteralNoBoundary
" 上面解释了
vmap <unique> <leader>frb <Plug>LeaderfRgVisualLiteralBoundary
" 上面解释了
vmap <unique> <leader>frc <Plug>LeaderfRgVisualRegexNoBoundary
" 上面解释了
vmap <unique> <leader>frd <Plug>LeaderfRgVisualRegexBoundary

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

" 为不同的项目配置不同的忽略配置
" autocmd BufNewFile,BufRead X:/yourdir* let g:Lf_WildIgnore={'file':['*.vcproj', '*.vcxproj'],'dir':[]}

let g:Lf_ShortcutB = '<c-l>'                                                     " 打开buffer搜索窗口
let g:Lf_ShortcutF = '<c-p>'                                                     " 打开leaderf窗口


" search visually selected text literally, don't quit LeaderF after accepting an entry
xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>




" LeaderF 配置 }

" 插件配置 }

