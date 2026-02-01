
" =====================File: lint.vim {======================= 语法检查 ================================================

" 注意coc.nvim插件也有语法检查功能(某些情况下也需要关闭,比如调试)
" 关闭
" :CocCommand eslint.disable
" 打开
" :CocCommand eslint.enable
" 如果上面的命令没有效果，可以直接关闭coc整个插件
" :CocDisable
" 要重新打开,使用
" CocEnable

" dense-analysis/ale {

function! s:ToggleALEByFiletype()
    if index(g:ale_disabled_filetypes, &filetype) >= 0
        silent! ALEDisable
    else
        silent! ALEEnable
    endif
endfunction


" 保存的时候不要自动检查
let g:ale_lint_on_save = 0
" 定义需要禁用 ALE 的文件类型列表
let g:ale_disabled_filetypes = ['markdown', 'asciidocx', 'asciidoc', 'adoc', 'text', 'txt', 'zim', 'sh', 'bash']
" 每次打开文件时判断是否禁用 ALE
autocmd FileType * call s:ToggleALEByFiletype()


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



" }

" ----------------------------------------------------------------------------

" 手动关闭ale(大部分的卡顿都是这里造成的,包括打开md文件)
nnoremap <leader>af :ALEDisable<cr>| " lint: 关闭ale的语法检查
" 手动打开ale
nnoremap <leader>ao :ALEEnable<cr>| " lint: 打开ale的语法检查

" ----------------------------------------------------------------------------

" =====================File: lint.vim }======================= 语法检查 ================================================

