
" =====================File: terminal.vim {======================= 终端操作 ============================================

" ----------------------------------------------------------------------------

" vim-terminal-help 插件配置 {
let g:terminal_height = 20
tnoremap <Esc> <C-\><C-n>| " 终端: 进入到普通模式
" 重新映射Esc键的功能
" <C-v>的默认功能是输出特殊字符,这里<C-S-->是不行的,不知道原因
tnoremap <C-v> <C-S-_>"+| " 终端: 粘贴系统剪切板
" 这个插件自定义了一个drop命令,但是使用有报错,可能是因为windows系统的换行符导致的
" 有空可以定位下 :TODO:

" vim-terminal-help 插件配置 }

" ----------------------------------------------------------------------------

function! TerminalBuffersDelete()
    for l:bufnr in range(1, bufnr('$'))
        if buflisted(l:bufnr) && getbufvar(l:bufnr, '&buftype') == 'terminal'
            execute 'bdelete!' l:bufnr
        endif
    endfor
endfunction

" ----------------------------------------------------------------------------

" 优先 MSYS2 wrapper（优先级高）
if filereadable('D:/msys64/ucrt64_bash.bat')
    " vim-terminal-help 使用的变量，并不是vim默认的变量
    let g:terminal_cwd = 1
    " 系统环境变量中的路径一定不能有空格，否则下面的脚本会执行异常
    " 并且下面的脚本的换行符一定要是windows的换行符，如果是Linux的换行符脚本
    " 无法正常执行
    let g:terminal_shell = 'D:/msys64/ucrt64_bash.bat'
    " 下面的设置后会导致启动的时候命令行卡住，当前不使用也没有影响
    " set shellcmdflag=-c
    " set shellquote=\"
    " set shellxquote=
else
    let g:terminal_cwd = 1
    " " 当前wsl下的免密输入已经搞定,所以就使用wsl下的环境
    let g:terminal_shell = 'bash'
endif

" ----------------------------------------------------------------------------

nnoremap <leader>tbd :call TerminalBuffersDelete()<cr>| " 终端: 删除所有的终端buffer

" ----------------------------------------------------------------------------

" =====================File: terminal.vim }======================= 终端操作 ============================================

