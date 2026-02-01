
" =====================File: translate.vim {======================= 翻译 ===============================================

" 用于发送字符到bash终端.
function! TranslateToTerminal(isBrief, language)
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

    let l:ascii_quote = CommonBashANSIQuote(l:merged)

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



function! TranslatePasteTerminalToBuffer(isBrief, selection_mode)
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


" 自动翻译相关的配置 {
" 首先需要使用 alt+= 打开默认终端
" 然后再进行下面的所有操作

" 下面的两个代理一般情况下不需要，如果说需要代理才能访问那么可以考虑加上
" let $http_proxy = 'xx:8080'
" let $https_proxy = 'yy:8080'

" 简短的翻译(中->英)
vnoremap <leader>te y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TranslateToTerminal(1, 'en')<CR>
" 完整的翻译(中->英)
vnoremap <leader>tf y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TranslateToTerminal(0, 'en')<CR>

" 简短的翻译(英->中)
vnoremap <C-t> y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TranslateToTerminal(1, 'zh')<CR>
" 完整的翻译(英->中)
vnoremap <C-S-T> y:let g:TRANSLATE_SELECTION_MODE = visualmode() \| call TranslateToTerminal(0, 'zh')<CR>

" 简单情况进行替换
nnoremap <leader>p :call TranslatePasteTerminalToBuffer(1, g:TRANSLATE_SELECTION_MODE)<CR>
" 复杂情况进行替换
nnoremap <leader><S-P> :call TranslatePasteTerminalToBuffer(0, g:TRANSLATE_SELECTION_MODE)<CR>



" 自动翻译相关的配置 }






" =====================File: translate.vim }======================= 翻译 ===============================================

