
" =====================File: debug.vim {======================= 调试 ===========

" ---- vim script --------------------------------------------------------------
" 复制系统消息到剪切板
command! CopyMessages execute('redir @+ | silent messages | redir END') | echo "已复制 :messages 到系统剪贴板"

" 清空 messages 历史
command! ClearMessages silent! messages clear | echo "消息历史已清空"

" 编辑 vim 配置文件
nnoremap <Leader>ver :e $MYVIMRC<CR>
" 重新加载 vim 配置文件
nnoremap <Leader>vr :source $MYVIMRC<CR>

" ---- C languge ---------------------------------------------------------------

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


" =====================File: debug.vim }======================= 调试 ===========

