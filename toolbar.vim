
" =====================File: toolbar.vim {======================= 工具栏 ======

" ----------------------------------------------------------------------------

" 工具栏的配置放到最后
set guioptions+=T
" set guioptions+=m

function! ToolBarGroup1()
    aunmenu ToolBar
    " menu SlideShow.SlideShow\ Menu.Next :SlidePrev<CR>
    " menu SlideShow.Start :SlideshowStart<CR>
    " menu SlideShow.Next :SlideNext<CR>
    " menu SlideShow.Prev :SlidePrev<CR>
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
    amenu ToolBar.BuiltIn18 :SlideshowStart<CR>
    amenu ToolBar.BuiltIn23 :SlideNext<CR>
    amenu ToolBar.BuiltIn22 :SlidePrev<CR>
    amenu ToolBar.BuiltIn24 :SlideInfo<CR>
    amenu ToolBar.BuiltIn4 :SlideshowStartAuto 1000<CR>
    amenu ToolBar.BuiltIn17 :SlideshowStopAuto<CR>


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

" ----------------------------------------------------------------------------

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

" ----------------------------------------------------------------------------

let g:toolbar_config = {
    \ 'current': 1,
    \ 'groups': ['ToolBarGroup1', 'ToolBarGroup2']
    \ }

" ----------------------------------------------------------------------------

function! ToggleToolBarGroup()
    let next_index = (g:toolbar_config['current'] + 1) % len(g:toolbar_config['groups'])
    let g:toolbar_config['current'] = next_index
    execute 'call ' . g:toolbar_config['groups'][g:toolbar_config['current']] . '()'
endfunction

" ----------------------------------------------------------------------------

nnoremap <silent> s, :call ToggleToolBarGroup()<CR>|   " toolbar: 切换工具栏组

" ----------------------------------------------------------------------------


" ----------------------------------------------------------------------------


" =====================File: toolbar.vim }======================= 工具栏 =======

