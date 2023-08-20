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
set noexpandtab

" highlight current line
set cursorline
" cursor not blinking
set guicursor+=a:blinkon0

set guifont=sarasa\ mono\ sc:h13

set noundofile
set nobackup

" 基本设置区域 }

" 插件 {
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
" 文件管理器
Plugin 'preservim/nerdtree'
" 单词包围
Plugin 'tpope/vim-surround'
" bash开发支持
Plugin 'WolfgangMehner/bash-support'
" 插入模式下自动补全括号
Plugin 'jiangmiao/auto-pairs'
" 异步语法检查和自动格式化框架
Plugin 'dense-analysis/ale'
" 漂亮的状态栏
Plugin 'vim-airline/vim-airline'
" 自动对齐插件
Plugin 'godlygeek/tabular'
" 对齐参考线插件
Plugin 'Yggdroot/indentLine'
" vim的git集成插件
Plugin 'tpope/vim-fugitive'
" 显示漂亮的git praph插件
Plugin 'rbong/vim-flog'
" vim的中文文档
Plugin 'yianwillis/vimcdoc'
" 这里必须使用realese分支,不能用master分支,master分支需要自己编译
" 下载下载后手动去插件目录下切换远程分支
Plugin 'neoclide/coc.nvim'
call vundle#end()
" 插件 }

" 插件配置 {
" dense-analysis/ale {
" 设置格式化器
let g:ale_fixers = {
\   'sh': ['shfmt'],
\}
" 通过ale提供自动完成支持
let g:ale_completion_enabled = 1
" 配置自动完成支持
set omnifunc=ale#completion#OmniFunc
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
" 使用漂亮的unicode字符
let g:ale_floating_window_border = repeat([''], 8)
" 错误提示的虚拟文本只在当前行出现
let g:ale_virtualtext_cursor = 'current'


" dense-analysis/ale }

" 插件配置 }


